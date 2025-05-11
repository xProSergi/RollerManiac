import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
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
        throw UnsupportedError('FirebaseOptions no configurado para Linux.');
      default:
        throw UnsupportedError('Plataforma no soportada.');
    }
  }

  static const _url = 'https://rollermaniac-a54df-default-rtdb.europe-west1.firebasedatabase.app';
  static const _bucket = 'rollermaniac-a54df.appspot.com';

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAq431CWuM-mYzIqsUBcfSfJwTR5nkZhQ0',
    appId: '1:205515140357:web:885cf49dbe79f1710a5b6c',
    messagingSenderId: '205515140357',
    projectId: 'rollermaniac-a54df',
    authDomain: 'rollermaniac-a54df.firebaseapp.com',
    storageBucket: _bucket,
    measurementId: 'G-DXQZ1JXLZP',
    databaseURL: _url,
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCYz9YZrZ9y_RMXWdis91zBuoi5ZqdfhwM',
    appId: '1:205515140357:android:6fa8bd1e39bf66180a5b6c',
    messagingSenderId: '205515140357',
    projectId: 'rollermaniac-a54df',
    storageBucket: _bucket,
    databaseURL: _url,
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAu2NbOawCzUOGmU-24rUnyC1_PtfQ6Xns',
    appId: '1:205515140357:ios:ed33b36b37c38e350a5b6c',
    messagingSenderId: '205515140357',
    projectId: 'rollermaniac-a54df',
    storageBucket: _bucket,
    iosBundleId: 'com.example.sergioRollermaniac',
    databaseURL: _url,
  );

  static const FirebaseOptions macos = ios;

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAq431CWuM-mYzIqsUBcfSfJwTR5nkZhQ0',
    appId: '1:205515140357:web:2d8c3451e593988d0a5b6c',
    messagingSenderId: '205515140357',
    projectId: 'rollermaniac-a54df',
    authDomain: 'rollermaniac-a54df.firebaseapp.com',
    storageBucket: _bucket,
    measurementId: 'G-PV7EGBBJW1',
    databaseURL: _url,
  );
}
