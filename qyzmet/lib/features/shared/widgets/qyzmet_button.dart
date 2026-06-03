import 'package:flutter/material.dart';

import '../../../config/app_colors.dart';

enum QyzmetButtonVariant { primary, outline, text, danger }

class QyzmetButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final QyzmetButtonVariant variant;
  final bool isLoading;
  final bool isFullWidth;
  final Widget? icon;
  final double? height;
  final double? fontSize;

  const QyzmetButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = QyzmetButtonVariant.primary,
    this.isLoading = false,
    this.isFullWidth = true,
    this.icon,
    this.height,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final content = isLoading
        ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                icon!,
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: fontSize ?? 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          );

    Widget button;

    switch (variant) {
      case QyzmetButtonVariant.primary:
        button = ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            minimumSize: Size(isFullWidth ? double.infinity : 0, height ?? 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: content,
        );
        break;

      case QyzmetButtonVariant.outline:
        button = OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary, width: 1.5),
            minimumSize: Size(isFullWidth ? double.infinity : 0, height ?? 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: content,
        );
        break;

      case QyzmetButtonVariant.text:
        button = TextButton(
          onPressed: isLoading ? null : onPressed,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            minimumSize: Size(isFullWidth ? double.infinity : 0, height ?? 52),
          ),
          child: content,
        );
        break;

      case QyzmetButtonVariant.danger:
        button = ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
            minimumSize: Size(isFullWidth ? double.infinity : 0, height ?? 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: content,
        );
        break;
    }

    return button;
  }
}
