// PLACEHOLDER - Replace with actual Firebase configuration
// Run: flutterfire configure
// to generate this file automatically

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
      case TargetPlatform.macOS:
        return macos;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // Replace all values below with your actual Firebase project config
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'YOUR_WEB_API_KEY',
    appId: '1:YOUR_APP_ID:web:YOUR_WEB_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'qyzmet-kz',
    authDomain: 'qyzmet-kz.firebaseapp.com',
    storageBucket: 'qyzmet-kz.appspot.com',
    measurementId: 'G-YOUR_MEASUREMENT_ID',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR_ANDROID_API_KEY',
    appId: '1:YOUR_APP_ID:android:YOUR_ANDROID_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'qyzmet-kz',
    storageBucket: 'qyzmet-kz.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY',
    appId: '1:YOUR_APP_ID:ios:YOUR_IOS_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'qyzmet-kz',
    storageBucket: 'qyzmet-kz.appspot.com',
    iosClientId: 'YOUR_IOS_CLIENT_ID',
    iosBundleId: 'kz.qyzmet.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'YOUR_MACOS_API_KEY',
    appId: '1:YOUR_APP_ID:macos:YOUR_MACOS_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'qyzmet-kz',
    storageBucket: 'qyzmet-kz.appspot.com',
    iosClientId: 'YOUR_MACOS_CLIENT_ID',
    iosBundleId: 'kz.qyzmet.app',
  );
}
