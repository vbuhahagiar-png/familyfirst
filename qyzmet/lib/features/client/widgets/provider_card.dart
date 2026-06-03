import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../config/app_colors.dart';
import '../../../core/models/provider_model.dart';
import '../../../core/utils/formatters.dart';
import 'star_rating.dart';

class ProviderCard extends StatelessWidget {
  final ProviderModel provider;
  final VoidCallback onTap;
  final bool isHorizontal;

  const ProviderCard({
    super.key,
    required this.provider,
    required this.onTap,
    this.isHorizontal = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isHorizontal) {
      return _HorizontalProviderCard(provider: provider, onTap: onTap);
    }
    return _VerticalProviderCard(provider: provider, onTap: onTap);
  }
}

class _VerticalProviderCard extends StatelessWidget {
  final ProviderModel provider;
  final VoidCallback onTap;

  const _VerticalProviderCard({
    required this.provider,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: provider.photoURL.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: provider.photoURL,
                          height: 120,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => _PhotoPlaceholder(),
                          errorWidget: (_, __, ___) => _PhotoPlaceholder(),
                        )
                      : _PhotoPlaceholder(),
                ),

                // Available badge
                if (provider.isAvailableNow)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Доступен',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                // Verified badge
                if (provider.isVerified)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.verified,
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                  ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    provider.displayName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Inter',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 4),

                  Text(
                    provider.serviceCategories
                        .take(2)
                        .map((c) => _categoryLabel(c))
                        .join(', '),
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      fontFamily: 'Inter',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 6),

                  StarRating(
                    rating: provider.rating,
                    size: 12,
                    totalReviews: provider.totalReviews,
                  ),

                  const SizedBox(height: 6),

                  Text(
                    provider.formattedPrice,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _categoryLabel(String id) {
    const labels = {
      'cleaning': 'Уборка',
      'babysitting': 'Няня',
      'repairs': 'Ремонт',
      'renovation': 'Ремонт квартир',
      'plumbing': 'Сантехника',
      'electrical': 'Электрика',
      'garden': 'Сад',
      'moving': 'Переезд',
    };
    return labels[id] ?? id;
  }
}

class _HorizontalProviderCard extends StatelessWidget {
  final ProviderModel provider;
  final VoidCallback onTap;

  const _HorizontalProviderCard({
    required this.provider,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(16),
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
        child: Row(
          children: [
            // Avatar
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: provider.photoURL.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: provider.photoURL,
                          width: 72,
                          height: 72,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => _AvatarPlaceholder(),
                          errorWidget: (_, __, ___) => _AvatarPlaceholder(),
                        )
                      : _AvatarPlaceholder(),
                ),
                if (provider.isVerified)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.verified,
                        color: Colors.white,
                        size: 10,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          provider.displayName,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                      if (provider.isAvailableNow)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    provider.serviceCategories
                        .take(2)
                        .map((c) => _categoryLabel(c))
                        .join(', '),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      StarRating(
                        rating: provider.rating,
                        size: 13,
                        totalReviews: provider.totalReviews,
                      ),
                      const Spacer(),
                      Text(
                        provider.formattedPrice,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${provider.location.city} · ${Formatters.responseTime(provider.responseTime)}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textHint,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(Icons.chevron_right, color: AppColors.textHint),
          ],
        ),
      ),
    );
  }

  String _categoryLabel(String id) {
    const labels = {
      'cleaning': 'Уборка',
      'babysitting': 'Няня',
      'repairs': 'Ремонт',
      'renovation': 'Ремонт квартир',
      'plumbing': 'Сантехника',
      'electrical': 'Электрика',
      'garden': 'Сад',
      'moving': 'Переезд',
    };
    return labels[id] ?? id;
  }
}

class _PhotoPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      width: double.infinity,
      color: AppColors.surfaceVariant,
      child: const Icon(
        Icons.person,
        size: 40,
        color: AppColors.textHint,
      ),
    );
  }
}

class _AvatarPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      color: AppColors.surfaceVariant,
      child: const Icon(
        Icons.person,
        size: 32,
        color: AppColors.textHint,
      ),
    );
  }
}
