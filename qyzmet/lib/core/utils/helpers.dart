import 'package:flutter/material.dart';

import '../../config/app_colors.dart';
import '../models/booking_model.dart';

class Helpers {
  Helpers._();

  static Color bookingStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return AppColors.statusPending;
      case BookingStatus.confirmed:
        return AppColors.statusConfirmed;
      case BookingStatus.inProgress:
        return AppColors.statusInProgress;
      case BookingStatus.completed:
        return AppColors.statusCompleted;
      case BookingStatus.cancelled:
        return AppColors.statusCancelled;
      case BookingStatus.refunded:
        return AppColors.statusCancelled;
    }
  }

  static String greetingByTime() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Доброе утро';
    if (hour < 18) return 'Добрый день';
    return 'Добрый вечер';
  }

  static String dayOfWeekRu(DateTime date) {
    const days = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday',
    ];
    return days[date.weekday - 1];
  }

  static String dayOfWeekRuFull(int weekday) {
    const days = [
      'Понедельник',
      'Вторник',
      'Среда',
      'Четверг',
      'Пятница',
      'Суббота',
      'Воскресенье',
    ];
    return days[weekday - 1];
  }

  static String calculateEndTime(String startTime, int durationHours) {
    final parts = startTime.split(':');
    final hour = int.parse(parts[0]) + durationHours;
    final minute = parts.length > 1 ? parts[1] : '00';
    return '${hour.toString().padLeft(2, '0')}:$minute';
  }

  static double calculateTotal(double pricePerHour, int hours) {
    return pricePerHour * hours;
  }

  static double calculateCommission(double total, double rate) {
    return total * rate;
  }

  static double calculateProviderAmount(double total, double commission) {
    return total - commission;
  }

  static String serviceCategoryIcon(String categoryId) {
    switch (categoryId) {
      case 'cleaning':
        return '🧹';
      case 'babysitting':
        return '👶';
      case 'repairs':
        return '🔧';
      case 'renovation':
        return '🏗️';
      case 'plumbing':
        return '🚿';
      case 'electrical':
        return '⚡';
      case 'garden':
        return '🌱';
      case 'moving':
        return '📦';
      default:
        return '🏠';
    }
  }

  static String serviceCategoryNameRu(String categoryId) {
    switch (categoryId) {
      case 'cleaning':
        return 'Уборка';
      case 'babysitting':
        return 'Няня';
      case 'repairs':
        return 'Ремонт';
      case 'renovation':
        return 'Ремонт квартиры';
      case 'plumbing':
        return 'Сантехника';
      case 'electrical':
        return 'Электрика';
      case 'garden':
        return 'Сад';
      case 'moving':
        return 'Переезд';
      default:
        return categoryId;
    }
  }

  static void showSnackBar(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  static Future<bool> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Подтвердить',
    String cancelText = 'Отмена',
    bool isDestructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: isDestructive
                ? TextButton.styleFrom(
                    foregroundColor: AppColors.error)
                : null,
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
