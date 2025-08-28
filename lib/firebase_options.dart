// ignore_for_file: type=lint
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
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for this platform.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // ✅ Web configuration
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyDRdN2getpNWHAoqy38l4jxCcrvjTuEkKU",
    authDomain: "datastore-b0b2e.firebaseapp.com",
    projectId: "datastore-b0b2e",
    storageBucket: "datastore-b0b2e.appspot.com",
    messagingSenderId: "551038864847",
    appId: "1:551038864847:web:e8c8e10624b6e8002216ba",
  );

  // ✅ Android configuration (manually added)
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: "AIzaSyDRdN2getpNWHAoqy38l4jxCcrvjTuEkKU",
    appId: "1:551038864847:android:e8c8e10624b6e8002216ba",
    messagingSenderId: "551038864847",
    projectId: "datastore-b0b2e",
    storageBucket: "datastore-b0b2e.appspot.com",
  );
}
