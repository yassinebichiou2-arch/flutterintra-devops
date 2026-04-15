import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
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
    apiKey: 'AIzaSyBbqlRY2qgo__GLHLRfuxODm7Jjgy8JDOw',
    appId: '1:520960517929:web:0f574068cf48e20feab938',
    messagingSenderId: '520960517929',
    projectId: 'flutterintra-ba903',
    authDomain: 'flutterintra-ba903.firebaseapp.com',
    storageBucket: 'flutterintra-ba903.firebasestorage.app',
    measurementId: 'G-40KRCMR62N',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBbqlRY2qgo__GLHLRfuxODm7Jjgy8JDOw',
    appId: '1:520960517929:android:0f574068cf48e20feab938',
    messagingSenderId: '520960517929',
    projectId: 'flutterintra-ba903',
    storageBucket: 'flutterintra-ba903.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBbqlRY2qgo__GLHLRfuxODm7Jjgy8JDOw',
    appId: '1:520960517929:ios:0f574068cf48e20feab938',
    messagingSenderId: '520960517929',
    projectId: 'flutterintra-ba903',
    storageBucket: 'flutterintra-ba903.firebasestorage.app',
    iosBundleId: 'com.example.devmob',
  );
}
