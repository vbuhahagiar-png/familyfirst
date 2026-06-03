import 'package:cloud_firestore/cloud_firestore.dart';

class DayAvailability {
  final String start;
  final String end;
  final bool enabled;

  const DayAvailability({
    required this.start,
    required this.end,
    required this.enabled,
  });

  factory DayAvailability.fromMap(Map<String, dynamic> data) {
    return DayAvailability(
      start: data['start'] ?? '09:00',
      end: data['end'] ?? '18:00',
      enabled: data['enabled'] ?? true,
    );
  }

  Map<String, dynamic> toMap() => {
        'start': start,
        'end': end,
        'enabled': enabled,
      };

  static DayAvailability get defaultWorkday => const DayAvailability(
        start: '09:00',
        end: '18:00',
        enabled: true,
      );

  static DayAvailability get defaultWeekend => const DayAvailability(
        start: '10:00',
        end: '16:00',
        enabled: false,
      );
}

class ProviderLocation {
  final String city;
  final String district;

  const ProviderLocation({
    required this.city,
    required this.district,
  });

  factory ProviderLocation.fromMap(Map<String, dynamic> data) {
    return ProviderLocation(
      city: data['city'] ?? 'Астана',
      district: data['district'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'city': city,
        'district': district,
      };
}

class ProviderModel {
  final String id;
  final String userId;
  final String displayName;
  final String bio;
  final String photoURL;
  final String idDocumentURL;
  final List<String> serviceCategories;
  final double pricePerHour;
  final String currency;
  final double rating;
  final int totalReviews;
  final int totalBookings;
  final int responseTime; // minutes
  final bool isVerified;
  final bool isAvailableNow;
  final String gender; // 'male' | 'female'
  final String? stripeAccountId;
  final Map<String, DayAvailability> availability;
  final ProviderLocation location;
  final DateTime createdAt;
  final List<String> photoGallery;
  final int yearsOfExperience;

  const ProviderModel({
    required this.id,
    required this.userId,
    required this.displayName,
    this.bio = '',
    this.photoURL = '',
    this.idDocumentURL = '',
    required this.serviceCategories,
    required this.pricePerHour,
    this.currency = 'KZT',
    this.rating = 0.0,
    this.totalReviews = 0,
    this.totalBookings = 0,
    this.responseTime = 30,
    this.isVerified = false,
    this.isAvailableNow = false,
    required this.gender,
    this.stripeAccountId,
    required this.availability,
    required this.location,
    required this.createdAt,
    this.photoGallery = const [],
    this.yearsOfExperience = 0,
  });

  factory ProviderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProviderModel.fromMap(data, doc.id);
  }

  factory ProviderModel.fromMap(Map<String, dynamic> data, String id) {
    final availabilityData =
        data['availability'] as Map<String, dynamic>? ?? {};
    final availability = <String, DayAvailability>{};
    for (final entry in availabilityData.entries) {
      availability[entry.key] =
          DayAvailability.fromMap(entry.value as Map<String, dynamic>);
    }

    return ProviderModel(
      id: id,
      userId: data['userId'] ?? '',
      displayName: data['displayName'] ?? '',
      bio: data['bio'] ?? '',
      photoURL: data['photoURL'] ?? '',
      idDocumentURL: data['idDocumentURL'] ?? '',
      serviceCategories:
          List<String>.from(data['serviceCategories'] ?? []),
      pricePerHour: (data['pricePerHour'] ?? 0).toDouble(),
      currency: data['currency'] ?? 'KZT',
      rating: (data['rating'] ?? 0.0).toDouble(),
      totalReviews: data['totalReviews'] ?? 0,
      totalBookings: data['totalBookings'] ?? 0,
      responseTime: data['responseTime'] ?? 30,
      isVerified: data['isVerified'] ?? false,
      isAvailableNow: data['isAvailableNow'] ?? false,
      gender: data['gender'] ?? 'female',
      stripeAccountId: data['stripeAccountId'],
      availability: availability,
      location: ProviderLocation.fromMap(
          data['location'] as Map<String, dynamic>? ?? {}),
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      photoGallery: List<String>.from(data['photoGallery'] ?? []),
      yearsOfExperience: data['yearsOfExperience'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'displayName': displayName,
      'bio': bio,
      'photoURL': photoURL,
      'idDocumentURL': idDocumentURL,
      'serviceCategories': serviceCategories,
      'pricePerHour': pricePerHour,
      'currency': currency,
      'rating': rating,
      'totalReviews': totalReviews,
      'totalBookings': totalBookings,
      'responseTime': responseTime,
      'isVerified': isVerified,
      'isAvailableNow': isAvailableNow,
      'gender': gender,
      'stripeAccountId': stripeAccountId,
      'availability':
          availability.map((k, v) => MapEntry(k, v.toMap())),
      'location': location.toMap(),
      'createdAt': Timestamp.fromDate(createdAt),
      'photoGallery': photoGallery,
      'yearsOfExperience': yearsOfExperience,
    };
  }

  String get formattedPrice =>
      '${pricePerHour.toStringAsFixed(0)} ₸/час';

  String get formattedRating => rating.toStringAsFixed(1);

  bool isAvailableOn(String day) =>
      availability[day]?.enabled ?? false;

  ProviderModel copyWith({
    String? id,
    String? userId,
    String? displayName,
    String? bio,
    String? photoURL,
    String? idDocumentURL,
    List<String>? serviceCategories,
    double? pricePerHour,
    String? currency,
    double? rating,
    int? totalReviews,
    int? totalBookings,
    int? responseTime,
    bool? isVerified,
    bool? isAvailableNow,
    String? gender,
    String? stripeAccountId,
    Map<String, DayAvailability>? availability,
    ProviderLocation? location,
    DateTime? createdAt,
    List<String>? photoGallery,
    int? yearsOfExperience,
  }) {
    return ProviderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      bio: bio ?? this.bio,
      photoURL: photoURL ?? this.photoURL,
      idDocumentURL: idDocumentURL ?? this.idDocumentURL,
      serviceCategories: serviceCategories ?? this.serviceCategories,
      pricePerHour: pricePerHour ?? this.pricePerHour,
      currency: currency ?? this.currency,
      rating: rating ?? this.rating,
      totalReviews: totalReviews ?? this.totalReviews,
      totalBookings: totalBookings ?? this.totalBookings,
      responseTime: responseTime ?? this.responseTime,
      isVerified: isVerified ?? this.isVerified,
      isAvailableNow: isAvailableNow ?? this.isAvailableNow,
      gender: gender ?? this.gender,
      stripeAccountId: stripeAccountId ?? this.stripeAccountId,
      availability: availability ?? this.availability,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
      photoGallery: photoGallery ?? this.photoGallery,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
    );
  }

  static Map<String, DayAvailability> defaultAvailability() => {
        'monday': DayAvailability.defaultWorkday,
        'tuesday': DayAvailability.defaultWorkday,
        'wednesday': DayAvailability.defaultWorkday,
        'thursday': DayAvailability.defaultWorkday,
        'friday': DayAvailability.defaultWorkday,
        'saturday': DayAvailability.defaultWeekend,
        'sunday': DayAvailability(
          start: '10:00',
          end: '16:00',
          enabled: false,
        ),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ProviderModel && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
