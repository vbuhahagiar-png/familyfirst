import 'package:flutter/material.dart';

import '../../../config/app_colors.dart';

class SocialLoginButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color iconColor;
  final VoidCallback? onPressed;

  const SocialLoginButton({
    super.key,
    required this.label,
    required this.icon,
    required this.iconColor,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        side: const BorderSide(color: AppColors.border),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: AppColors.surface,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }
}
