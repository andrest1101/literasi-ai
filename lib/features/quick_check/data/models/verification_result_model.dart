import 'dart:convert';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/verification_result.dart';

/// Model JSON hasil Gemini → entity domain.
///
/// Parsing dibuat toleran terhadap output model yang dibungkus markdown
/// code fence, field opsional kosong, dan confidence di luar 0–100.
class VerificationResultModel {
  const VerificationResultModel._();

  static VerificationResult fromJson(
    Map<String, dynamic> json,
    String claim, {
    DateTime? checkedAt,
  }) {
    final verdict = _parseVerdict(json['verdict']);
    final confidence = _parseConfidence(json['confidence']);
    final explanation = _parseText(json['explanation']);
    final suggestion = _parseText(json['suggestion']);

    return VerificationResult(
      claim: claim,
      verdict: verdict,
      confidence: confidence,
      explanation: explanation,
      suggestion: suggestion,
      checkedAt: checkedAt ?? DateTime.now(),
    );
  }

  /// Parsing dari teks mentah Gemini: membersihkan ```json fence bila ada.
  static VerificationResult fromRawText(
    String rawText,
    String claim, {
    DateTime? checkedAt,
  }) {
    final cleaned = _stripCodeFence(rawText);
    if (cleaned.isEmpty) {
      throw const ParsingFailure(
        'Hasil AI kosong. Coba verifikasi ulang klaimmu.',
      );
    }
    try {
      final decoded = jsonDecode(cleaned);
      if (decoded is! Map<String, dynamic>) {
        throw const ParsingFailure();
      }
      return fromJson(decoded, claim, checkedAt: checkedAt);
    } on ParsingFailure {
      rethrow;
    } catch (_) {
      throw const ParsingFailure();
    }
  }

  Map<String, dynamic> toJson(VerificationResult result) {
    return {
      'claim': result.claim,
      'verdict': result.verdict.jsonValue,
      'confidence': result.confidence,
      'explanation': result.explanation,
      'suggestion': result.suggestion,
      'checkedAt': result.checkedAt.toIso8601String(),
      'source': result.source.name,
      if (result.imageFileName != null) 'imageFileName': result.imageFileName,
      if (result.sourceUrl != null) 'sourceUrl': result.sourceUrl,
      if (result.sourceTitle != null) 'sourceTitle': result.sourceTitle,
    };
  }

  static String _stripCodeFence(String raw) {
    var text = raw.trim();
    final fence = RegExp(r'^```(?:json)?\s*([\s\S]*?)\s*```$');
    final match = fence.firstMatch(text);
    if (match != null) {
      text = match.group(1)?.trim() ?? '';
    }
    // Ambil objek JSON pertama bila model menambah teks di sekitarnya.
    final start = text.indexOf('{');
    final end = text.lastIndexOf('}');
    if (start >= 0 && end > start) {
      return text.substring(start, end + 1).trim();
    }
    return text;
  }

  static Verdict _parseVerdict(Object? value) {
    final normalized = value.toString().trim().toUpperCase();
    return switch (normalized) {
      'HOAKS' || 'HOAX' => Verdict.hoaks,
      'VALID' || 'BENAR' || 'FAKTA' => Verdict.valid,
      'PERLU_DICEK' ||
      'PERLU DICEK' ||
      'MERAGUKAN' ||
      'UNCERTAIN' => Verdict.perluDicek,
      'TIDAK_DAPAT_DIPASTIKAN' ||
      'TIDAK DAPAT DIPASTIKAN' ||
      'TIDAK_DAPAT_DIVERIFIKASI' ||
      'UNKNOWN' => Verdict.tidakDapatDipastikan,
      _ => throw const ParsingFailure(),
    };
  }

  static int _parseConfidence(Object? value) {
    int parsed;
    if (value is num) {
      parsed = value.round();
    } else {
      parsed = int.tryParse(value.toString().trim()) ?? -1;
    }
    if (parsed < 0 || parsed > 100) {
      throw const ParsingFailure(
        'Skor keyakinan AI tidak valid. Coba verifikasi ulang.',
      );
    }
    return parsed;
  }

  static String _parseText(Object? value) {
    final text = value?.toString().trim() ?? '';
    if (text.isEmpty) {
      throw const ParsingFailure();
    }
    return text;
  }
}
