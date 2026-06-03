import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/app_colors.dart';
import '../../../core/services/auth_service.dart';
import '../../../navigation/route_names.dart';
import '../../shared/widgets/qyzmet_button.dart';
import '../../shared/widgets/qyzmet_text_field.dart';

class PhoneAuthScreen extends ConsumerStatefulWidget {
  final String role;

  const PhoneAuthScreen({super.key, this.role = 'client'});

  @override
  ConsumerState<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends ConsumerState<PhoneAuthScreen> {
  final _phoneController = TextEditingController(text: '+7');
  final _otpController = TextEditingController();
  bool _isLoading = false;
  bool _otpSent = false;
  String _verificationId = '';
  int _resendTimer = 0;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (_phoneController.text.length < 12) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите корректный номер телефона')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final id = await ref
          .read(authServiceProvider)
          .verifyPhoneNumber(_phoneController.text.trim());

      setState(() {
        _verificationId = id;
        _otpSent = true;
        _resendTimer = 60;
      });

      _startResendTimer();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка отправки кода: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _startResendTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted && _resendTimer > 0) {
        setState(() => _resendTimer--);
        return true;
      }
      return false;
    });
  }

  Future<void> _verifyOtp() async {
    if (_otpController.text.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите 6-значный код')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = await ref.read(authServiceProvider).verifyOtp(
            verificationId: _verificationId,
            smsCode: _otpController.text,
            role: widget.role,
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
            content: const Text('Неверный код. Попробуйте снова'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Вход по телефону'),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _otpSent
                          ? 'SMS с кодом отправлен на ${_phoneController.text}'
                          : 'Введите ваш казахстанский номер (+7)',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            if (!_otpSent) ...[
              QyzmetTextField(
                label: 'Номер телефона',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9+]'))],
                prefixIcon: const Icon(Icons.phone, size: 20),
                hint: '+7 (700) 000-0000',
              ),

              const SizedBox(height: 24),

              QyzmetButton(
                label: 'Получить код',
                onPressed: _sendOtp,
                isLoading: _isLoading,
              ),
            ] else ...[
              // OTP input
              Center(
                child: Text(
                  'Введите код из SMS',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),

              const SizedBox(height: 24),

              // OTP fields
              _OtpInputWidget(
                controller: _otpController,
                onCompleted: (code) => _verifyOtp(),
              ),

              const SizedBox(height: 32),

              QyzmetButton(
                label: 'Подтвердить',
                onPressed: _verifyOtp,
                isLoading: _isLoading,
              ),

              const SizedBox(height: 16),

              Center(
                child: _resendTimer > 0
                    ? Text(
                        'Отправить повторно через $_resendTimer с.',
                        style:
                            const TextStyle(color: AppColors.textSecondary),
                      )
                    : TextButton(
                        onPressed: _sendOtp,
                        child: const Text('Отправить код повторно'),
                      ),
              ),

              TextButton(
                onPressed: () =>
                    setState(() {
                      _otpSent = false;
                      _otpController.clear();
                    }),
                child: const Text('Изменить номер'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _OtpInputWidget extends StatelessWidget {
  final TextEditingController controller;
  final void Function(String) onCompleted;

  const _OtpInputWidget({
    required this.controller,
    required this.onCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      maxLength: 6,
      textAlign: TextAlign.center,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      style: const TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: 16,
        fontFamily: 'Inter',
      ),
      onChanged: (v) {
        if (v.length == 6) onCompleted(v);
      },
      decoration: InputDecoration(
        counterText: '',
        hintText: '------',
        hintStyle: TextStyle(
          color: AppColors.textHint,
          fontSize: 32,
          letterSpacing: 16,
        ),
        filled: true,
        fillColor: AppColors.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }
}
