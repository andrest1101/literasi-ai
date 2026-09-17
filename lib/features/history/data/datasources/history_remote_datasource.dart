import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../quick_check/domain/entities/verification_result.dart';
import '../models/history_doc_model.dart';

/// Akses Firestore terisolasi untuk koleksi riwayat per pengguna.
class HistoryRemoteDatasource {
  HistoryRemoteDatasource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _collection(String userId) =>
      _firestore.collection('users').doc(userId).collection('verifications');

  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> watch(String userId) =>
      _collection(userId)
          .orderBy('checkedAt', descending: true)
          .limit(50)
          .snapshots()
          .map((snapshot) => snapshot.docs);

  Future<void> save({required String userId, required VerificationResult result}) =>
      _collection(userId).add(HistoryDocModel.toDocument(result));

  Future<void> delete({required String userId, required String entryId}) =>
      _collection(userId).doc(entryId).delete();
}
