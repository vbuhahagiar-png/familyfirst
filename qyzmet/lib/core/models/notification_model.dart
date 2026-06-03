import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType {
  bookingCreated,
  bookingConfirmed,
  bookingCancelled,
  bookingCompleted,
  paymentReceived,
  newReview,
  promotionalOffer,
}

extension NotificationTypeExtension on NotificationType {
  String get value {
    switch (this) {
      case NotificationType.bookingCreated:
        return 'booking_created';
      case NotificationType.bookingConfirmed:
        return 'booking_confirmed';
      case NotificationType.bookingCancelled:
        return 'booking_cancelled';
      case NotificationType.bookingCompleted:
        return 'booking_completed';
      case NotificationType.paymentReceived:
        return 'payment_received';
      case NotificationType.newReview:
        return 'new_review';
      case NotificationType.promotionalOffer:
        return 'promotional_offer';
    }
  }

  static NotificationType fromString(String value) {
    switch (value) {
      case 'booking_confirmed':
        return NotificationType.bookingConfirmed;
      case 'booking_cancelled':
        return NotificationType.bookingCancelled;
      case 'booking_completed':
        return NotificationType.bookingCompleted;
      case 'payment_received':
        return NotificationType.paymentReceived;
      case 'new_review':
        return NotificationType.newReview;
      case 'promotional_offer':
        return NotificationType.promotionalOffer;
      default:
        return NotificationType.bookingCreated;
    }
  }
}

class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String body;
  final NotificationType type;
  final String? referenceId; // bookingId, paymentId, etc.
  final bool isRead;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    this.referenceId,
    this.isRead = false,
    required this.createdAt,
  });

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationModel.fromMap(data, doc.id);
  }

  factory NotificationModel.fromMap(Map<String, dynamic> data, String id) {
    return NotificationModel(
      id: id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      type: NotificationTypeExtension.fromString(data['type'] ?? ''),
      referenceId: data['referenceId'],
      isRead: data['isRead'] ?? false,
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'body': body,
      'type': type.value,
      'referenceId': referenceId,
      'isRead': isRead,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  NotificationModel copyWith({
    bool? isRead,
  }) {
    return NotificationModel(
      id: id,
      userId: userId,
      title: title,
      body: body,
      type: type,
      referenceId: referenceId,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is NotificationModel && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
