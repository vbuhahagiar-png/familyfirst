import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String phoneNumber;
  final String photoURL;
  final String role; // 'client' | 'provider'
  final DateTime createdAt;
  final int loyaltyPoints;
  final int loyaltyLevel; // 1 | 2 | 3
  final int totalBookings;
  final String preferredLanguage; // 'ru' | 'kk' | 'en'
  final bool isVerified;
  final bool notificationsEnabled;
  final String? fcmToken;

  const UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.phoneNumber = '',
    this.photoURL = '',
    required this.role,
    required this.createdAt,
    this.loyaltyPoints = 0,
    this.loyaltyLevel = 1,
    this.totalBookings = 0,
    this.preferredLanguage = 'ru',
    this.isVerified = false,
    this.notificationsEnabled = true,
    this.fcmToken,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      photoURL: data['photoURL'] ?? '',
      role: data['role'] ?? 'client',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      loyaltyPoints: data['loyaltyPoints'] ?? 0,
      loyaltyLevel: data['loyaltyLevel'] ?? 1,
      totalBookings: data['totalBookings'] ?? 0,
      preferredLanguage: data['preferredLanguage'] ?? 'ru',
      isVerified: data['isVerified'] ?? false,
      notificationsEnabled: data['notificationsEnabled'] ?? true,
      fcmToken: data['fcmToken'],
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> data, String uid) {
    return UserModel(
      uid: uid,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      photoURL: data['photoURL'] ?? '',
      role: data['role'] ?? 'client',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      loyaltyPoints: data['loyaltyPoints'] ?? 0,
      loyaltyLevel: data['loyaltyLevel'] ?? 1,
      totalBookings: data['totalBookings'] ?? 0,
      preferredLanguage: data['preferredLanguage'] ?? 'ru',
      isVerified: data['isVerified'] ?? false,
      notificationsEnabled: data['notificationsEnabled'] ?? true,
      fcmToken: data['fcmToken'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'phoneNumber': phoneNumber,
      'photoURL': photoURL,
      'role': role,
      'createdAt': Timestamp.fromDate(createdAt),
      'loyaltyPoints': loyaltyPoints,
      'loyaltyLevel': loyaltyLevel,
      'totalBookings': totalBookings,
      'preferredLanguage': preferredLanguage,
      'isVerified': isVerified,
      'notificationsEnabled': notificationsEnabled,
      'fcmToken': fcmToken,
    };
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? phoneNumber,
    String? photoURL,
    String? role,
    DateTime? createdAt,
    int? loyaltyPoints,
    int? loyaltyLevel,
    int? totalBookings,
    String? preferredLanguage,
    bool? isVerified,
    bool? notificationsEnabled,
    String? fcmToken,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      photoURL: photoURL ?? this.photoURL,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      loyaltyPoints: loyaltyPoints ?? this.loyaltyPoints,
      loyaltyLevel: loyaltyLevel ?? this.loyaltyLevel,
      totalBookings: totalBookings ?? this.totalBookings,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      isVerified: isVerified ?? this.isVerified,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }

  bool get isClient => role == 'client';
  bool get isProvider => role == 'provider';

  String get loyaltyLevelName {
    switch (loyaltyLevel) {
      case 2:
        return 'Silver';
      case 3:
        return 'Gold';
      default:
        return 'Standard';
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is UserModel && uid == other.uid;

  @override
  int get hashCode => uid.hashCode;
}
