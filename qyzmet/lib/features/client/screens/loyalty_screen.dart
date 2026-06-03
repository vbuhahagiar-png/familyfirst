import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/app_colors.dart';
import '../../../core/models/loyalty_model.dart';
import '../../../core/services/auth_service.dart';
import '../../shared/widgets/qyzmet_app_bar.dart';

class LoyaltyScreen extends ConsumerWidget {
  const LoyaltyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const QyzmetAppBar(title: 'Программа лояльности'),
      body: userAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(child: Text('Ошибка: $e')),
        data: (user) {
          if (user == null) return const SizedBox();
          final level =
              LoyaltyLevelExtension.fromBookings(user.totalBookings);
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Level card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      // Level icon
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            _levelEmoji(level),
                            style: const TextStyle(fontSize: 40),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        level.nameRu,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Inter',
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${user.loyaltyPoints} баллов',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 18,
                          fontFamily: 'Inter',
                        ),
                      ),

                      if (level != LoyaltyLevel.gold) ...[
                        const SizedBox(height: 16),
                        // Progress to next level
                        _ProgressBar(
                          current: user.totalBookings,
                          target: _nextLevelTarget(level),
                          label: '${_bookingsToNext(user.totalBookings, level)} заказов до следующего уровня',
                        ),
                      ] else ...[
                        const SizedBox(height: 12),
                        const Text(
                          'Максимальный уровень!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Benefits
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Ваши привилегии',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                if (level.discountRate > 0)
                  _BenefitCard(
                    icon: Icons.discount,
                    title: 'Скидка ${(level.discountRate * 100).round()}%',
                    description: 'На все заказы',
                    color: AppColors.success,
                  ),

                _BenefitCard(
                  icon: Icons.priority_high,
                  title: 'Приоритетная поддержка',
                  description:
                      (level == LoyaltyLevel.silver || level == LoyaltyLevel.gold)
                          ? 'Доступна'
                          : 'Со статуса Серебро',
                  color: (level == LoyaltyLevel.silver || level == LoyaltyLevel.gold)
                      ? AppColors.primary
                      : AppColors.textHint,
                ),

                _BenefitCard(
                  icon: Icons.verified_user,
                  title: 'Золотой статус',
                  description: '15 заказов',
                  color: level == LoyaltyLevel.gold
                      ? const Color(0xFFF59E0B)
                      : AppColors.textHint,
                ),

                const SizedBox(height: 24),

                // Levels overview
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Уровни',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                _LevelRow(
                  emoji: '🔵',
                  name: 'Стандарт',
                  requirement: '0 заказов',
                  discount: '0%',
                  isActive: level == LoyaltyLevel.standard,
                ),
                _LevelRow(
                  emoji: '🥈',
                  name: 'Серебро',
                  requirement: '5+ заказов',
                  discount: '5%',
                  isActive: level == LoyaltyLevel.silver,
                ),
                _LevelRow(
                  emoji: '🥇',
                  name: 'Золото',
                  requirement: '15+ заказов',
                  discount: '10%',
                  isActive: level == LoyaltyLevel.gold,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _levelEmoji(LoyaltyLevel level) {
    switch (level) {
      case LoyaltyLevel.silver:
        return '🥈';
      case LoyaltyLevel.gold:
        return '🥇';
      default:
        return '🔵';
    }
  }

  int _nextLevelTarget(LoyaltyLevel level) {
    switch (level) {
      case LoyaltyLevel.standard:
        return LoyaltyLevel.silver.minBookings;
      case LoyaltyLevel.silver:
        return LoyaltyLevel.gold.minBookings;
      default:
        return 0;
    }
  }

  int _bookingsToNext(int total, LoyaltyLevel level) {
    return _nextLevelTarget(level) - total;
  }
}

class _ProgressBar extends StatelessWidget {
  final int current;
  final int target;
  final String label;

  const _ProgressBar({
    required this.current,
    required this.target,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (current / target).clamp(0.0, 1.0);
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white.withOpacity(0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _BenefitCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const _BenefitCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    fontFamily: 'Inter',
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelRow extends StatelessWidget {
  final String emoji;
  final String name;
  final String requirement;
  final String discount;
  final bool isActive;

  const _LevelRow({
    required this.emoji,
    required this.name,
    required this.requirement,
    required this.discount,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isActive ? AppColors.primarySurface : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? AppColors.primary : AppColors.divider,
          width: isActive ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isActive ? AppColors.primary : AppColors.textPrimary,
                    fontSize: 15,
                    fontFamily: 'Inter',
                  ),
                ),
                Text(
                  requirement,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Скидка $discount',
              style: const TextStyle(
                color: AppColors.success,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
          if (isActive) ...[
            const SizedBox(width: 8),
            const Icon(Icons.check_circle, color: AppColors.primary, size: 20),
          ],
        ],
      ),
    );
  }
}
