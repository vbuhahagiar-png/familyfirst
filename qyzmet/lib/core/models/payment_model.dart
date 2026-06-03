import 'package:cloud_firestore/cloud_firestore.dart';

enum PaymentMethod {
  card,
  applePay,
  googlePay,
  kaspiPay,
}

extension PaymentMethodExtension on PaymentMethod {
  String get value {
    switch (this) {
      case PaymentMethod.card:
        return 'card';
      case PaymentMethod.applePay:
        return 'apple_pay';
      case PaymentMethod.googlePay:
        return 'google_pay';
      case PaymentMethod.kaspiPay:
        return 'kaspi_pay';
    }
  }

  String get label {
    switch (this) {
      case PaymentMethod.card:
        return 'Банковская карта';
      case PaymentMethod.applePay:
        return 'Apple Pay';
      case PaymentMethod.googlePay:
        return 'Google Pay';
      case PaymentMethod.kaspiPay:
        return 'Kaspi Pay';
    }
  }

  static PaymentMethod fromString(String value) {
    switch (value) {
      case 'apple_pay':
        return PaymentMethod.applePay;
      case 'google_pay':
        return PaymentMethod.googlePay;
      case 'kaspi_pay':
        return PaymentMethod.kaspiPay;
      default:
        return PaymentMethod.card;
    }
  }
}

class PaymentModel {
  final String id;
  final String bookingId;
  final String clientId;
  final String providerId;
  final double amount;
  final double commission;
  final double providerAmount;
  final String currency;
  final String paymentIntentId;
  final PaymentMethod method;
  final String status; // 'pending' | 'succeeded' | 'failed' | 'refunded'
  final DateTime createdAt;
  final DateTime? completedAt;

  const PaymentModel({
    required this.id,
    required this.bookingId,
    required this.clientId,
    required this.providerId,
    required this.amount,
    required this.commission,
    required this.providerAmount,
    this.currency = 'KZT',
    required this.paymentIntentId,
    required this.method,
    required this.status,
    required this.createdAt,
    this.completedAt,
  });

  factory PaymentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PaymentModel.fromMap(data, doc.id);
  }

  factory PaymentModel.fromMap(Map<String, dynamic> data, String id) {
    return PaymentModel(
      id: id,
      bookingId: data['bookingId'] ?? '',
      clientId: data['clientId'] ?? '',
      providerId: data['providerId'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      commission: (data['commission'] ?? 0).toDouble(),
      providerAmount: (data['providerAmount'] ?? 0).toDouble(),
      currency: data['currency'] ?? 'KZT',
      paymentIntentId: data['paymentIntentId'] ?? '',
      method: PaymentMethodExtension.fromString(data['method'] ?? 'card'),
      status: data['status'] ?? 'pending',
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bookingId': bookingId,
      'clientId': clientId,
      'providerId': providerId,
      'amount': amount,
      'commission': commission,
      'providerAmount': providerAmount,
      'currency': currency,
      'paymentIntentId': paymentIntentId,
      'method': method.value,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'completedAt':
          completedAt != null ? Timestamp.fromDate(completedAt!) : null,
    };
  }

  bool get isSucceeded => status == 'succeeded';
  bool get isFailed => status == 'failed';
  bool get isRefunded => status == 'refunded';

  String get formattedAmount => '${amount.toStringAsFixed(0)} ₸';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is PaymentModel && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
