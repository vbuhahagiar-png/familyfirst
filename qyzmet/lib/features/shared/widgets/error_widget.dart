import 'package:flutter/material.dart';

import '../../../config/app_colors.dart';
import 'qyzmet_button.dart';

class QyzmetErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final String? retryLabel;

  const QyzmetErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.retryLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                size: 48,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Что-то пошло не так',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              QyzmetButton(
                label: retryLabel ?? 'Попробовать снова',
                onPressed: onRetry,
                isFullWidth: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class QyzmetEmptyWidget extends StatelessWidget {
  final String message;
  final String? submessage;
  final IconData? icon;
  final Widget? action;

  const QyzmetEmptyWidget({
    super.key,
    required this.message,
    this.submessage,
    this.icon,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon ?? Icons.inbox_outlined,
                size: 48,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            if (submessage != null) ...[
              const SizedBox(height: 8),
              Text(
                submessage!,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: 24),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
