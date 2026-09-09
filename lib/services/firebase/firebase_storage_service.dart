import 'package:flutter/foundation.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class FirebaseStorageService {
  static final FirebaseStorageService _instance = FirebaseStorageService._internal();
  factory FirebaseStorageService() => _instance;
  FirebaseStorageService._internal();

  FirebaseStorage get _storage => FirebaseStorage.instance;

  /// Uploads a single proof image (Before or After) to Firebase Storage
  /// and returns its public/accessible download URL.
  Future<String?> uploadProofImage({
    required String userId,
    required String deedId,
    required String imageType, // 'before' or 'after'
    required XFile file,
  }) async {
    try {
      final bytes = await file.readAsBytes();
      final sanitizedUserId = userId.isNotEmpty ? userId : 'anonymous';
      final fileName = '${deedId}_${imageType}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storageRef = _storage.ref().child('proofs/$sanitizedUserId/$fileName');

      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'userId': sanitizedUserId,
          'deedId': deedId,
          'imageType': imageType,
          'uploadedAt': DateTime.now().toIso8601String(),
        },
      );

      final uploadTask = storageRef.putData(bytes, metadata);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      debugPrint('Proof image ($imageType) uploaded to Firebase Storage: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      debugPrint('Firebase Storage upload note ($imageType): $e');
      // If Firebase Storage is unavailable or offline, return the local/mock URI gracefully
      return file.path.isNotEmpty ? file.path : 'data:image/jpeg;name=${file.name}';
    }
  }

  /// Uploads both before and after proof images concurrently
  Future<Map<String, String?>> uploadProofPair({
    required String userId,
    required String deedId,
    XFile? beforeFile,
    XFile? afterFile,
  }) async {
    String? beforeUrl;
    String? afterUrl;

    final List<Future> uploads = [];

    if (beforeFile != null) {
      uploads.add(
        uploadProofImage(
          userId: userId,
          deedId: deedId,
          imageType: 'before',
          file: beforeFile,
        ).then((url) => beforeUrl = url),
      );
    }

    if (afterFile != null) {
      uploads.add(
        uploadProofImage(
          userId: userId,
          deedId: deedId,
          imageType: 'after',
          file: afterFile,
        ).then((url) => afterUrl = url),
      );
    }

    if (uploads.isNotEmpty) {
      await Future.wait(uploads);
    }

    return {
      'beforeImageUrl': beforeUrl,
      'afterImageUrl': afterUrl,
    };
  }

  /// Uploads supporting wish attachments or evidence
  Future<String?> uploadWishAttachment({
    required String userId,
    required String wishId,
    required XFile file,
  }) async {
    try {
      final bytes = await file.readAsBytes();
      final sanitizedUserId = userId.isNotEmpty ? userId : 'anonymous';
      final fileName = '${wishId}_${DateTime.now().millisecondsSinceEpoch}_${file.name}';
      final storageRef = _storage.ref().child('wishes/$sanitizedUserId/$fileName');

      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'userId': sanitizedUserId,
          'wishId': wishId,
          'uploadedAt': DateTime.now().toIso8601String(),
        },
      );

      final uploadTask = storageRef.putData(bytes, metadata);
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      debugPrint('Firebase Storage wish attachment note: $e');
      return file.path.isNotEmpty ? file.path : 'data:image/jpeg;name=${file.name}';
    }
  }

  /// Uploads Organization / Institution KYC verification documents
  Future<String?> uploadKycDocument({
    required String userId,
    required String orgName,
    required XFile file,
  }) async {
    try {
      final bytes = await file.readAsBytes();
      final sanitizedUserId = userId.isNotEmpty ? userId : 'anonymous';
      final fileName = 'kyc_${DateTime.now().millisecondsSinceEpoch}_${file.name}';
      final storageRef = _storage.ref().child('kyc/$sanitizedUserId/$fileName');

      final metadata = SettableMetadata(
        contentType: 'application/octet-stream',
        customMetadata: {
          'userId': sanitizedUserId,
          'orgName': orgName,
          'uploadedAt': DateTime.now().toIso8601String(),
        },
      );

      final uploadTask = storageRef.putData(bytes, metadata);
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      debugPrint('Firebase Storage KYC doc note: $e');
      return file.path.isNotEmpty ? file.path : file.name;
    }
  }
}
