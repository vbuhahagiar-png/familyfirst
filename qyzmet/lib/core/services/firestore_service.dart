import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/provider_model.dart';
import '../models/booking_model.dart';
import '../models/review_model.dart';
import '../models/user_model.dart';
import '../../config/app_constants.dart';

final firestoreServiceProvider =
    Provider<FirestoreService>((ref) => FirestoreService());

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─── Providers ───────────────────────────────────────────────────────────

  Future<List<ProviderModel>> getProviders({
    String? category,
    String? city,
    int limit = 20,
    DocumentSnapshot? lastDoc,
  }) async {
    Query query = _db
        .collection(AppConstants.providersCollection)
        .where('isVerified', isEqualTo: true)
        .orderBy('rating', descending: true)
        .limit(limit);

    if (category != null) {
      query = query.where('serviceCategories', arrayContains: category);
    }
    if (city != null) {
      query = query.where('location.city', isEqualTo: city);
    }
    if (lastDoc != null) {
      query = query.startAfterDocument(lastDoc);
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => ProviderModel.fromFirestore(doc))
        .toList();
  }

  Stream<ProviderModel?> getProviderStream(String providerId) {
    return _db
        .collection(AppConstants.providersCollection)
        .doc(providerId)
        .snapshots()
        .map((doc) =>
            doc.exists ? ProviderModel.fromFirestore(doc) : null);
  }

  Future<ProviderModel?> getProvider(String providerId) async {
    final doc = await _db
        .collection(AppConstants.providersCollection)
        .doc(providerId)
        .get();
    if (!doc.exists) return null;
    return ProviderModel.fromFirestore(doc);
  }

  Future<ProviderModel?> getProviderByUserId(String userId) async {
    final query = await _db
        .collection(AppConstants.providersCollection)
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();
    if (query.docs.isEmpty) return null;
    return ProviderModel.fromFirestore(query.docs.first);
  }

  Future<String> createProvider(ProviderModel provider) async {
    final ref = await _db
        .collection(AppConstants.providersCollection)
        .add(provider.toMap());
    return ref.id;
  }

  Future<void> updateProvider(String providerId, Map<String, dynamic> data) async {
    await _db
        .collection(AppConstants.providersCollection)
        .doc(providerId)
        .update(data);
  }

  Future<List<ProviderModel>> searchProviders(String query) async {
    final snapshot = await _db
        .collection(AppConstants.providersCollection)
        .where('isVerified', isEqualTo: true)
        .orderBy('displayName')
        .startAt([query])
        .endAt(['$query'])
        .limit(20)
        .get();
    return snapshot.docs
        .map((doc) => ProviderModel.fromFirestore(doc))
        .toList();
  }

  // ─── Bookings ────────────────────────────────────────────────────────────

  Future<String> createBooking(BookingModel booking) async {
    final ref = await _db
        .collection(AppConstants.bookingsCollection)
        .add(booking.toMap());
    return ref.id;
  }

  Future<void> updateBookingStatus(
      String bookingId, BookingStatus status) async {
    await _db
        .collection(AppConstants.bookingsCollection)
        .doc(bookingId)
        .update({
      'status': status.value,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateBooking(
      String bookingId, Map<String, dynamic> data) async {
    await _db
        .collection(AppConstants.bookingsCollection)
        .doc(bookingId)
        .update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<BookingModel>> getClientBookings(String clientId) {
    return _db
        .collection(AppConstants.bookingsCollection)
        .where('clientId', isEqualTo: clientId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BookingModel.fromFirestore(doc))
            .toList());
  }

  Stream<List<BookingModel>> getProviderBookings(String providerId) {
    return _db
        .collection(AppConstants.bookingsCollection)
        .where('providerId', isEqualTo: providerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BookingModel.fromFirestore(doc))
            .toList());
  }

  Stream<List<BookingModel>> getProviderPendingBookings(String providerId) {
    return _db
        .collection(AppConstants.bookingsCollection)
        .where('providerId', isEqualTo: providerId)
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BookingModel.fromFirestore(doc))
            .toList());
  }

  Future<BookingModel?> getBooking(String bookingId) async {
    final doc = await _db
        .collection(AppConstants.bookingsCollection)
        .doc(bookingId)
        .get();
    if (!doc.exists) return null;
    return BookingModel.fromFirestore(doc);
  }

  // ─── Reviews ─────────────────────────────────────────────────────────────

  Future<String> createReview(ReviewModel review) async {
    final ref = await _db
        .collection(AppConstants.reviewsCollection)
        .add(review.toMap());

    // Update provider rating
    await _updateProviderRating(review.providerId);

    return ref.id;
  }

  Stream<List<ReviewModel>> getProviderReviews(String providerId) {
    return _db
        .collection(AppConstants.reviewsCollection)
        .where('providerId', isEqualTo: providerId)
        .orderBy('createdAt', descending: true)
        .limit(20)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ReviewModel.fromFirestore(doc))
            .toList());
  }

  Future<void> _updateProviderRating(String providerId) async {
    final snapshot = await _db
        .collection(AppConstants.reviewsCollection)
        .where('providerId', isEqualTo: providerId)
        .get();

    if (snapshot.docs.isEmpty) return;

    final reviews =
        snapshot.docs.map((doc) => ReviewModel.fromFirestore(doc)).toList();
    final totalRating = reviews.fold<double>(0, (sum, r) => sum + r.rating);
    final avgRating = totalRating / reviews.length;

    await _db
        .collection(AppConstants.providersCollection)
        .doc(providerId)
        .update({
      'rating': avgRating,
      'totalReviews': reviews.length,
    });
  }

  // ─── Users ───────────────────────────────────────────────────────────────

  Future<UserModel?> getUser(String userId) async {
    final doc = await _db
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    await _db
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .update(data);
  }

  Future<void> incrementUserBookings(String userId) async {
    await _db
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .update({
      'totalBookings': FieldValue.increment(1),
    });
  }

  // ─── Earnings ────────────────────────────────────────────────────────────

  Future<Map<String, double>> getProviderEarnings(String providerId) async {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final weekStart = todayStart.subtract(Duration(days: now.weekday - 1));
    final monthStart = DateTime(now.year, now.month, 1);

    final allBookings = await _db
        .collection(AppConstants.bookingsCollection)
        .where('providerId', isEqualTo: providerId)
        .where('status', isEqualTo: 'completed')
        .where('paymentStatus', isEqualTo: 'paid')
        .get();

    double todayTotal = 0;
    double weekTotal = 0;
    double monthTotal = 0;
    double allTimeTotal = 0;

    for (final doc in allBookings.docs) {
      final booking = BookingModel.fromFirestore(doc);
      final amount = booking.providerAmount;
      allTimeTotal += amount;

      if (booking.date.isAfter(monthStart)) {
        monthTotal += amount;
      }
      if (booking.date.isAfter(weekStart)) {
        weekTotal += amount;
      }
      if (booking.date.isAfter(todayStart)) {
        todayTotal += amount;
      }
    }

    return {
      'today': todayTotal,
      'week': weekTotal,
      'month': monthTotal,
      'total': allTimeTotal,
    };
  }
}
