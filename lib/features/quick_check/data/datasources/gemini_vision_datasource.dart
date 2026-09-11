import 'dart:async';

import 'package:google_generative_ai/google_generative_ai.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/image_attachment.dart';
import '../../domain/entities/verification_result.dart';
import '../models/verification_result_model.dart';

/// Datasource verifikasi klaim gambar via Gemini multimodal.
///
/// Mengirim `TextPart` instruksi + `DataPart` bytes gambar dalam satu
/// `Content.multi`. Model membaca teks visual terlebih dahulu, lalu
/// memberikan verdict JSON terstruktur yang sama seperti mode teks.
///
/// API key TIDAK PERNAH di-hardcode: diambil dari
/// `--dart-define=GEMINI_API_KEY=...`.
class GeminiVisionDatasource {
  GeminiVisionDatasource({
    GenerativeModel? model,
    String? apiKey,
    this.modelName = defaultModelName,
    this.timeout = const Duration(seconds: 45),
  }) : _model = model,
       _apiKey = apiKey ?? const String.fromEnvironment('GEMINI_API_KEY');

  static const String defaultModelName = 'gemini-3.5-flash-lite';

  final GenerativeModel? _model;
  final String _apiKey;
  final String modelName;
  final Duration timeout;

  GenerativeModel _resolveModel() {
    if (_model != null) return _model;
    if (_apiKey.isEmpty) {
      throw const UnknownFailure(
        'GEMINI_API_KEY belum dikonfigurasi. '
        'Jalankan dengan --dart-define=GEMINI_API_KEY=...',
      );
    }
    return GenerativeModel(
      model: modelName,
      apiKey: _apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.2,
        maxOutputTokens: 768,
        responseMimeType: 'application/json',
      ),
    );
  }

  Future<VerificationResult> verifyImage({
    required ImageAttachment image,
    String caption = '',
  }) async {
    if (!image.isValid) {
      throw const UnknownFailure(
        'Gambar tidak terbaca, upload ulang dengan pencahayaan lebih baik.',
      );
    }
    final model = _resolveModel();
    try {
      final response = await model
          .generateContent([
            Content.multi([
              TextPart(_buildPrompt(caption)),
              DataPart(image.mimeType, image.bytes),
            ]),
          ])
          .timeout(timeout);
      final text = response.text?.trim() ?? '';
      if (text.isEmpty) {
        throw const ServerFailure(
          'Server AI tidak mengembalikan hasil. Coba lagi.',
        );
      }
      final claim = caption.isEmpty ? 'Gambar: ${image.fileName}' : caption;
      final parsed = VerificationResultModel.fromRawText(text, claim);
      return VerificationResult(
        claim: parsed.claim,
        verdict: parsed.verdict,
        confidence: parsed.confidence,
        explanation: parsed.explanation,
        suggestion: parsed.suggestion,
        checkedAt: parsed.checkedAt,
        source: VerificationSource.image,
        imageFileName: image.fileName,
      );
    } on TimeoutException {
      throw const NetworkFailure();
    } on Failure {
      rethrow;
    } on GenerativeAIException catch (e) {
      throw ServerFailure(_friendlyMessage(e.message));
    } catch (_) {
      throw const ServerFailure();
    }
  }

  String _friendlyMessage(String message) {
    final lower = message.toLowerCase();
    if (lower.contains('api key') || lower.contains('api_key')) {
      return 'API key Gemini tidak valid. Periksa konfigurasi key-mu.';
    }
    if (lower.contains('quota') ||
        lower.contains('rate') ||
        lower.contains('429')) {
      return 'Batas pemakaian AI tercapai. Tunggu sebentar lalu coba lagi.';
    }
    if (lower.contains('blocked') || lower.contains('safety')) {
      return 'Gambar tidak dapat diproses filter keamanan. Coba gambar lain.';
    }
    if (lower.contains('not found') || lower.contains('404')) {
      return 'Model AI tidak ditemukan. Periksa nama model yang dipakai.';
    }
    return 'Server AI tidak merespons, coba lagi.';
  }

  String _buildPrompt(String caption) {
    final context = caption.isEmpty
        ? 'Tidak ada caption tambahan dari pengguna.'
        : 'Caption pengguna: $caption';
    return '''
Kamu adalah AI spesialis verifikasi fakta untuk masyarakat Indonesia.
Langkah 1: baca dan ekstrak teks atau klaim utama dari gambar terlampir.
Langkah 2: verifikasi klaim tersebut dan berikan verdict dalam format JSON.
Gunakan Bahasa Indonesia yang mudah dipahami.
Jangan tambahkan teks di luar format JSON.

$context

Format respons (JSON murni, tanpa markdown):
{
  "verdict": "HOAKS | VALID | PERLU_DICEK | TIDAK_DAPAT_DIPASTIKAN",
  "confidence": 0-100,
  "explanation": "penjelasan 2-3 kalimat",
  "suggestion": "saran verifikasi lanjutan, mis. cek TurnBackHoax atau media arus utama"
}

Aturan:
- Bila teks gambar tidak terbaca atau bukti tidak cukup, pakai
  "TIDAK_DAPAT_DIPASTIKAN" dengan confidence rendah.
- Jangan mengarang sumber, tanggal, atau kutipan spesifik.
''';
  }
}
