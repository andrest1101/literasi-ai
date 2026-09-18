import 'package:cloud_firestore/cloud_firestore.dart';

/// Progres belajar per pengguna di Firestore.
///
/// Dokumen `users/{uid}/learn/progress`: `completedModules` array id modul
/// (arrayUnion idempoten), `quizBest` map modul ke skor terbaik. Skor terbaik
/// mencegah farming poin dengan mengulang kuis berkali-kali.
class LearnRemoteDatasource {
  LearnRemoteDatasource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _doc(String userId) => _firestore
      .collection('users')
      .doc(userId)
      .collection('learn')
      .doc('progress');

  Stream<DocumentSnapshot<Map<String, dynamic>>> watch(String userId) =>
      _doc(userId).snapshots();

  Future<void> completeModule(String userId, String moduleId) =>
      _doc(userId).set({
        'completedModules': FieldValue.arrayUnion([moduleId]),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

  Future<void> submitQuizBest(String userId, String moduleId, int best) =>
      _doc(userId).set({
        'quizBest.$moduleId': best,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
}
