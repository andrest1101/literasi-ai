import 'package:cloud_firestore/cloud_firestore.dart';

/// Akses Firestore terisolasi untuk dokumen skor per pengguna.
///
/// Dokumen `users/{uid}/score/summary` memakai increment atomik agar dua
/// verifikasi berurutan tidak saling menimpa. `modulesDone` disimpan sebagai
/// array id modul; klaim ganda modul yang sama diabaikan di sisi client
/// sebelum transaksi agar tidak boros write.
class ScoreRemoteDatasource {
  ScoreRemoteDatasource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _doc(String userId) => _firestore
      .collection('users')
      .doc(userId)
      .collection('score')
      .doc('summary');

  Stream<DocumentSnapshot<Map<String, dynamic>>> watch(String userId) =>
      _doc(userId).snapshots();

  Future<void> awardVerification(String userId) => _doc(userId).set({
    'verifications': FieldValue.increment(1),
    'updatedAt': FieldValue.serverTimestamp(),
  }, SetOptions(merge: true));

  Future<void> awardModule(String userId, String moduleId) => _doc(userId).set({
    'modulesDone': FieldValue.arrayUnion([moduleId]),
    'updatedAt': FieldValue.serverTimestamp(),
  }, SetOptions(merge: true));

  Future<void> awardQuiz(String userId, {required bool correct}) {
    if (!correct) return Future.value();
    return _doc(userId).set({
      'quizCorrect': FieldValue.increment(1),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
