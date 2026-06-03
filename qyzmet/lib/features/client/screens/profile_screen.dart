import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../config/app_colors.dart';
import '../../../core/models/user_model.dart';
import '../../../core/services/auth_service.dart';
import '../../../navigation/route_names.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Профиль'),
        backgroundColor: AppColors.background,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: userAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(child: Text('Ошибка: $e')),
        data: (user) {
          if (user == null) return const Center(child: Text('Нет данных'));
          return _ProfileBody(user: user);
        },
      ),
    );
  }
}

class _ProfileBody extends ConsumerWidget {
  final UserModel user;

  const _ProfileBody({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Avatar section
        Center(
          child: Stack(
            children: [
              CircleAvatar(
                radius: 52,
                backgroundColor: AppColors.primarySurface,
                backgroundImage: user.photoURL.isNotEmpty
                    ? CachedNetworkImageProvider(user.photoURL)
                    : null,
                child: user.photoURL.isEmpty
                    ? Text(
                        user.displayName.isNotEmpty
                            ? user.displayName[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                          fontFamily: 'Inter',
                        ),
                      )
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        Center(
          child: Column(
            children: [
              Text(
                user.displayName,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 4),
              Text(
                user.email,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 8),
              // Loyalty badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${user.loyaltyLevelName} · ${user.loyaltyPoints} баллов',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Stats row
        Row(
          children: [
            Expanded(
              child: _StatCard(
                value: '${user.totalBookings}',
                label: 'Заказов',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                value: '${user.loyaltyPoints}',
                label: 'Баллов',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                value: user.loyaltyLevelName,
                label: 'Уровень',
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Menu items
        _MenuSection(title: 'Аккаунт', items: [
          _MenuItem(
            icon: Icons.person_outline,
            label: 'Редактировать профиль',
            onTap: () {},
          ),
          _MenuItem(
            icon: Icons.star_outline,
            label: 'Программа лояльности',
            onTap: () => context.go(RouteNames.loyalty),
            trailing: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${user.loyaltyPoints} балл.',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          _MenuItem(
            icon: Icons.notifications_outlined,
            label: 'Уведомления',
            onTap: () {},
          ),
        ]),

        const SizedBox(height: 16),

        _MenuSection(title: 'Приложение', items: [
          _MenuItem(
            icon: Icons.language,
            label: 'Язык',
            trailing: const Text(
              'Русский',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            onTap: () {},
          ),
          _MenuItem(
            icon: Icons.dark_mode_outlined,
            label: 'Тема',
            onTap: () {},
          ),
        ]),

        const SizedBox(height: 16),

        _MenuSection(title: 'Поддержка', items: [
          _MenuItem(
            icon: Icons.help_outline,
            label: 'Центр помощи',
            onTap: () {},
          ),
          _MenuItem(
            icon: Icons.chat_outlined,
            label: 'Написать нам',
            onTap: () {},
          ),
          _MenuItem(
            icon: Icons.privacy_tip_outlined,
            label: 'Политика конфиденциальности',
            onTap: () {},
          ),
          _MenuItem(
            icon: Icons.description_outlined,
            label: 'Условия использования',
            onTap: () {},
          ),
        ]),

        const SizedBox(height: 16),

        // Logout
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.divider),
          ),
          child: ListTile(
            leading: const Icon(Icons.logout, color: AppColors.error),
            title: const Text(
              'Выйти',
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () async {
              await ref.read(authServiceProvider).signOut();
              if (context.mounted) {
                context.go(RouteNames.login);
              }
            },
          ),
        ),

        const SizedBox(height: 32),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;

  const _StatCard({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuSection extends StatelessWidget {
  final String title;
  final List<_MenuItem> items;

  const _MenuSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.divider),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1, indent: 56),
            itemBuilder: (_, i) => items[i],
          ),
        ),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget? trailing;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary, size: 22),
      title: Text(
        label,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          fontFamily: 'Inter',
        ),
      ),
      trailing: trailing ?? const Icon(Icons.chevron_right, color: AppColors.textHint),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
    );
  }
}
