import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_model.dart';
import '../../config/app_constants.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

final currentUserProvider = StreamProvider<UserModel?>((ref) {
  final auth = ref.watch(authServiceProvider);
  return auth.currentUserStream;
});

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Stream<UserModel?> get currentUserStream {
    return _auth.authStateChanges().asyncExpand((user) {
      if (user == null) return Stream.value(null);
      return _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .snapshots()
          .map((doc) =>
              doc.exists ? UserModel.fromFirestore(doc) : null);
    });
  }

  Future<UserModel?> getCurrentUserModel() async {
    final user = currentUser;
    if (user == null) return null;
    final doc = await _firestore
        .collection(AppConstants.usersCollection)
        .doc(user.uid)
        .get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user!;
    return await _getOrCreateUserModel(user);
  }

  Future<UserModel> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
    required String role,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user!;
    await user.updateDisplayName(displayName);

    final userModel = UserModel(
      uid: user.uid,
      email: email,
      displayName: displayName,
      role: role,
      createdAt: DateTime.now(),
    );

    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(user.uid)
        .set(userModel.toMap());

    return userModel;
  }

  Future<UserModel> signInWithGoogle({String role = 'client'}) async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) throw Exception('Google sign in cancelled');

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await _auth.signInWithCredential(credential);
    final user = userCredential.user!;
    return await _getOrCreateUserModel(user, role: role);
  }

  Future<String> verifyPhoneNumber(String phoneNumber) async {
    String verificationId = '';

    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        throw e;
      },
      codeSent: (String id, int? resendToken) {
        verificationId = id;
      },
      codeAutoRetrievalTimeout: (String id) {
        verificationId = id;
      },
      timeout: const Duration(seconds: 60),
    );

    return verificationId;
  }

  Future<UserModel> verifyOtp({
    required String verificationId,
    required String smsCode,
    String role = 'client',
  }) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    final userCredential = await _auth.signInWithCredential(credential);
    final user = userCredential.user!;
    return await _getOrCreateUserModel(user, role: role);
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  Future<void> updateFcmToken(String token) async {
    final user = currentUser;
    if (user == null) return;
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(user.uid)
        .update({'fcmToken': token});
  }

  Future<void> updateUserProfile({
    String? displayName,
    String? photoURL,
    String? phoneNumber,
    String? preferredLanguage,
  }) async {
    final user = currentUser;
    if (user == null) return;

    final updates = <String, dynamic>{};
    if (displayName != null) {
      updates['displayName'] = displayName;
      await user.updateDisplayName(displayName);
    }
    if (photoURL != null) {
      updates['photoURL'] = photoURL;
      await user.updatePhotoURL(photoURL);
    }
    if (phoneNumber != null) updates['phoneNumber'] = phoneNumber;
    if (preferredLanguage != null) {
      updates['preferredLanguage'] = preferredLanguage;
    }

    if (updates.isNotEmpty) {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .update(updates);
    }
  }

  Future<UserModel> _getOrCreateUserModel(User user,
      {String role = 'client'}) async {
    final doc = await _firestore
        .collection(AppConstants.usersCollection)
        .doc(user.uid)
        .get();

    if (doc.exists) {
      return UserModel.fromFirestore(doc);
    }

    final userModel = UserModel(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName ?? '',
      photoURL: user.photoURL ?? '',
      phoneNumber: user.phoneNumber ?? '',
      role: role,
      createdAt: DateTime.now(),
    );

    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(user.uid)
        .set(userModel.toMap());

    return userModel;
  }
}

