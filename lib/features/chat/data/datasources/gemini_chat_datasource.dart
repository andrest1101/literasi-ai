import 'dart:async';

import 'package:google_generative_ai/google_generative_ai.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/chat_message.dart';

/// Datasource chat literasi via Gemini — teks santai, bukan JSON verdict.
///
/// Pola konstruktor, timeout 30 detik, dan pesan error ramah disamakan dengan
/// `GeminiTextDatasource` agar perilaku key hilang/kuota/safety konsisten.
/// API key TIDAK PERNAH di-hardcode: diambil dari
/// `--dart-define=GEMINI_API_KEY=...`.
class GeminiChatDatasource {
  GeminiChatDatasource({
    GenerativeModel? model,
    String? apiKey,
    this.modelName = defaultModelName,
    this.timeout = const Duration(seconds: 30),
  }) : _model = model,
       _apiKey = apiKey ?? const String.fromEnvironment('GEMINI_API_KEY');

  static const String defaultModelName = 'gemini-3.5-flash-lite';

  /// Batas konteks agar prompt tetap hemat kuota free tier.
  static const int maxHistory = 10;

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
        temperature: 0.7,
        maxOutputTokens: 512,
      ),
    );
  }

  Future<String> reply({
    required List<ChatMessage> history,
    required String message,
  }) async {
    return replyWithKey(history: history, message: message, apiKey: _apiKey);
  }

  Future<String> replyWithKey({
    required List<ChatMessage> history,
    required String message,
    required String apiKey,
  }) async {
    final model = _resolveModel(apiKey);
    try {
      final contents = <Content>[
        Content.text(_systemPrompt),
        for (final item in history.take(maxHistory))
          if (item.isUser)
            Content.text('Pengguna: ${item.text}')
          else
            Content.model([TextPart('Asisten: ${item.text}')]),
        Content.text('Pengguna: $message'),
      ];
      final response = await model.generateContent(contents).timeout(timeout);
      final text = response.text?.trim() ?? '';
      if (text.isEmpty) {
        throw const ServerFailure(
          'Server AI tidak mengembalikan jawaban. Coba lagi.',
        );
      }
      return text;
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
      return 'Pertanyaan tidak dapat diproses filter keamanan. Coba ubah redaksinya.';
    }
    if (lower.contains('not found') || lower.contains('404')) {
      return 'Model AI tidak ditemukan. Periksa nama model yang dipakai.';
    }
    return 'Server AI tidak merespons, coba lagi.';
  }

  static const String _systemPrompt =
      'Kamu adalah asisten literasi digital LiterasiAI untuk masyarakat '
      'Indonesia. Jawab santai tapi informatif dalam Bahasa Indonesia yang mudah '
      'dipahami, maksimal 5 kalimat. Fokus pada cara mengenali hoaks, memverifikasi '
      'sumber, dan berpikir kritis. Jangan mengarang sumber, tanggal, atau kutipan '
      'spesifik. Bila bukti tidak cukup, katakan jujur dan sarankan verifikasi ke '
      'sumber resmi seperti TurnBackHoax atau media arus utama. Kamu bukan sumber '
      'kebenaran mutlak, melainkan teman diskusi literasi.';
}
