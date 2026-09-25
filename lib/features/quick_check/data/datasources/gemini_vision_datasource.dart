import 'dart:async';

import 'package:google_generative_ai/google_generative_ai.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/gemini_error_mapper.dart';
import '../../../../core/utils/gemini_model_pool.dart';
import '../../domain/entities/image_attachment.dart';
import '../../domain/entities/verification_result.dart';
import '../models/verification_result_model.dart';

/// Datasource verifikasi klaim gambar via Gemini multimodal.
///
/// Mengirim `TextPart` instruksi + `DataPart` bytes gambar dalam satu
/// `Content.multi`. Model membaca teks visual terlebih dahulu, lalu
/// memberikan verdict JSON terstruktur yang sama seperti mode teks.
/// Failover antar model ditangani [GeminiModelPool] (kuota 429/404/503
/// berpindah otomatis ke model cadangan).
///
/// API key TIDAK PERNAH di-hardcode: diambil dari
/// `--dart-define=GEMINI_API_KEY=...` atau penyimpanan aman pengguna.
class GeminiVisionDatasource {
  GeminiVisionDatasource({
    GenerativeModel? model,
    String? apiKey,
    this.modelName = defaultModelName,
    this.timeout = const Duration(seconds: 45),
    GeminiModelPool? pool,
  }) : _model = model,
       _apiKey = apiKey ?? const String.fromEnvironment('GEMINI_API_KEY'),
       _pool = pool ?? GeminiModelPool.shared;

  static const String defaultModelName = GeminiModelPool.primaryModel;

  /// Batas token keluaran: ruang untuk thinking model + verdict JSON.
  /// Lihat penjelasan lengkap di [GeminiTextDatasource.maxOutputTokens]:
  /// 512 lama membuat jawaban terpotong di tengah JSON (MAX_TOKENS).
  static const int maxOutputTokens = 2048;

  final GenerativeModel? _model;
  final GeminiModelPool _pool;
  final String _apiKey;
  final String modelName;
  final Duration timeout;

  /// Konfigurasi generasi yang dipakai request verifikasi gambar.
  GenerationConfig get generationConfig => GenerationConfig(
    temperature: 0.2,
    maxOutputTokens: maxOutputTokens,
    responseMimeType: 'application/json',
  );

  Future<VerificationResult> verifyImage({
    required ImageAttachment image,
    String caption = '',
  }) async {
    return verifyImageWithKey(image: image, caption: caption, apiKey: _apiKey);
  }

  Future<VerificationResult> verifyImageWithKey({
    required ImageAttachment image,
    String caption = '',
    required String apiKey,
  }) async {
    if (!image.isValid) {
      throw const UnknownFailure(
        'Gambar tidak terbaca, upload ulang dengan pencahayaan lebih baik.',
      );
    }
    try {
      final response = await _generate(image, caption, apiKey);
      final text = response.text?.trim() ?? '';
      if (text.isEmpty) {
        throw ServerFailure(
          GeminiErrorMapper.emptyResponseMessage(response),
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
      throw GeminiErrorMapper.map(e, context: 'verify-image');
    } catch (e) {
      throw GeminiErrorMapper.mapAny(e, context: 'verify-image');
    }
  }

  /// Kirim request: lewat [GeminiModelPool] (failover) untuk kunci
  /// pengguna, atau langsung ke model yang disuntikkan untuk test.
  Future<GenerateContentResponse> _generate(
    ImageAttachment image,
    String caption,
    String apiKey,
  ) {
    final contents = [
      Content.multi([
        TextPart(_buildPrompt(caption)),
        DataPart(image.mimeType, image.bytes),
      ]),
    ];
    final injected = _model;
    if (injected != null) {
      return injected.generateContent(contents).timeout(timeout);
    }
    if (apiKey.trim().isEmpty) {
      throw const UnknownFailure(
        'Kunci API belum tersambung. '
        'Tempel kunci di Pengaturan atau jalankan dengan --dart-define=GEMINI_API_KEY=...',
      );
    }
    return _pool.generate(
      apiKey: apiKey,
      generationConfig: generationConfig,
      contents: contents,
      context: 'verify-image',
      timeout: timeout,
    );
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
