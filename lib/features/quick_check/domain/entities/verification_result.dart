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
    this.isDemo = false,
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

  /// True bila hasil berasal dari mode demo offline (tanpa kunci API).
  /// UI memakai ini untuk badge DEMO, bukan menebak dari teks penjelasan.
  final bool isDemo;
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
    bool isDemo = false,
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
      isDemo: isDemo,
      imageFileName: imageFileName,
      sourceUrl: sourceUrl,
      sourceTitle: sourceTitle,
    );
  }
}
