import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../config/app_constants.dart';

final storageServiceProvider =
    Provider<StorageService>((ref) => StorageService());

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  Future<String?> uploadUserAvatar(String userId, File file) async {
    final ref = _storage
        .ref()
        .child(AppConstants.avatarsPath)
        .child('$userId.jpg');

    final uploadTask = await ref.putFile(
      file,
      SettableMetadata(contentType: 'image/jpeg'),
    );

    return await uploadTask.ref.getDownloadURL();
  }

  Future<String?> uploadProviderPhoto(
      String providerId, File file, int index) async {
    final ref = _storage
        .ref()
        .child(AppConstants.providersPath)
        .child(providerId)
        .child('photo_$index.jpg');

    final uploadTask = await ref.putFile(
      file,
      SettableMetadata(contentType: 'image/jpeg'),
    );

    return await uploadTask.ref.getDownloadURL();
  }

  Future<String?> uploadIdDocument(String providerId, File file) async {
    final ref = _storage
        .ref()
        .child(AppConstants.documentsPath)
        .child('$providerId.jpg');

    final uploadTask = await ref.putFile(
      file,
      SettableMetadata(contentType: 'image/jpeg'),
    );

    return await uploadTask.ref.getDownloadURL();
  }

  Future<File?> pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (image == null) return null;
    return File(image.path);
  }

  Future<File?> pickImageFromCamera() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (image == null) return null;
    return File(image.path);
  }

  Future<void> deleteFile(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (_) {}
  }
}
