import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/app_colors.dart';
import '../../../core/services/auth_service.dart';
import '../../../navigation/route_names.dart';
import 'provider_home_screen.dart';

class ProviderProfileScreen extends ConsumerWidget {
  const ProviderProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final providerAsync = ref.watch(providerProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Профиль'),
        backgroundColor: AppColors.background,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.go(RouteNames.providerProfileSetup),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Profile header
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: AppColors.primarySurface,
                  child: Text(
                    userAsync.value?.displayName.isNotEmpty == true
                        ? userAsync.value!.displayName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  userAsync.value?.displayName ?? '',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 4),
                providerAsync.when(
                  loading: () => const SizedBox(),
                  error: (_, __) => const SizedBox(),
                  data: (p) => p != null
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (p.isVerified)
                              const Icon(
                                Icons.verified,
                                color: AppColors.primary,
                                size: 16,
                              ),
                            if (p.isVerified) const SizedBox(width: 4),
                            Text(
                              p.isVerified
                                  ? 'Верифицирован'
                                  : 'На проверке',
                              style: TextStyle(
                                color: p.isVerified
                                    ? AppColors.primary
                                    : AppColors.warning,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        )
                      : const SizedBox(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Stats
          providerAsync.when(
            loading: () => const SizedBox(),
            error: (_, __) => const SizedBox(),
            data: (p) => p != null
                ? Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                            label: 'Рейтинг',
                            value: p.formattedRating,
                            icon: Icons.star,
                            color: AppColors.starFilled),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                            label: 'Заказов',
                            value: '${p.totalBookings}',
                            icon: Icons.work,
                            color: AppColors.primary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                            label: 'Отзывов',
                            value: '${p.totalReviews}',
                            icon: Icons.rate_review,
                            color: AppColors.info),
                      ),
                    ],
                  )
                : const SizedBox(),
          ),

          const SizedBox(height: 24),

          // Menu
          _MenuItem(
            icon: Icons.settings,
            label: 'Настройки',
            onTap: () {},
          ),
          _MenuItem(
            icon: Icons.language,
            label: 'Язык',
            onTap: () {},
          ),
          _MenuItem(
            icon: Icons.help_outline,
            label: 'Поддержка',
            onTap: () {},
          ),
          _MenuItem(
            icon: Icons.privacy_tip_outlined,
            label: 'Политика конфиденциальности',
            onTap: () {},
          ),

          const SizedBox(height: 16),

          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider),
            ),
            child: ListTile(
              leading: const Icon(Icons.logout, color: AppColors.error),
              title: const Text(
                'Выйти',
                style: TextStyle(color: AppColors.error),
              ),
              onTap: () async {
                await ref.read(authServiceProvider).signOut();
                if (context.mounted) context.go(RouteNames.login);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: color,
              fontFamily: 'Inter',
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.textSecondary, size: 22),
        title: Text(label),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textHint),
        onTap: onTap,
      ),
    );
  }
}
