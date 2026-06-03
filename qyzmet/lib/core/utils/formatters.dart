import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  static final _kztFormatter = NumberFormat('#,##0', 'ru_KZ');
  static final _dateFormatter = DateFormat('dd MMMM yyyy', 'ru');
  static final _shortDateFormatter = DateFormat('dd MMM', 'ru');
  static final _timeFormatter = DateFormat('HH:mm');
  static final _dateTimeFormatter = DateFormat('dd MMM, HH:mm', 'ru');
  static final _dayNameFormatter = DateFormat('EEEE', 'ru');

  static String currency(double amount, {String symbol = '₸'}) {
    return '${_kztFormatter.format(amount)} $symbol';
  }

  static String date(DateTime date) {
    return _dateFormatter.format(date);
  }

  static String shortDate(DateTime date) {
    return _shortDateFormatter.format(date);
  }

  static String time(DateTime dateTime) {
    return _timeFormatter.format(dateTime);
  }

  static String dateTime(DateTime dt) {
    return _dateTimeFormatter.format(dt);
  }

  static String dayName(DateTime date) {
    return _dayNameFormatter.format(date);
  }

  static String duration(int hours) {
    if (hours == 1) return '1 час';
    if (hours >= 2 && hours <= 4) return '$hours часа';
    return '$hours часов';
  }

  static String phone(String phone) {
    final digits = phone.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.length == 11) {
      return '+${digits[0]} (${digits.substring(1, 4)}) ${digits.substring(4, 7)}-${digits.substring(7, 9)}-${digits.substring(9)}';
    }
    return phone;
  }

  static String relativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Только что';
    } else if (difference.inHours < 1) {
      final m = difference.inMinutes;
      return '$m мин. назад';
    } else if (difference.inDays < 1) {
      final h = difference.inHours;
      return '$h ч. назад';
    } else if (difference.inDays < 7) {
      final d = difference.inDays;
      return '$d дн. назад';
    } else {
      return shortDate(dateTime);
    }
  }

  static String responseTime(int minutes) {
    if (minutes < 60) {
      return '~$minutes мин.';
    }
    final hours = (minutes / 60).round();
    return '~$hours ч.';
  }

  static String rating(double rating) {
    return rating.toStringAsFixed(1);
  }

  static String bookingStatus(String status) {
    switch (status) {
      case 'pending':
        return 'Ожидание';
      case 'confirmed':
        return 'Подтверждено';
      case 'in_progress':
        return 'В процессе';
      case 'completed':
        return 'Завершено';
      case 'cancelled':
        return 'Отменено';
      case 'refunded':
        return 'Возврат';
      default:
        return status;
    }
  }
}
