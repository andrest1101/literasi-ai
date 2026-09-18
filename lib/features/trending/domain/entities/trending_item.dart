import '../../../quick_check/domain/entities/verification_result.dart';

/// Satu hoaks trending — konten curated lokal, murni Dart.
///
/// Ditulis manual Bahasa Indonesia natural + rujukan TurnBackHoax agar tidak
/// terasa template generik. API Kominfo menyusul; fase ini offline-first agar
/// guest tanpa koneksi tetap melihat feed.
class TrendingItem {
  const TrendingItem({
    required this.id,
    required this.title,
    required this.summary,
    required this.verdict,
    required this.confidence,
    required this.category,
    required this.isHot,
    required this.checkedAt,
    required this.reference,
  });

  final String id;
  final String title;
  final String summary;
  final Verdict verdict;
  final int confidence;
  final String category;
  final bool isHot;
  final DateTime checkedAt;
  final String reference;

  /// Konversi ke hasil verifikasi agar detail reuse kartu hasil + share.
  VerificationResult toResult() {
    return VerificationResult(
      claim: title,
      verdict: verdict,
      confidence: confidence,
      explanation: summary,
      suggestion:
          'Bandingkan dengan $reference dan media arus utama sebelum menyebarkan.',
      checkedAt: checkedAt,
      source: VerificationSource.text,
    );
  }
}
