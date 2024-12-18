// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyA_qm8LuUdqtEgvy93swjFFeab4fSddB-k',
    appId: '1:1026146951416:web:c49c300590ee153ee1db0d',
    messagingSenderId: '1026146951416',
    projectId: 'vision-9fe56',
    authDomain: 'vision-9fe56.firebaseapp.com',
    databaseURL: 'https://vision-9fe56-default-rtdb.firebaseio.com',
    storageBucket: 'vision-9fe56.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCJOuJgGLWvn5OqCqSS7udmxvSdz1HkBoE',
    appId: '1:1026146951416:android:9fb891836a74e878e1db0d',
    messagingSenderId: '1026146951416',
    projectId: 'vision-9fe56',
    databaseURL: 'https://vision-9fe56-default-rtdb.firebaseio.com',
    storageBucket: 'vision-9fe56.appspot.com',
  );
}
