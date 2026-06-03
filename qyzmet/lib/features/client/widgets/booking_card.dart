import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../config/app_colors.dart';
import '../../../core/models/booking_model.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/helpers.dart';

class BookingCard extends StatelessWidget {
  final BookingModel booking;
  final VoidCallback? onTap;
  final VoidCallback? onCancel;
  final VoidCallback? onReview;

  const BookingCard({
    super.key,
    required this.booking,
    this.onTap,
    this.onCancel,
    this.onReview,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Provider avatar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: booking.providerPhotoURL.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: booking.providerPhotoURL,
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            width: 48,
                            height: 48,
                            color: AppColors.surfaceVariant,
                            child: const Icon(Icons.person, size: 24),
                          ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking.providerName,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Inter',
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          booking.serviceName,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Helpers.bookingStatusColor(booking.status)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      booking.status.labelRu,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Helpers.bookingStatusColor(booking.status),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Divider
            const Divider(height: 1),

            // Details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _DetailItem(
                    icon: Icons.calendar_today,
                    label: Formatters.shortDate(booking.date),
                  ),
                  const SizedBox(width: 16),
                  _DetailItem(
                    icon: Icons.access_time,
                    label: booking.startTime,
                  ),
                  const SizedBox(width: 16),
                  _DetailItem(
                    icon: Icons.timer,
                    label: Formatters.duration(booking.durationHours),
                  ),
                  const Spacer(),
                  Text(
                    booking.formattedTotal,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ),

            // Actions
            if (booking.canBeCancelled || booking.status == BookingStatus.completed)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Row(
                  children: [
                    if (booking.canBeCancelled && onCancel != null)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: onCancel,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                            side: const BorderSide(color: AppColors.error),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text('Отменить'),
                        ),
                      ),
                    if (booking.status == BookingStatus.completed && onReview != null) ...[
                      if (booking.canBeCancelled) const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: onReview,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                          child: const Text('Оставить отзыв'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _DetailItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
            fontFamily: 'Inter',
          ),
        ),
      ],
    );
  }
}
