import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/app_colors.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/services/stripe_service.dart';
import '../../../core/models/booking_model.dart';
import '../../../core/utils/formatters.dart';
import '../../../navigation/route_names.dart';
import '../../shared/widgets/loading_overlay.dart';
import '../../shared/widgets/qyzmet_app_bar.dart';
import '../../shared/widgets/qyzmet_button.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  final String bookingId;
  final double totalAmount;

  const PaymentScreen({
    super.key,
    required this.bookingId,
    required this.totalAmount,
  });

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  bool _isLoading = false;
  String _selectedMethod = 'card';
  BookingModel? _booking;

  @override
  void initState() {
    super.initState();
    _loadBooking();
  }

  Future<void> _loadBooking() async {
    final b = await ref.read(firestoreServiceProvider).getBooking(widget.bookingId);
    if (mounted) setState(() => _booking = b);
  }

  Future<void> _pay() async {
    setState(() => _isLoading = true);

    try {
      final stripeService = ref.read(stripeServiceProvider);

      // Create payment intent
      final paymentData = await stripeService.createPaymentIntent(
        amountKZT: widget.totalAmount.round(),
        bookingId: widget.bookingId,
        clientId: _booking?.clientId ?? '',
        providerId: _booking?.providerId ?? '',
      );

      final clientSecret = paymentData['clientSecret'] as String;

      // Present payment sheet
      await stripeService.presentPaymentSheet(
        clientSecret: clientSecret,
        merchantName: 'Qyzmet',
        customerEmail: '',
      );

      // Update booking payment status
      await ref.read(firestoreServiceProvider).updateBooking(
        widget.bookingId,
        {
          'paymentStatus': 'paid',
          'paymentIntentId': paymentData['paymentIntentId'],
          'status': 'confirmed',
        },
      );

      if (mounted) {
        context.go(RouteNames.bookingConfirmationPath(widget.bookingId));
      }
    } catch (e) {
      if (mounted) {
        final message = e.toString().contains('cancelled')
            ? 'Оплата отменена'
            : 'Ошибка оплаты: $e';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
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
    return LoadingOverlay(
      isLoading: _isLoading,
      message: 'Обработка платежа...',
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: const QyzmetAppBar(title: 'Оплата'),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order summary
              _OrderSummary(
                booking: _booking,
                totalAmount: widget.totalAmount,
              ),

              const SizedBox(height: 24),

              // Payment methods
              const Text(
                'Способ оплаты',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Inter',
                ),
              ),

              const SizedBox(height: 12),

              _PaymentMethodTile(
                id: 'card',
                icon: Icons.credit_card,
                label: 'Банковская карта',
                sublabel: 'Visa, Mastercard, Мир',
                isSelected: _selectedMethod == 'card',
                onTap: () => setState(() => _selectedMethod = 'card'),
              ),

              const SizedBox(height: 8),

              _PaymentMethodTile(
                id: 'google_pay',
                icon: Icons.g_mobiledata,
                label: 'Google Pay',
                sublabel: '',
                isSelected: _selectedMethod == 'google_pay',
                onTap: () => setState(() => _selectedMethod = 'google_pay'),
              ),

              const SizedBox(height: 8),

              _PaymentMethodTile(
                id: 'apple_pay',
                icon: Icons.apple,
                label: 'Apple Pay',
                sublabel: '',
                isSelected: _selectedMethod == 'apple_pay',
                onTap: () => setState(() => _selectedMethod = 'apple_pay'),
              ),

              const SizedBox(height: 24),

              // Security note
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.shield, color: AppColors.success, size: 20),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Ваши платёжные данные защищены шифрованием SSL. Деньги поступят специалисту только после выполнения заказа.',
                        style: TextStyle(
                          color: AppColors.success,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              QyzmetButton(
                label: 'Оплатить ${Formatters.currency(widget.totalAmount)}',
                onPressed: _pay,
                isLoading: _isLoading,
              ),

              const SizedBox(height: 16),

              QyzmetButton(
                label: 'Отмена',
                variant: QyzmetButtonVariant.outline,
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderSummary extends StatelessWidget {
  final BookingModel? booking;
  final double totalAmount;

  const _OrderSummary({this.booking, required this.totalAmount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Детали заказа',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 12),

          if (booking != null) ...[
            _DetailRow(
                label: 'Специалист', value: booking!.providerName),
            _DetailRow(label: 'Услуга', value: booking!.serviceName),
            _DetailRow(
              label: 'Дата',
              value: Formatters.date(booking!.date),
            ),
            _DetailRow(
                label: 'Время', value: booking!.startTime),
            _DetailRow(
              label: 'Длительность',
              value: Formatters.duration(booking!.durationHours),
            ),
            _DetailRow(
                label: 'Адрес', value: booking!.address),
            const Divider(height: 20),
          ],

          _DetailRow(
            label: 'Итого',
            value: Formatters.currency(totalAmount),
            isBold: true,
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;

  const _DetailRow({
    required this.label,
    required this.value,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
                fontSize: isBold ? 16 : 14,
                color: isBold ? AppColors.primary : AppColors.textPrimary,
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

class _PaymentMethodTile extends StatelessWidget {
  final String id;
  final IconData icon;
  final String label;
  final String sublabel;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentMethodTile({
    required this.id,
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primarySurface : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 24, color: AppColors.textPrimary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      fontFamily: 'Inter',
                    ),
                  ),
                  if (sublabel.isNotEmpty)
                    Text(
                      sublabel,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppColors.primary,
              )
            else
              const Icon(
                Icons.radio_button_unchecked,
                color: AppColors.border,
              ),
          ],
        ),
      ),
    );
  }
}
