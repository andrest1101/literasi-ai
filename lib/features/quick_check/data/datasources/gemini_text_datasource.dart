import 'dart:async';

import 'package:google_generative_ai/google_generative_ai.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/verification_result.dart';
import '../models/verification_result_model.dart';

/// Datasource verifikasi klaim teks via Gemini.
///
/// Model final: `gemini-3.5-flash-lite`. SDK 0.4.7 tidak memvalidasi nama
/// model di sisi client — string diteruskan ke endpoint — sehingga tidak
/// perlu upgrade package untuk model ini.
///
/// API key TIDAK PERNAH di-hardcode: diambil dari
/// `--dart-define=GEMINI_API_KEY=...`.
class GeminiTextDatasource {
  GeminiTextDatasource({
    GenerativeModel? model,
    String? apiKey,
    this.modelName = defaultModelName,
    this.timeout = const Duration(seconds: 30),
  }) : _model = model,
       _apiKey = apiKey ?? const String.fromEnvironment('GEMINI_API_KEY');

  static const String defaultModelName = 'gemini-3.5-flash-lite';

  final GenerativeModel? _model;
  final String _apiKey;
  final String modelName;
  final Duration timeout;

  GenerativeModel _resolveModel([String? overrideKey]) {
    if (_model != null) return _model;
    final key = overrideKey ?? _apiKey;
    if (key.isEmpty) {
      throw const UnknownFailure(
        'Kunci API belum tersambung. '
        'Tempel kunci di Pengaturan atau jalankan dengan --dart-define=GEMINI_API_KEY=...',
      );
    }
    return GenerativeModel(
      model: modelName,
      apiKey: key,
      generationConfig: GenerationConfig(
        temperature: 0.2,
        maxOutputTokens: 512,
        responseMimeType: 'application/json',
      ),
    );
  }

  Future<VerificationResult> verifyText(String claim) async {
    return verifyTextWithKey(claim, _apiKey);
  }

  Future<VerificationResult> verifyTextWithKey(
    String claim,
    String apiKey,
  ) async {
    final model = _resolveModel(apiKey);
    try {
      final response = await model
          .generateContent([Content.text(_buildPrompt(claim))])
          .timeout(timeout);
      final text = response.text?.trim() ?? '';
      if (text.isEmpty) {
        throw const ServerFailure(
          'Server AI tidak mengembalikan hasil. Coba lagi.',
        );
      }
      return VerificationResultModel.fromRawText(text, claim);
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
      return 'API key Gemini tidak valid. Periksa konfigurasi kunci API Anda.';
    }
    if (lower.contains('quota') ||
        lower.contains('rate') ||
        lower.contains('429')) {
      return 'Batas pemakaian AI tercapai. Tunggu sebentar lalu coba lagi.';
    }
    if (lower.contains('blocked') || lower.contains('safety')) {
      return 'Informasi tidak dapat diproses filter keamanan. Coba ubah redaksinya.';
    }
    if (lower.contains('not found') || lower.contains('404')) {
      return 'Model AI tidak ditemukan. Periksa nama model yang dipakai.';
    }
    return 'Server AI tidak merespons, coba lagi.';
  }

  String _buildPrompt(String claim) {
    return '''
Kamu adalah AI spesialis verifikasi fakta untuk masyarakat Indonesia.
Analisis klaim berikut dan berikan verdict dalam format JSON yang diminta.
Gunakan Bahasa Indonesia yang mudah dipahami.
Jangan tambahkan teks di luar format JSON.

Klaim: $claim

Format respons (JSON murni, tanpa markdown):
{
  "verdict": "HOAKS | VALID | PERLU_DICEK | TIDAK_DAPAT_DIPASTIKAN",
  "confidence": 0-100,
  "explanation": "penjelasan 2-3 kalimat",
  "suggestion": "saran verifikasi lanjutan, mis. cek TurnBackHoax atau media arus utama"
}

Aturan:
- Bila bukti tidak cukup, pakai "TIDAK_DAPAT_DIPASTIKAN" dengan confidence rendah.
- Jangan mengarang sumber, tanggal, atau kutipan spesifik.
''';
  }
}
