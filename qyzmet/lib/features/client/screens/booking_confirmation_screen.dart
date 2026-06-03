import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/app_colors.dart';
import '../../../core/models/booking_model.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/utils/formatters.dart';
import '../../../navigation/route_names.dart';
import '../../shared/widgets/qyzmet_button.dart';

class BookingConfirmationScreen extends ConsumerWidget {
  final String bookingId;

  const BookingConfirmationScreen({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<BookingModel?>(
      future: ref.read(firestoreServiceProvider).getBooking(bookingId),
      builder: (context, snapshot) {
        final booking = snapshot.data;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Success icon
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.elasticOut,
                    builder: (context, value, child) => Transform.scale(
                      scale: value,
                      child: child,
                    ),
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.success,
                          width: 3,
                        ),
                      ),
                      child: const Icon(
                        Icons.check,
                        color: AppColors.success,
                        size: 64,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  const Text(
                    'Заказ оформлен!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Inter',
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    'Ваш заказ успешно создан. Специалист свяжется с вами в ближайшее время.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 15,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 32),

                  // Booking details card
                  if (booking != null)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.divider),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadow,
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _ConfirmRow(
                            icon: Icons.person,
                            label: 'Специалист',
                            value: booking.providerName,
                          ),
                          _ConfirmRow(
                            icon: Icons.calendar_today,
                            label: 'Дата',
                            value: Formatters.date(booking.date),
                          ),
                          _ConfirmRow(
                            icon: Icons.access_time,
                            label: 'Время',
                            value: '${booking.startTime} – ${booking.endTime}',
                          ),
                          _ConfirmRow(
                            icon: Icons.location_on,
                            label: 'Адрес',
                            value: booking.address,
                          ),
                          const Divider(),
                          _ConfirmRow(
                            icon: Icons.payment,
                            label: 'Оплачено',
                            value: booking.formattedTotal,
                            valueColor: AppColors.success,
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 32),

                  QyzmetButton(
                    label: 'Мои заказы',
                    onPressed: () => context.go(RouteNames.bookingsHistory),
                  ),

                  const SizedBox(height: 12),

                  QyzmetButton(
                    label: 'На главную',
                    variant: QyzmetButtonVariant.outline,
                    onPressed: () => context.go(RouteNames.clientHome),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ConfirmRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _ConfirmRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: valueColor ?? AppColors.textPrimary,
                fontFamily: 'Inter',
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
