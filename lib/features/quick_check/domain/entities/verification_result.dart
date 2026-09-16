/// Hasil verifikasi klaim teks — domain murni, tanpa dependensi Flutter.
enum Verdict {
  hoaks,
  valid,
  perluDicek,
  tidakDapatDipastikan;

  /// Label Indonesia sesuai PRD §4.1.
  String get label => switch (this) {
    Verdict.hoaks => 'HOAKS',
    Verdict.valid => 'VALID',
    Verdict.perluDicek => 'PERLU DICEK',
    Verdict.tidakDapatDipastikan => 'TIDAK DAPAT DIPASTIKAN',
  };

  /// Nilai JSON yang dipakai kontrak Gemini ↔ model.
  String get jsonValue => switch (this) {
    Verdict.hoaks => 'HOAKS',
    Verdict.valid => 'VALID',
    Verdict.perluDicek => 'PERLU_DICEK',
    Verdict.tidakDapatDipastikan => 'TIDAK_DAPAT_DIPASTIKAN',
  };
}

/// Sumber bukti yang diverifikasi.
enum VerificationSource { text, image, url }

/// Hasil verifikasi satu klaim teks, gambar, atau link artikel.
class VerificationResult {
  const VerificationResult({
    required this.claim,
    required this.verdict,
    required this.confidence,
    required this.explanation,
    required this.suggestion,
    required this.checkedAt,
    this.source = VerificationSource.text,
    this.imageFileName,
    this.sourceUrl,
    this.sourceTitle,
  });

  final String claim;
  final Verdict verdict;

  /// Skor 0–100.
  final int confidence;
  final String explanation;
  final String suggestion;
  final DateTime checkedAt;
  final VerificationSource source;
  final String? imageFileName;

  /// Link artikel asli untuk mode URL.
  final String? sourceUrl;

  /// Judul artikel hasil fetch untuk mode URL.
  final String? sourceTitle;

  /// Hasil aman saat model tidak dapat memastikan — tetap sukses, bukan error.
  factory VerificationResult.uncertain(
    String claim, {
    String explanation =
        'Model tidak memiliki cukup bukti untuk memastikan klaim ini.',
    String suggestion =
        'Bandingkan dengan sumber resmi seperti TurnBackHoax atau media arus utama.',
    DateTime? checkedAt,
    VerificationSource source = VerificationSource.text,
    String? imageFileName,
    String? sourceUrl,
    String? sourceTitle,
  }) {
    return VerificationResult(
      claim: claim,
      verdict: Verdict.tidakDapatDipastikan,
      confidence: 0,
      explanation: explanation,
      suggestion: suggestion,
      checkedAt: checkedAt ?? DateTime.now(),
      source: source,
      imageFileName: imageFileName,
      sourceUrl: sourceUrl,
      sourceTitle: sourceTitle,
    );
  }
}
