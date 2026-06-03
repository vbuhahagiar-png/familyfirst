import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/app_colors.dart';
import '../../../core/models/booking_model.dart';
import '../../../core/models/provider_model.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/helpers.dart';
import '../../../navigation/route_names.dart';
import '../widgets/booking_request_card.dart';

final providerProfileProvider = FutureProvider<ProviderModel?>((ref) async {
  final user = await ref.read(authServiceProvider).getCurrentUserModel();
  if (user == null) return null;
  return ref.read(firestoreServiceProvider).getProviderByUserId(user.uid);
});

final providerPendingBookingsProvider =
    StreamProvider<List<BookingModel>>((ref) async* {
  final provider = await ref.read(providerProfileProvider.future);
  if (provider == null) {
    yield [];
    return;
  }
  yield* ref.read(firestoreServiceProvider).getProviderPendingBookings(provider.id);
});

class ProviderHomeScreen extends ConsumerWidget {
  const ProviderHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final providerAsync = ref.watch(providerProfileProvider);
    final pendingAsync = ref.watch(providerPendingBookingsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: _ProviderHeader(
                name: userAsync.value?.displayName ?? '',
              ),
            ),

            // Earnings summary
            SliverToBoxAdapter(
              child: providerAsync.when(
                loading: () => const SizedBox(height: 80),
                error: (_, __) => const SizedBox(),
                data: (provider) => provider != null
                    ? _EarningsSummary(providerId: provider.id)
                    : _SetupProfile(),
              ),
            ),

            // Available toggle
            SliverToBoxAdapter(
              child: providerAsync.when(
                loading: () => const SizedBox(),
                error: (_, __) => const SizedBox(),
                data: (provider) => provider != null
                    ? _AvailableToggle(provider: provider)
                    : const SizedBox(),
              ),
            ),

            // Pending requests title
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: Text(
                  'Новые запросы',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
            ),

            // Pending bookings
            pendingAsync.when(
              loading: () => const SliverToBoxAdapter(
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              ),
              error: (e, _) =>
                  SliverToBoxAdapter(child: Center(child: Text('Ошибка: $e'))),
              data: (bookings) => bookings.isEmpty
                  ? const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: _EmptyRequests(),
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => BookingRequestCard(
                            booking: bookings[index],
                            onAccept: () => _acceptBooking(
                                context, ref, bookings[index]),
                            onDecline: () => _declineBooking(
                                context, ref, bookings[index]),
                          ),
                          childCount: bookings.length,
                        ),
                      ),
                    ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  Future<void> _acceptBooking(
      BuildContext context, WidgetRef ref, BookingModel booking) async {
    await ref.read(firestoreServiceProvider).updateBookingStatus(
          booking.id,
          BookingStatus.confirmed,
        );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Заказ принят'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<void> _declineBooking(
      BuildContext context, WidgetRef ref, BookingModel booking) async {
    await ref.read(firestoreServiceProvider).updateBookingStatus(
          booking.id,
          BookingStatus.cancelled,
        );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Заказ отклонён'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}

class _ProviderHeader extends StatelessWidget {
  final String name;

  const _ProviderHeader({required this.name});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                Helpers.greetingByTime(),
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              if (name.isNotEmpty)
                Text(
                  name.split(' ').first,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Inter',
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

class _EarningsSummary extends ConsumerWidget {
  final String providerId;

  const _EarningsSummary({required this.providerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<Map<String, double>>(
      future: ref.read(firestoreServiceProvider).getProviderEarnings(providerId),
      builder: (context, snapshot) {
        final earnings = snapshot.data ?? {};
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Доход сегодня',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  Formatters.currency(earnings['today'] ?? 0),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _EarningsItem(
                        label: 'Неделя',
                        value: Formatters.currency(earnings['week'] ?? 0),
                      ),
                    ),
                    Expanded(
                      child: _EarningsItem(
                        label: 'Месяц',
                        value: Formatters.currency(earnings['month'] ?? 0),
                      ),
                    ),
                    Expanded(
                      child: _EarningsItem(
                        label: 'Всего',
                        value: Formatters.currency(earnings['total'] ?? 0),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _EarningsItem extends StatelessWidget {
  final String label;
  final String value;

  const _EarningsItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            fontFamily: 'Inter',
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _AvailableToggle extends ConsumerWidget {
  final ProviderModel provider;

  const _AvailableToggle({required this.provider});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: provider.isAvailableNow
                    ? AppColors.success
                    : AppColors.textHint,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    provider.isAvailableNow
                        ? 'Вы доступны'
                        : 'Вы недоступны',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      fontFamily: 'Inter',
                    ),
                  ),
                  Text(
                    provider.isAvailableNow
                        ? 'Клиенты могут вас найти'
                        : 'Вы не появляетесь в поиске',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: provider.isAvailableNow,
              onChanged: (v) {
                ref.read(firestoreServiceProvider).updateProvider(
                      provider.id,
                      {'isAvailableNow': v},
                    );
              },
              activeColor: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}

class _SetupProfile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.primarySurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            const Icon(Icons.account_circle, size: 48, color: AppColors.primary),
            const SizedBox(height: 12),
            const Text(
              'Заполните профиль',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Чтобы начать принимать заказы, заполните профиль специалиста',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(RouteNames.providerProfileSetup),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              child: const Text('Заполнить профиль'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyRequests extends StatelessWidget {
  const _EmptyRequests();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 48,
            color: AppColors.textHint,
          ),
          SizedBox(height: 12),
          Text(
            'Нет новых запросов',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'Inter',
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Новые заказы появятся здесь',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
