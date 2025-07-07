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
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAQmbv4XL41giy2blYH2L9xwaNnaAFbPcU',
    appId: '1:508208800323:web:38e74c8ee6b708e226eaf6',
    messagingSenderId: '508208800323',
    projectId: 'cjls-money',
    authDomain: 'cjls-money.firebaseapp.com',
    storageBucket: 'cjls-money.firebasestorage.app',
    measurementId: 'G-RPJLDP8M9J',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBYblbo1IeBXhecX9OF_6YLF-vM2kaovmc',
    appId: '1:508208800323:android:d5773cd9f1d2052b26eaf6',
    messagingSenderId: '508208800323',
    projectId: 'cjls-money',
    storageBucket: 'cjls-money.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCyBOq-AwPh9DD4wvO4_lidY3rSNuT68ds',
    appId: '1:508208800323:ios:2f9c285bbbb98ecd26eaf6',
    messagingSenderId: '508208800323',
    projectId: 'cjls-money',
    storageBucket: 'cjls-money.firebasestorage.app',
    iosBundleId: 'com.example.money',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCyBOq-AwPh9DD4wvO4_lidY3rSNuT68ds',
    appId: '1:508208800323:ios:2f9c285bbbb98ecd26eaf6',
    messagingSenderId: '508208800323',
    projectId: 'cjls-money',
    storageBucket: 'cjls-money.firebasestorage.app',
    iosBundleId: 'com.example.money',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAQmbv4XL41giy2blYH2L9xwaNnaAFbPcU',
    appId: '1:508208800323:web:caa273b9d21b529526eaf6',
    messagingSenderId: '508208800323',
    projectId: 'cjls-money',
    authDomain: 'cjls-money.firebaseapp.com',
    storageBucket: 'cjls-money.firebasestorage.app',
    measurementId: 'G-CS42PQSMPK',
  );
}