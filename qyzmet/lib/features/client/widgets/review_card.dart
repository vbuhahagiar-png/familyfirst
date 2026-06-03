import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../config/app_colors.dart';
import '../../../core/models/review_model.dart';
import '../../../core/utils/formatters.dart';
import 'star_rating.dart';

class ReviewCard extends StatelessWidget {
  final ReviewModel review;

  const ReviewCard({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: review.clientPhotoURL.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: review.clientPhotoURL,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: AppColors.primarySurface,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            review.clientName.isNotEmpty
                                ? review.clientName[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.clientName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Inter',
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      Formatters.relativeTime(review.createdAt),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              StarRating(
                rating: review.rating,
                size: 14,
                showValue: true,
                totalReviews: null,
              ),
            ],
          ),

          if (review.comment.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              review.comment,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
                height: 1.5,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ],
      ),
    );
  }
}
