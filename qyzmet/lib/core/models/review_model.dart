import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String id;
  final String bookingId;
  final String clientId;
  final String clientName;
  final String clientPhotoURL;
  final String providerId;
  final double rating;
  final String comment;
  final DateTime createdAt;
  final String serviceCategory;

  const ReviewModel({
    required this.id,
    required this.bookingId,
    required this.clientId,
    required this.clientName,
    this.clientPhotoURL = '',
    required this.providerId,
    required this.rating,
    this.comment = '',
    required this.createdAt,
    required this.serviceCategory,
  });

  factory ReviewModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ReviewModel.fromMap(data, doc.id);
  }

  factory ReviewModel.fromMap(Map<String, dynamic> data, String id) {
    return ReviewModel(
      id: id,
      bookingId: data['bookingId'] ?? '',
      clientId: data['clientId'] ?? '',
      clientName: data['clientName'] ?? '',
      clientPhotoURL: data['clientPhotoURL'] ?? '',
      providerId: data['providerId'] ?? '',
      rating: (data['rating'] ?? 0.0).toDouble(),
      comment: data['comment'] ?? '',
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      serviceCategory: data['serviceCategory'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bookingId': bookingId,
      'clientId': clientId,
      'clientName': clientName,
      'clientPhotoURL': clientPhotoURL,
      'providerId': providerId,
      'rating': rating,
      'comment': comment,
      'createdAt': Timestamp.fromDate(createdAt),
      'serviceCategory': serviceCategory,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ReviewModel && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
