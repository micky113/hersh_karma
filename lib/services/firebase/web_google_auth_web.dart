// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:async';
import 'dart:js_util' as js_util;
import 'dart:html' as html;

class WebGoogleAuthPlatform {
  static Future<Map<String, String>?> triggerGooglePopup() async {
    try {
      final promise = js_util.callMethod(html.window, 'signInWithGooglePopup', []);
      final result = await js_util.promiseToFuture<dynamic>(promise);

      if (result != null) {
        final email = js_util.getProperty(result, 'email')?.toString() ?? '';
        final displayName = js_util.getProperty(result, 'displayName')?.toString() ?? '';
        final uid = js_util.getProperty(result, 'uid')?.toString() ?? '';
        final photoURL = js_util.getProperty(result, 'photoURL')?.toString() ?? '';

        return {
          'email': email,
          'displayName': displayName,
          'uid': uid,
          'photoURL': photoURL,
        };
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, String>?> getFirebaseCurrentUser() async {
    try {
      final promise = js_util.callMethod(html.window, 'getFirebaseCurrentUser', []);
      final result = await js_util.promiseToFuture<dynamic>(promise);

      if (result != null) {
        final email = js_util.getProperty(result, 'email')?.toString() ?? '';
        final displayName = js_util.getProperty(result, 'displayName')?.toString() ?? '';
        final uid = js_util.getProperty(result, 'uid')?.toString() ?? '';
        final photoURL = js_util.getProperty(result, 'photoURL')?.toString() ?? '';

        if (email.isNotEmpty) {
          return {
            'email': email,
            'displayName': displayName,
            'uid': uid,
            'photoURL': photoURL,
          };
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<void> signOutWeb() async {
    try {
      final promise = js_util.callMethod(html.window, 'signOutFirebaseUser', []);
      await js_util.promiseToFuture<dynamic>(promise);
    } catch (_) {}
  }
}
