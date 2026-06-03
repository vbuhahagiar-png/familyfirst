import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/app_colors.dart';
import '../../../config/app_constants.dart';
import '../../../core/models/booking_model.dart';
import '../../../core/models/provider_model.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/helpers.dart';
import '../../../navigation/route_names.dart';
import '../../shared/widgets/loading_overlay.dart';
import '../../shared/widgets/qyzmet_app_bar.dart';
import '../../shared/widgets/qyzmet_button.dart';
import '../../shared/widgets/qyzmet_text_field.dart';

class BookingScreen extends ConsumerStatefulWidget {
  final String providerId;

  const BookingScreen({super.key, required this.providerId});

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  ProviderModel? _provider;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String _selectedTime = '';
  int _selectedDuration = 2;
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadProvider();
  }

  Future<void> _loadProvider() async {
    final p = await ref.read(firestoreServiceProvider).getProvider(widget.providerId);
    if (mounted) setState(() => _provider = p);
  }

  @override
  void dispose() {
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  double get _totalAmount =>
      (_provider?.pricePerHour ?? 0) * _selectedDuration;

  Future<void> _confirmBooking() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedTime.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Выберите время')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = await ref.read(authServiceProvider).getCurrentUserModel();
      if (user == null) throw Exception('Не авторизован');

      final provider = _provider!;
      final commission =
          Helpers.calculateCommission(_totalAmount, AppConstants.commissionRate);
      final providerAmount =
          Helpers.calculateProviderAmount(_totalAmount, commission);
      final endTime = Helpers.calculateEndTime(_selectedTime, _selectedDuration);

      final booking = BookingModel(
        id: '',
        clientId: user.uid,
        clientName: user.displayName,
        providerId: provider.id,
        providerName: provider.displayName,
        providerPhotoURL: provider.photoURL,
        serviceCategory: provider.serviceCategories.first,
        serviceName: Helpers.serviceCategoryNameRu(
            provider.serviceCategories.first),
        date: _selectedDate,
        startTime: _selectedTime,
        endTime: endTime,
        durationHours: _selectedDuration,
        totalAmount: _totalAmount,
        commission: commission,
        providerAmount: providerAmount,
        currency: 'KZT',
        status: BookingStatus.pending,
        paymentStatus: PaymentStatus.pending,
        address: _addressController.text.trim(),
        notes: _notesController.text.trim(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final bookingId =
          await ref.read(firestoreServiceProvider).createBooking(booking);

      if (mounted) {
        context.go(
          RouteNames.paymentPath(bookingId),
          extra: {'totalAmount': _totalAmount},
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_provider == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: const QyzmetAppBar(title: 'Оформить заказ'),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Provider summary
                _ProviderSummary(provider: _provider!),

                const SizedBox(height: 24),

                // Date picker
                _SectionTitle(title: 'Выберите дату'),
                const SizedBox(height: 12),
                _DatePicker(
                  selectedDate: _selectedDate,
                  onDateSelected: (d) => setState(() => _selectedDate = d),
                ),

                const SizedBox(height: 24),

                // Time picker
                _SectionTitle(title: 'Время начала'),
                const SizedBox(height: 12),
                _TimePicker(
                  selectedTime: _selectedTime,
                  onTimeSelected: (t) => setState(() => _selectedTime = t),
                ),

                const SizedBox(height: 24),

                // Duration
                _SectionTitle(title: 'Продолжительность'),
                const SizedBox(height: 12),
                _DurationPicker(
                  selectedDuration: _selectedDuration,
                  onDurationSelected: (d) =>
                      setState(() => _selectedDuration = d),
                ),

                const SizedBox(height: 24),

                // Address
                _SectionTitle(title: 'Адрес'),
                const SizedBox(height: 12),
                QyzmetTextField(
                  label: 'Улица, дом, квартира',
                  controller: _addressController,
                  maxLines: 2,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Введите адрес' : null,
                  prefixIcon: const Icon(Icons.location_on_outlined, size: 20),
                  textCapitalization: TextCapitalization.words,
                ),

                const SizedBox(height: 16),

                // Notes
                QyzmetTextField(
                  label: 'Комментарий (необязательно)',
                  controller: _notesController,
                  maxLines: 3,
                  hint: 'Особые пожелания, инструкции...',
                ),

                const SizedBox(height: 24),

                // Price summary
                _PriceSummary(
                  provider: _provider!,
                  duration: _selectedDuration,
                  total: _totalAmount,
                ),

                const SizedBox(height: 24),

                QyzmetButton(
                  label: 'Перейти к оплате',
                  onPressed: _confirmBooking,
                ),

                const SizedBox(height: 8),

                const Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock_outline, size: 14, color: AppColors.textSecondary),
                      SizedBox(width: 4),
                      Text(
                        'Безопасная оплата через Stripe',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProviderSummary extends StatelessWidget {
  final ProviderModel provider;

  const _ProviderSummary({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 56,
              height: 56,
              color: AppColors.primarySurface,
              child: const Icon(Icons.person, color: AppColors.primary, size: 28),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  provider.displayName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Inter',
                  ),
                ),
                Text(
                  provider.serviceCategories
                      .map((c) => Helpers.serviceCategoryNameRu(c))
                      .join(', '),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Text(
            provider.formattedPrice,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        fontFamily: 'Inter',
      ),
    );
  }
}

class _DatePicker extends StatelessWidget {
  final DateTime selectedDate;
  final void Function(DateTime) onDateSelected;

  const _DatePicker({
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return SizedBox(
      height: 70,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 14,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final date = now.add(Duration(days: index + 1));
          final isSelected = date.day == selectedDate.day &&
              date.month == selectedDate.month;

          return GestureDetector(
            onTap: () => onDateSelected(date),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 60,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _dayName(date.weekday),
                    style: TextStyle(
                      fontSize: 11,
                      color: isSelected
                          ? Colors.white.withOpacity(0.8)
                          : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${date.day}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _dayName(int weekday) {
    const days = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
    return days[weekday - 1];
  }
}

class _TimePicker extends StatelessWidget {
  final String selectedTime;
  final void Function(String) onTimeSelected;

  const _TimePicker({
    required this.selectedTime,
    required this.onTimeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: AppConstants.timeSlots.map((time) {
        final isSelected = time == selectedTime;
        return GestureDetector(
          onTap: () => onTimeSelected(time),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
              ),
            ),
            child: Text(
              time,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontFamily: 'Inter',
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _DurationPicker extends StatelessWidget {
  final int selectedDuration;
  final void Function(int) onDurationSelected;

  const _DurationPicker({
    required this.selectedDuration,
    required this.onDurationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: AppConstants.bookingDurations.map((hours) {
        final isSelected = hours == selectedDuration;
        return GestureDetector(
          onTap: () => onDurationSelected(hours),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
              ),
            ),
            child: Text(
              Formatters.duration(hours),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontFamily: 'Inter',
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _PriceSummary extends StatelessWidget {
  final ProviderModel provider;
  final int duration;
  final double total;

  const _PriceSummary({
    required this.provider,
    required this.duration,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          _PriceRow(
            label: '${Formatters.currency(provider.pricePerHour)} × $duration ч.',
            value: Formatters.currency(total),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(color: AppColors.primary, height: 1),
          ),
          _PriceRow(
            label: 'Итого',
            value: Formatters.currency(total),
            isBold: true,
          ),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;

  const _PriceRow({
    required this.label,
    required this.value,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isBold ? AppColors.textPrimary : AppColors.textSecondary,
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isBold ? AppColors.primary : AppColors.textPrimary,
            fontSize: isBold ? 18 : 14,
            fontWeight: FontWeight.w700,
            fontFamily: 'Inter',
          ),
        ),
      ],
    );
  }
}
