// lib/services/storage_service.dart

import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class StorageService {
  FirebaseStorage get _storage => FirebaseStorage.instance;

  /// Uploads a profile photo and returns the download URL.
  Future<String> uploadProfilePhoto(String uid, File file) async {
    try {
      final ref = _storage.ref().child('profiles').child('$uid.jpg');
      final uploadTask = await ref.putFile(file);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      debugPrint('Storage Error: $e');
      return '';
    }
  }

  /// Uploads a case document/photo and returns the download URL.
  Future<String> uploadCaseDocument(String caseId, String fileName, File file) async {
    try {
      final ref = _storage.ref().child('cases').child(caseId).child(fileName);
      final uploadTask = await ref.putFile(file);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      debugPrint('Storage Error: $e');
      return '';
    }
  }

  /// Registration identity images — `users/{uid}/id_card.jpg` or `selfie.jpg`.
  Future<String> uploadUserRegistrationImage({
    required String uid,
    required String fileName,
    required XFile file,
  }) async {
    try {
      final ref = _storage.ref().child('users').child(uid).child(fileName);
      final bytes = await file.readAsBytes();
      final uploadTask = await ref.putData(
        bytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      debugPrint('StorageService.uploadUserRegistrationImage failed: $e');
      rethrow;
    }
  }
}
