import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCNxbnliCxMk2cKtzobIWyLHppEBIMmPro',
    appId: '1:341148406350:web:0d8e5bb68b7a38d7e8a91f',
    messagingSenderId: '341148406350',
    projectId: 'hersh-karma',
    authDomain: 'hersh-karma.firebaseapp.com',
    storageBucket: 'hersh-karma.firebasestorage.app',
    measurementId: 'G-LNR0V3QCEM',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCNxbnliCxMk2cKtzobIWyLHppEBIMmPro',
    appId: '1:341148406350:web:0d8e5bb68b7a38d7e8a91f',
    messagingSenderId: '341148406350',
    projectId: 'hersh-karma',
    storageBucket: 'hersh-karma.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCNxbnliCxMk2cKtzobIWyLHppEBIMmPro',
    appId: '1:341148406350:web:0d8e5bb68b7a38d7e8a91f',
    messagingSenderId: '341148406350',
    projectId: 'hersh-karma',
    storageBucket: 'hersh-karma.firebasestorage.app',
    iosBundleId: 'com.hersh.karma',
  );
}
