import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return const FirebaseOptions(
      apiKey: 'AIzaSyDQqaq2IUq2IU3xYlfH77db5BFiZIIBfA0',
      appId: '1:335083381643:android:592d0ce8945d6786fa458e',
      messagingSenderId: '335083381643',
      projectId: 'watch-and-earn-pro-b608e',
      storageBucket: 'watch-and-earn-pro-b608e.appspot.com',
    );
  }
}
