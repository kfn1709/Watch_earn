import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
class FirebaseService {
  static Future<void> addGold(int points) async {
    String uid = FirebaseAuth.instance.currentUser?.uid ?? "test_user";
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'points': FieldValue.increment(points),
      'lastUpdate': DateTime.now(),
    }, SetOptions(merge: true));
  }
}
