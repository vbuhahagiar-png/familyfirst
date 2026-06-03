import 'package:cloud_firestore/cloud_firestore.dart';

enum LoyaltyLevel {
  standard,
  silver,
  gold,
}

extension LoyaltyLevelExtension on LoyaltyLevel {
  String get nameRu {
    switch (this) {
      case LoyaltyLevel.standard:
        return 'Стандарт';
      case LoyaltyLevel.silver:
        return 'Серебро';
      case LoyaltyLevel.gold:
        return 'Золото';
    }
  }

  double get discountRate {
    switch (this) {
      case LoyaltyLevel.standard:
        return 0.0;
      case LoyaltyLevel.silver:
        return 0.05; // 5%
      case LoyaltyLevel.gold:
        return 0.10; // 10%
    }
  }

  int get minBookings {
    switch (this) {
      case LoyaltyLevel.standard:
        return 0;
      case LoyaltyLevel.silver:
        return 5;
      case LoyaltyLevel.gold:
        return 15;
    }
  }

  static LoyaltyLevel fromBookings(int totalBookings) {
    if (totalBookings >= 15) return LoyaltyLevel.gold;
    if (totalBookings >= 5) return LoyaltyLevel.silver;
    return LoyaltyLevel.standard;
  }
}

class LoyaltyTransaction {
  final String id;
  final String userId;
  final int points;
  final String description;
  final String? bookingId;
  final DateTime createdAt;

  const LoyaltyTransaction({
    required this.id,
    required this.userId,
    required this.points,
    required this.description,
    this.bookingId,
    required this.createdAt,
  });

  factory LoyaltyTransaction.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LoyaltyTransaction(
      id: doc.id,
      userId: data['userId'] ?? '',
      points: data['points'] ?? 0,
      description: data['description'] ?? '',
      bookingId: data['bookingId'],
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'points': points,
      'description': description,
      'bookingId': bookingId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

class LoyaltyModel {
  final String userId;
  final int totalPoints;
  final int totalBookings;
  final LoyaltyLevel level;
  final List<LoyaltyTransaction> transactions;

  const LoyaltyModel({
    required this.userId,
    required this.totalPoints,
    required this.totalBookings,
    required this.level,
    this.transactions = const [],
  });

  int get bookingsToNextLevel {
    switch (level) {
      case LoyaltyLevel.standard:
        return LoyaltyLevel.silver.minBookings - totalBookings;
      case LoyaltyLevel.silver:
        return LoyaltyLevel.gold.minBookings - totalBookings;
      case LoyaltyLevel.gold:
        return 0;
    }
  }

  bool get isMaxLevel => level == LoyaltyLevel.gold;

  double get discountRate => level.discountRate;

  double applyDiscount(double amount) {
    return amount * (1 - discountRate);
  }
}
