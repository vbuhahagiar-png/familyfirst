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

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  String _role = 'client';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final user = await ref
          .read(authServiceProvider)
          .registerWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            displayName: _nameController.text.trim(),
            role: _role,
          );

      if (mounted) {
        if (user.isProvider) {
          context.go(RouteNames.providerProfileSetup);
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
    if (error.contains('email-already-in-use')) {
      return 'Этот email уже используется';
    }
    if (error.contains('weak-password')) return 'Пароль слишком слабый';
    if (error.contains('invalid-email')) return 'Неверный формат email';
    return 'Ошибка регистрации. Попробуйте снова';
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Создать аккаунт'),
          backgroundColor: AppColors.background,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Кто вы?',
                  style: Theme.of(context).textTheme.titleLarge,
                ),

                const SizedBox(height: 12),

                // Role selector
                Row(
                  children: [
                    Expanded(
                      child: _RoleCard(
                        label: 'Клиент',
                        description: 'Заказываю услуги',
                        icon: Icons.person,
                        isSelected: _role == 'client',
                        onTap: () => setState(() => _role = 'client'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _RoleCard(
                        label: 'Специалист',
                        description: 'Предоставляю услуги',
                        icon: Icons.work,
                        isSelected: _role == 'provider',
                        onTap: () => setState(() => _role = 'provider'),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                Text(
                  'Ваши данные',
                  style: Theme.of(context).textTheme.titleLarge,
                ),

                const SizedBox(height: 16),

                QyzmetTextField(
                  label: 'Имя и фамилия',
                  controller: _nameController,
                  validator: Validators.name,
                  textCapitalization: TextCapitalization.words,
                  prefixIcon: const Icon(Icons.person_outline, size: 20),
                ),

                const SizedBox(height: 16),

                QyzmetTextField(
                  label: 'Email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.email,
                  prefixIcon: const Icon(Icons.email_outlined, size: 20),
                ),

                const SizedBox(height: 16),

                QyzmetTextField(
                  label: 'Пароль',
                  controller: _passwordController,
                  isPassword: true,
                  validator: Validators.password,
                  prefixIcon: const Icon(Icons.lock_outline, size: 20),
                ),

                const SizedBox(height: 16),

                QyzmetTextField(
                  label: 'Подтвердите пароль',
                  controller: _confirmPasswordController,
                  isPassword: true,
                  validator: (v) => Validators.confirmPassword(
                      v, _passwordController.text),
                  prefixIcon: const Icon(Icons.lock_outline, size: 20),
                ),

                const SizedBox(height: 8),

                Text(
                  'Регистрируясь, вы принимаете Условия использования и Политику конфиденциальности',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),

                const SizedBox(height: 24),

                QyzmetButton(
                  label: 'Зарегистрироваться',
                  onPressed: _register,
                  isLoading: _isLoading,
                ),

                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Уже есть аккаунт? ',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    TextButton(
                      onPressed: () => context.go(RouteNames.login),
                      child: const Text(
                        'Войти',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String label;
  final String description;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.label,
    required this.description,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primarySurface : AppColors.surface,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
