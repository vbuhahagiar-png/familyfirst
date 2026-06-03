import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/app_colors.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/utils/formatters.dart';
import '../../shared/widgets/qyzmet_app_bar.dart';
import '../widgets/earnings_chart.dart';
import 'provider_home_screen.dart';

class ProviderEarningsScreen extends ConsumerWidget {
  const ProviderEarningsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final providerAsync = ref.watch(providerProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const QyzmetAppBar(
        title: 'Мои доходы',
        showBackButton: false,
      ),
      body: providerAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(child: Text('Ошибка: $e')),
        data: (provider) {
          if (provider == null) {
            return const Center(child: Text('Профиль не найден'));
          }
          return _EarningsBody(providerId: provider.id);
        },
      ),
    );
  }
}

class _EarningsBody extends ConsumerWidget {
  final String providerId;

  const _EarningsBody({required this.providerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<Map<String, double>>(
      future:
          ref.read(firestoreServiceProvider).getProviderEarnings(providerId),
      builder: (context, snapshot) {
        final earnings = snapshot.data ??
            {'today': 0, 'week': 0, 'month': 0, 'total': 0};

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Total earnings card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Всего заработано',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      Formatters.currency(earnings['total'] ?? 0),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Period cards
              Row(
                children: [
                  Expanded(
                    child: _PeriodCard(
                      label: 'Сегодня',
                      amount: earnings['today'] ?? 0,
                      icon: Icons.today,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _PeriodCard(
                      label: 'Неделя',
                      amount: earnings['week'] ?? 0,
                      icon: Icons.date_range,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _PeriodCard(
                      label: 'Месяц',
                      amount: earnings['month'] ?? 0,
                      icon: Icons.calendar_month,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Chart
              const Text(
                'График за неделю',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Inter',
                ),
              ),

              const SizedBox(height: 16),

              Container(
                height: 200,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.divider),
                ),
                child: EarningsChart(
                  data: const [
                    5000, 12000, 8000, 15000, 9000, 20000, 11000
                  ],
                  labels: const ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'],
                  maxValue: 20000,
                ),
              ),

              const SizedBox(height: 24),

              // Commission info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.info, size: 20),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Комиссия платформы: 15%. Выплаты производятся раз в неделю на привязанный счёт.',
                        style: TextStyle(
                          color: AppColors.info,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Payout button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.account_balance_wallet),
                  label: const Text(
                    'Запросить выплату',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PeriodCard extends StatelessWidget {
  final String label;
  final double amount;
  final IconData icon;

  const _PeriodCard({
    required this.label,
    required this.amount,
    required this.icon,
  });

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
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(height: 8),
          Text(
            Formatters.currency(amount),
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: AppColors.primary,
              fontFamily: 'Inter',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
