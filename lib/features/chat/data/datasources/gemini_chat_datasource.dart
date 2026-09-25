import 'dart:async';

import 'package:google_generative_ai/google_generative_ai.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/gemini_error_mapper.dart';
import '../../../../core/utils/gemini_model_pool.dart';
import '../../domain/entities/chat_message.dart';

/// Datasource chat literasi via Gemini — teks santai, bukan JSON verdict.
///
/// Pola konstruktor, timeout 30 detik, pesan error ramah, dan failover
/// antar model ([GeminiModelPool]) disamakan dengan [GeminiTextDatasource]
/// agar perilaku key hilang/kuota/safety konsisten di semua fitur AI.
/// API key TIDAK PERNAH di-hardcode: diambil dari
/// `--dart-define=GEMINI_API_KEY=...` atau penyimpanan aman pengguna.
class GeminiChatDatasource {
  GeminiChatDatasource({
    GenerativeModel? model,
    String? apiKey,
    this.modelName = defaultModelName,
    this.timeout = const Duration(seconds: 30),
    GeminiModelPool? pool,
  }) : _model = model,
       _apiKey = apiKey ?? const String.fromEnvironment('GEMINI_API_KEY'),
       _pool = pool ?? GeminiModelPool.shared;

  static const String defaultModelName = GeminiModelPool.primaryModel;

  /// Batas konteks agar prompt tetap hemat kuota free tier.
  static const int maxHistory = 10;

  /// Batas token keluaran — 512 lama membuat jawaban terpotong di tengah
  /// (finishReason MAX_TOKENS) karena thinking model memakai ratusan token
  /// untuk berpikir lebih dulu (diagnosa: 671 token thinking). 2048 cukup
  /// untuk thinking + jawaban maksimal 5 kalimat. Rincian:
  /// [GeminiTextDatasource.maxOutputTokens].
  static const int maxOutputTokens = 2048;

  final GenerativeModel? _model;
  final GeminiModelPool _pool;
  final String _apiKey;
  final String modelName;
  final Duration timeout;

  /// Konfigurasi generasi yang dipakai request chat.
  GenerationConfig get generationConfig =>
      GenerationConfig(temperature: 0.7, maxOutputTokens: maxOutputTokens);

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
    final contents = <Content>[
      Content.text(_systemPrompt),
      for (final item in history.take(maxHistory))
        if (item.isUser)
          Content.text('Pengguna: ${item.text}')
        else
          Content.model([TextPart('Asisten: ${item.text}')]),
      Content.text('Pengguna: $message'),
    ];
    try {
      final response = await _generate(contents, apiKey);
      final text = response.text?.trim() ?? '';
      if (text.isEmpty) {
        throw ServerFailure(
          GeminiErrorMapper.emptyResponseMessage(
            response,
            emptyMessage: 'Server AI tidak mengembalikan jawaban. Coba lagi.',
          ),
        );
      }
      return text;
    } on TimeoutException {
      throw const NetworkFailure();
    } on Failure {
      rethrow;
    } on GenerativeAIException catch (e) {
      throw GeminiErrorMapper.map(e, context: 'chat-reply');
    } catch (e) {
      throw GeminiErrorMapper.mapAny(e, context: 'chat-reply');
    }
  }

  /// Kirim request: lewat [GeminiModelPool] (failover) untuk kunci
  /// pengguna, atau langsung ke model yang disuntikkan untuk test.
  Future<GenerateContentResponse> _generate(
    List<Content> contents,
    String apiKey,
  ) {
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
      context: 'chat-reply',
      timeout: timeout,
    );
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
