import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/app_colors.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/utils/validators.dart';
import '../../../navigation/route_names.dart';
import '../../shared/widgets/loading_overlay.dart';
import '../../shared/widgets/qyzmet_button.dart';
import '../../shared/widgets/qyzmet_text_field.dart';
import '../widgets/social_login_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final user = await ref.read(authServiceProvider).signInWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
      if (mounted) {
        if (user.isProvider) {
          context.go(RouteNames.providerHome);
        } else {
          context.go(RouteNames.clientHome);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_parseError(e.toString())),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final user = await ref.read(authServiceProvider).signInWithGoogle();
      if (mounted) {
        if (user.isProvider) {
          context.go(RouteNames.providerHome);
        } else {
          context.go(RouteNames.clientHome);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_parseError(e.toString())),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _parseError(String error) {
    if (error.contains('user-not-found')) return 'Пользователь не найден';
    if (error.contains('wrong-password')) return 'Неверный пароль';
    if (error.contains('invalid-email')) return 'Неверный email';
    if (error.contains('too-many-requests')) {
      return 'Слишком много попыток. Попробуйте позже';
    }
    return 'Ошибка входа. Проверьте данные и попробуйте снова';
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 48),

                  // Logo
                  Center(
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Center(
                        child: Text(
                          'Q',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  Text(
                    'Добро пожаловать!',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Войдите в аккаунт Qyzmet',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),

                  const SizedBox(height: 32),

                  // Email field
                  QyzmetTextField(
                    label: 'Email',
                    hint: 'example@mail.com',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.email,
                    prefixIcon: const Icon(Icons.email_outlined, size: 20),
                  ),

                  const SizedBox(height: 16),

                  // Password field
                  QyzmetTextField(
                    label: 'Пароль',
                    controller: _passwordController,
                    isPassword: true,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Введите пароль' : null,
                    prefixIcon: const Icon(Icons.lock_outline, size: 20),
                  ),

                  const SizedBox(height: 8),

                  // Forgot password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => _showForgotPassword(),
                      child: const Text('Забыли пароль?'),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Sign in button
                  QyzmetButton(
                    label: 'Войти',
                    onPressed: _signIn,
                    isLoading: _isLoading,
                  ),

                  const SizedBox(height: 24),

                  // Divider
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'или',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Social buttons
                  SocialLoginButton(
                    label: 'Продолжить с Google',
                    icon: Icons.g_mobiledata,
                    iconColor: Colors.red,
                    onPressed: _signInWithGoogle,
                  ),

                  const SizedBox(height: 12),

                  SocialLoginButton(
                    label: 'Продолжить с Apple',
                    icon: Icons.apple,
                    iconColor: Colors.black,
                    onPressed: () {
                      // Apple sign in
                    },
                  ),

                  const SizedBox(height: 12),

                  SocialLoginButton(
                    label: 'Продолжить с телефоном',
                    icon: Icons.phone,
                    iconColor: AppColors.primary,
                    onPressed: () => context.go(RouteNames.phoneAuth),
                  ),

                  const SizedBox(height: 32),

                  // Register link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Нет аккаунта? ',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      TextButton(
                        onPressed: () => context.go(RouteNames.register),
                        child: const Text(
                          'Зарегистрироваться',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showForgotPassword() {
    final emailController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Восстановление пароля'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Введите email для сброса пароля'),
            const SizedBox(height: 16),
            QyzmetTextField(
              label: 'Email',
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await ref
                    .read(authServiceProvider)
                    .sendPasswordResetEmail(emailController.text.trim());
                if (mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Письмо отправлено на ваш email'),
                    ),
                  );
                }
              } catch (_) {}
            },
            child: const Text('Отправить'),
          ),
        ],
      ),
    );
  }
}
