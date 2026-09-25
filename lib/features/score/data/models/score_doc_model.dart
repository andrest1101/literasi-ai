import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/literacy_score.dart';

/// Mapping dokumen skor: toleran terhadap dokumen hilang/korup.
///
/// Field non-angka atau negatif dinormalisasi ke 0; `modulesDone` non-list
/// diabaikan. Versi map-murni tersedia agar unit test tidak perlu mock
/// `DocumentSnapshot`.
class ScoreDocModel {
  const ScoreDocModel._();

  static LiteracyScore fromDocument(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    return fromMap(doc.data() ?? const <String, dynamic>{});
  }

  static LiteracyScore fromMap(Map<String, dynamic> data) {
    final modules = data['modulesDone'];
    return LiteracyScore(
      verifications: _nonNegativeInt(data['verifications']),
      modulesDone: modules is List
          ? modules
                .map((e) => e?.toString() ?? '')
                .where((e) => e.isNotEmpty)
                .toList(growable: false)
          : const [],
      quizCorrect: _nonNegativeInt(data['quizCorrect']),
    );
  }

  static int _nonNegativeInt(Object? value) {
    final parsed = value is num ? value.toInt() : 0;
    return parsed < 0 ? 0 : parsed;
  }
}
