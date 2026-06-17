import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with [Firebase.initializeApp].
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
        return ios;
      case TargetPlatform.windows:
        return windows;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'placeholder-web-api-key',
    appId: '1:1234567890:web:1234567890',
    messagingSenderId: '1234567890',
    projectId: 'worth-wealth-os',
    authDomain: 'worth-wealth-os.firebaseapp.com',
    storageBucket: 'worth-wealth-os.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCNBVAxLDCzzBSLLg3A4TFqQ6wr-6I-OUo',
    appId: '1:478137199876:android:725573a623c1170f493451',
    messagingSenderId: '478137199876',
    projectId: 'worth-app-alokk',
    storageBucket: 'worth-app-alokk.firebasestorage.app',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'placeholder-ios-api-key',
    appId: '1:1234567890:ios:1234567890',
    messagingSenderId: '1234567890',
    projectId: 'worth-wealth-os',
    storageBucket: 'worth-wealth-os.appspot.com',
    iosBundleId: 'com.example.worth',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'placeholder-windows-api-key',
    appId: '1:1234567890:windows:1234567890',
    messagingSenderId: '1234567890',
    projectId: 'worth-wealth-os',
    storageBucket: 'worth-wealth-os.appspot.com',
  );
}
