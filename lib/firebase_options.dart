// lib/firebase_options.dart
// ─────────────────────────────────────────────────────────────────────────────
// SETUP INSTRUCTIONS:
// 1. Go to https://console.firebase.google.com
// 2. Create a new project: "career-roadmap-pk"
// 3. Add Android + iOS + Web apps
// 4. Run: flutterfire configure
//    This command auto-generates this file with your real credentials.
//
// The placeholder values below will be replaced by flutterfire configure.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android: return android;
      case TargetPlatform.iOS:     return ios;
      default:
        throw UnsupportedError('Unsupported platform');
    }
  }

  // ── Replace with your real Firebase config values ──────────────────────────
  static const FirebaseOptions web = FirebaseOptions(
    apiKey:            'YOUR_API_KEY',
    appId:             'YOUR_WEB_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId:         'career-roadmap-pk',
    authDomain:        'career-roadmap-pk.firebaseapp.com',
    storageBucket:     'career-roadmap-pk.appspot.com',
    measurementId:     'YOUR_MEASUREMENT_ID',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey:            'YOUR_ANDROID_API_KEY',
    appId:             'YOUR_ANDROID_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId:         'career-roadmap-pk',
    storageBucket:     'career-roadmap-pk.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey:            'YOUR_IOS_API_KEY',
    appId:             'YOUR_IOS_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId:         'career-roadmap-pk',
    storageBucket:     'career-roadmap-pk.appspot.com',
    iosBundleId:       'com.yourname.careerRoadmap',
  );
}
