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
    final candidates = _extractJsonObjects(_stripCodeFence(rawText));
    if (candidates.isEmpty || candidates.every((text) => text.trim().isEmpty)) {
      throw const ParsingFailure(
        'Hasil AI kosong. Coba verifikasi ulang klaimmu.',
      );
    }
    for (final candidate in candidates) {
      try {
        final decoded = jsonDecode(candidate);
        if (decoded is! Map<String, dynamic>) continue;
        return fromJson(decoded, claim, checkedAt: checkedAt);
      } on ParsingFailure {
        rethrow;
      } catch (_) {
        continue;
      }
    }
    throw const ParsingFailure();
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
    return text;
  }

  static List<String> _extractJsonObjects(String text) {
    if (!text.contains('{')) return [text.trim()];
    final objects = <String>[];

    var inString = false;
    var escaped = false;
    var depth = 0;
    var start = -1;
    for (var i = 0; i < text.length; i++) {
      final char = text.codeUnitAt(i);
      if (inString) {
        if (escaped) {
          escaped = false;
        } else if (char == 0x5c) {
          escaped = true;
        } else if (char == 0x22) {
          inString = false;
        }
        continue;
      }
      if (char == 0x22) {
        inString = true;
      } else if (char == 0x7b) {
        if (depth == 0) start = i;
        depth++;
      } else if (char == 0x7d) {
        depth--;
        if (depth == 0 && start >= 0) {
          objects.add(text.substring(start, i + 1).trim());
          start = -1;
        }
      }
    }
    return objects.isEmpty ? [text.trim()] : objects;
  }

  static Verdict _parseVerdict(Object? value) {
    final normalized = value.toString().trim().toUpperCase();
    return switch (normalized) {
      'HOAKS' || 'HOAX' => Verdict.hoaks,
      'PALSU' || 'FALSE' || 'MISLEADING' || 'MENYESATKAN' => Verdict.hoaks,
      'VALID' || 'BENAR' || 'FAKTA' || 'TRUE' => Verdict.valid,
      'PERLU_DICEK' ||
      'PERLU DICEK' ||
      'MERAGUKAN' ||
      'MUNGKIN' ||
      'UNCERTAIN' => Verdict.perluDicek,
      'TIDAK_DAPAT_DIPASTIKAN' ||
      'TIDAK DAPAT DIPASTIKAN' ||
      'TIDAK_DAPAT_DIVERIFIKASI' ||
      'UNKNOWN' => Verdict.tidakDapatDipastikan,
      _ => Verdict.tidakDapatDipastikan,
    };
  }

  static int _parseConfidence(Object? value) {
    int parsed;
    if (value is num) {
      parsed = value.round();
    } else {
      parsed = int.tryParse(value.toString().trim()) ?? -1;
    }
    return parsed.clamp(0, 100);
  }

  static String _parseText(Object? value) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? 'Model tidak memberikan detail tambahan.' : text;
  }
}
