import 'web_google_auth_stub.dart'
    if (dart.library.js_interop) 'web_google_auth_web.dart'
    if (dart.library.js) 'web_google_auth_web.dart'
    if (dart.library.html) 'web_google_auth_web.dart';

abstract class WebGoogleAuth {
  static Future<Map<String, String>?> triggerGooglePopup() =>
      WebGoogleAuthPlatform.triggerGooglePopup();

  static Future<Map<String, String>?> getFirebaseCurrentUser() =>
      WebGoogleAuthPlatform.getFirebaseCurrentUser();

  static Future<void> signOutWeb() =>
      WebGoogleAuthPlatform.signOutWeb();

  static Future<bool> setFirestoreDoc(String collectionName, String docId, String jsonString) =>
      WebGoogleAuthPlatform.setFirestoreDoc(collectionName, docId, jsonString);

  static Future<String?> getFirestoreDoc(String collectionName, String docId) =>
      WebGoogleAuthPlatform.getFirestoreDoc(collectionName, docId);
}
