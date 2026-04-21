import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../utils/helpers.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? get _userId => FirebaseAuth.instance.currentUser?.uid;

  // ==================== دوال المستخدم ====================

  Future<UserModel?> getUser() async {
    if (_userId == null) return null;

    return await Helpers.retry(
      action: () async {
        final doc = await Helpers.withTimeout(
          action: () => _firestore.collection('users').doc(_userId).get(),
          timeout: const Duration(seconds: 10),
        );
        if (!doc.exists) return null;
        return UserModel.fromJson(doc.data()!);
      },
      maxAttempts: 3,
      delayBetween: const Duration(seconds: 1),
    );
  }

  Stream<DocumentSnapshot> streamUser() {
    return _firestore.collection('users').doc(_userId).snapshots();
  }

  Future<void> updatePoints(int points) async {
    if (_userId == null) return;

    await Helpers.retry(
      action: () => _firestore
          .collection('users')
          .doc(_userId)
          .update({'points': points}),
      maxAttempts: 3,
    );
  }

  Future<void> updateUser(Map<String, dynamic> data) async {
    if (_userId == null) return;

    await Helpers.retry(
      action: () => _firestore.collection('users').doc(_userId).update(data),
      maxAttempts: 3,
    );
  }

  // ==================== دوال الأرباح ====================

  Future<void> addEarning(int points) async {
    if (_userId == null) return;

    await Helpers.retry(
      action: () => _firestore
          .collection('users')
          .doc(_userId)
          .collection('earnings')
          .add({
        'points': points,
        'timestamp': FieldValue.serverTimestamp(),
      }),
      maxAttempts: 3,
    );
  }

  Stream<QuerySnapshot> streamEarnings() {
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('earnings')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // ==================== دوال السحوبات ====================

  Future<void> addWithdrawal(Map<String, dynamic> withdrawal) async {
    if (_userId == null) return;

    await Helpers.retry(
      action: () => _firestore
          .collection('users')
          .doc(_userId)
          .collection('withdrawals')
          .add(withdrawal),
      maxAttempts: 3,
    );
  }

  Stream<QuerySnapshot> streamWithdrawals() {
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('withdrawals')
        .orderBy('requestDate', descending: true)
        .snapshots();
  }

  // ==================== دوال التحقق ====================

  Future<Map<String, dynamic>?> getUserData() async {
    if (_userId == null) return null;

    final results = await Helpers.parallel([
      () => _firestore.collection('users').doc(_userId).get(),
      () => _firestore
          .collection('users')
          .doc(_userId)
          .collection('earnings')
          .limit(5)
          .get(),
      () => _firestore
          .collection('users')
          .doc(_userId)
          .collection('withdrawals')
          .limit(5)
          .get(),
    ]);

    return {
      'user': results[0].data(),
      'recentEarnings': results[1].docs,
      'recentWithdrawals': results[2].docs,
    };
  }
}
