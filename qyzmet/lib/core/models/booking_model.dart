import 'package:cloud_firestore/cloud_firestore.dart';

enum BookingStatus {
  pending,
  confirmed,
  inProgress,
  completed,
  cancelled,
  refunded,
}

enum PaymentStatus {
  pending,
  paid,
  refunded,
}

extension BookingStatusExtension on BookingStatus {
  String get value {
    switch (this) {
      case BookingStatus.pending:
        return 'pending';
      case BookingStatus.confirmed:
        return 'confirmed';
      case BookingStatus.inProgress:
        return 'in_progress';
      case BookingStatus.completed:
        return 'completed';
      case BookingStatus.cancelled:
        return 'cancelled';
      case BookingStatus.refunded:
        return 'refunded';
    }
  }

  static BookingStatus fromString(String value) {
    switch (value) {
      case 'confirmed':
        return BookingStatus.confirmed;
      case 'in_progress':
        return BookingStatus.inProgress;
      case 'completed':
        return BookingStatus.completed;
      case 'cancelled':
        return BookingStatus.cancelled;
      case 'refunded':
        return BookingStatus.refunded;
      default:
        return BookingStatus.pending;
    }
  }

  String get labelRu {
    switch (this) {
      case BookingStatus.pending:
        return 'Ожидание';
      case BookingStatus.confirmed:
        return 'Подтверждено';
      case BookingStatus.inProgress:
        return 'В процессе';
      case BookingStatus.completed:
        return 'Завершено';
      case BookingStatus.cancelled:
        return 'Отменено';
      case BookingStatus.refunded:
        return 'Возврат';
    }
  }
}

extension PaymentStatusExtension on PaymentStatus {
  String get value {
    switch (this) {
      case PaymentStatus.pending:
        return 'pending';
      case PaymentStatus.paid:
        return 'paid';
      case PaymentStatus.refunded:
        return 'refunded';
    }
  }

  static PaymentStatus fromString(String value) {
    switch (value) {
      case 'paid':
        return PaymentStatus.paid;
      case 'refunded':
        return PaymentStatus.refunded;
      default:
        return PaymentStatus.pending;
    }
  }
}

class BookingModel {
  final String id;
  final String clientId;
  final String providerId;
  final String providerName;
  final String providerPhotoURL;
  final String clientName;
  final String serviceCategory;
  final String serviceName;
  final DateTime date;
  final String startTime;
  final String endTime;
  final int durationHours;
  final double totalAmount;
  final double commission;
  final double providerAmount;
  final String currency;
  final BookingStatus status;
  final String? paymentIntentId;
  final PaymentStatus paymentStatus;
  final String address;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BookingModel({
    required this.id,
    required this.clientId,
    required this.providerId,
    this.providerName = '',
    this.providerPhotoURL = '',
    this.clientName = '',
    required this.serviceCategory,
    required this.serviceName,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.durationHours,
    required this.totalAmount,
    required this.commission,
    required this.providerAmount,
    this.currency = 'KZT',
    required this.status,
    this.paymentIntentId,
    required this.paymentStatus,
    required this.address,
    this.notes = '',
    required this.createdAt,
    required this.updatedAt,
  });

  factory BookingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BookingModel.fromMap(data, doc.id);
  }

  factory BookingModel.fromMap(Map<String, dynamic> data, String id) {
    return BookingModel(
      id: id,
      clientId: data['clientId'] ?? '',
      providerId: data['providerId'] ?? '',
      providerName: data['providerName'] ?? '',
      providerPhotoURL: data['providerPhotoURL'] ?? '',
      clientName: data['clientName'] ?? '',
      serviceCategory: data['serviceCategory'] ?? '',
      serviceName: data['serviceName'] ?? '',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      startTime: data['startTime'] ?? '',
      endTime: data['endTime'] ?? '',
      durationHours: data['durationHours'] ?? 1,
      totalAmount: (data['totalAmount'] ?? 0).toDouble(),
      commission: (data['commission'] ?? 0).toDouble(),
      providerAmount: (data['providerAmount'] ?? 0).toDouble(),
      currency: data['currency'] ?? 'KZT',
      status: BookingStatusExtension.fromString(data['status'] ?? 'pending'),
      paymentIntentId: data['paymentIntentId'],
      paymentStatus:
          PaymentStatusExtension.fromString(data['paymentStatus'] ?? 'pending'),
      address: data['address'] ?? '',
      notes: data['notes'] ?? '',
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt:
          (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'clientId': clientId,
      'providerId': providerId,
      'providerName': providerName,
      'providerPhotoURL': providerPhotoURL,
      'clientName': clientName,
      'serviceCategory': serviceCategory,
      'serviceName': serviceName,
      'date': Timestamp.fromDate(date),
      'startTime': startTime,
      'endTime': endTime,
      'durationHours': durationHours,
      'totalAmount': totalAmount,
      'commission': commission,
      'providerAmount': providerAmount,
      'currency': currency,
      'status': status.value,
      'paymentIntentId': paymentIntentId,
      'paymentStatus': paymentStatus.value,
      'address': address,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  BookingModel copyWith({
    String? id,
    String? clientId,
    String? providerId,
    String? providerName,
    String? providerPhotoURL,
    String? clientName,
    String? serviceCategory,
    String? serviceName,
    DateTime? date,
    String? startTime,
    String? endTime,
    int? durationHours,
    double? totalAmount,
    double? commission,
    double? providerAmount,
    String? currency,
    BookingStatus? status,
    String? paymentIntentId,
    PaymentStatus? paymentStatus,
    String? address,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BookingModel(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      providerId: providerId ?? this.providerId,
      providerName: providerName ?? this.providerName,
      providerPhotoURL: providerPhotoURL ?? this.providerPhotoURL,
      clientName: clientName ?? this.clientName,
      serviceCategory: serviceCategory ?? this.serviceCategory,
      serviceName: serviceName ?? this.serviceName,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationHours: durationHours ?? this.durationHours,
      totalAmount: totalAmount ?? this.totalAmount,
      commission: commission ?? this.commission,
      providerAmount: providerAmount ?? this.providerAmount,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      paymentIntentId: paymentIntentId ?? this.paymentIntentId,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      address: address ?? this.address,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get canBeCancelled =>
      status == BookingStatus.pending || status == BookingStatus.confirmed;

  bool get isUpcoming =>
      status == BookingStatus.pending || status == BookingStatus.confirmed;

  bool get isPast =>
      status == BookingStatus.completed ||
      status == BookingStatus.cancelled ||
      status == BookingStatus.refunded;

  String get formattedTotal =>
      '${totalAmount.toStringAsFixed(0)} ₸';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is BookingModel && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
