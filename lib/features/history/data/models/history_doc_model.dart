import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../quick_check/domain/entities/verification_result.dart';
import '../../domain/entities/history_entry.dart';

/// Mapping dokumen Firestore ke entity riwayat, tanpa API/UI dependency.
class HistoryDocModel {
  const HistoryDocModel._();

  static HistoryEntry fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    return fromMap(doc.id, doc.data() ?? const <String, dynamic>{});
  }

  /// Versi murni-map agar unit test tidak perlu mock DocumentSnapshot.
  static HistoryEntry fromMap(String id, Map<String, dynamic> data) {
    final source = switch (data['source']) {
      'image' => VerificationSource.image,
      'url' => VerificationSource.url,
      _ => VerificationSource.text,
    };
    final verdict = switch (data['verdict']) {
      'HOAKS' => Verdict.hoaks,
      'VALID' => Verdict.valid,
      'PERLU_DICEK' => Verdict.perluDicek,
      _ => Verdict.tidakDapatDipastikan,
    };
    final checkedAt = DateTime.tryParse(data['checkedAt']?.toString() ?? '');
    return HistoryEntry(
      id: id,
      result: VerificationResult(
        claim: data['claim']?.toString() ?? '',
        verdict: verdict,
        confidence: (data['confidence'] as num?)?.round() ?? 0,
        explanation: data['explanation']?.toString() ?? '',
        suggestion: data['suggestion']?.toString() ?? '',
        checkedAt: checkedAt ?? DateTime.fromMillisecondsSinceEpoch(0),
        source: source,
        imageFileName: data['imageFileName']?.toString(),
        sourceUrl: data['sourceUrl']?.toString(),
        sourceTitle: data['sourceTitle']?.toString(),
      ),
    );
  }

  static Map<String, dynamic> toDocument(VerificationResult result) => {
    'claim': result.claim,
    'verdict': result.verdict.jsonValue,
    'confidence': result.confidence,
    'explanation': result.explanation,
    'suggestion': result.suggestion,
    'checkedAt': result.checkedAt.toUtc().toIso8601String(),
    'source': result.source.name,
    if (result.imageFileName != null) 'imageFileName': result.imageFileName,
    if (result.sourceUrl != null) 'sourceUrl': result.sourceUrl,
    if (result.sourceTitle != null) 'sourceTitle': result.sourceTitle,
  };
}
