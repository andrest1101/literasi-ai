import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import 'gemini_error_mapper.dart';

/// Pengganti pemanggilan API sungguhan untuk keperluan test.
///
/// `GenerativeModel` adalah class final di SDK sehingga tidak bisa di-fake;
/// test menyuntikkan transport ini untuk mensimulasikan 429/404/503 per model.
typedef GeminiTransport = Future<GenerateContentResponse> Function({
  required String model,
  required String apiKey,
  required GenerationConfig generationConfig,
  required List<Content> contents,
});

/// Pool model Gemini dengan gagal-pindah (failover) otomatis antar model.
///
/// Masalah nyata yang dipecahkan (diagnosa langsung ke server, Sep 2026):
/// * `gemini-3.6-flash` free tier dibatasi 20 request → 429 yang bisa
///   bertahan berjam-jam, sementara model lain punya kuota TERPISAH
///   (bukti: saat 3.6-flash 429, 3.5/3.7-flash membalas 200 OK);
/// * model lama (2.x) sudah 404 "no longer available";
/// * model terbaru (3.8) kadang 503 high demand.
///
/// Karena itu satu request tidak menempel pada satu model: pool mencoba
/// kandiden berurutan, memberi jeda penalti ke model yang gagal (kuota →
/// 10 menit, sibuk/timeout → 45 detik, ditarik → 12 jam), dan mengingat
/// model terakhir berhasil agar request berikutnya langsung ke tujuan.
///
/// Error yang bersifat independen model (kunci ditolak, wilayah dibatasi)
/// TIDAK di-failover: hasilnya sama di model mana pun, jadi langsung
/// diteruskan ke caller agar pesannya tetap akurat.
class GeminiModelPool {
  GeminiModelPool({
    GeminiTransport? transport,
    List<String>? candidates,
    Duration retryDelay = defaultRetryDelay,
    DateTime Function()? clock,
  }) : _transport = transport,
       _candidates = List.unmodifiable(candidates ?? defaultCandidates),
       _retryDelay = retryDelay,
       _clock = clock ?? DateTime.now;

  /// Model utama: sama dengan nama yang dipakai seluruh datasource.
  static const String primaryModel = 'gemini-3.6-flash';

  /// Urutan kandidat: model utama dulu, lalu model cadangan yang terbukti
  /// melayani request free tier saat diagnosa (semua membalas 200 OK).
  static const List<String> defaultCandidates = [
    primaryModel,
    'gemini-3.5-flash',
    'gemini-3.7-flash',
    'gemini-flash-latest',
    'gemini-flash-lite-latest',
  ];

  static const Duration defaultRetryDelay = Duration(seconds: 3);
  static const Duration quotaPenalty = Duration(minutes: 10);
  static const Duration busyPenalty = Duration(seconds: 45);
  static const Duration retiredPenalty = Duration(hours: 12);
  static const Duration timeoutPenalty = Duration(seconds: 45);

  /// Instansi bersama seluruh datasource + probe: status model yang sedang
  /// gagal saling menguntungkan, bukan duplikasi request antar fitur.
  static final GeminiModelPool shared = GeminiModelPool();

  final GeminiTransport? _transport;
  final List<String> _candidates;
  final Duration _retryDelay;
  final DateTime Function() _clock;

  String? _preferred;
  final _blockedUntil = <String, DateTime>{};

  /// Model yang terakhir berhasil melayani request (null bila belum ada).
  String? get preferred => _preferred;

  /// Salinan status penalti per model (untuk log/diagnostik/test).
  Map<String, DateTime> get blockedUntil => Map.unmodifiable(_blockedUntil);

  /// Model yang saat ini lolos penalti (untuk log/diagnostik/test).
  List<String> activeCandidates({bool ignorePenalty = false}) =>
      _order(ignorePenalty: ignorePenalty);

  /// Lupakan preferensi & penalti (dipakai test dan ganti kunci).
  void reset() {
    _preferred = null;
    _blockedUntil.clear();
  }

  /// Kirim request ke kandidat model berikutnya sampai ada yang berhasil.
  ///
  /// Lempar [Failure] bila seluruh kandidat gagal (pesan terpilih oleh
  /// [GeminiErrorMapper.finalFailure]), atau meneruskan exception asli bila
  /// error-nya independen model (kunci/wilayah).
  Future<GenerateContentResponse> generate({
    required String apiKey,
    required GenerationConfig generationConfig,
    required List<Content> contents,
    required String context,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final errors = <Object>[];
    final failedModels = <String>[];
    for (var round = 0; round < 2; round++) {
      for (final model in _order(ignorePenalty: round > 0)) {
        try {
          final response = await _invoke(
            model: model,
            apiKey: apiKey,
            generationConfig: generationConfig,
            contents: contents,
          ).timeout(timeout);
          _onSuccess(model, context);
          return response;
        } on GenerativeAIException catch (e) {
          final kind = GeminiErrorMapper.kindOf(e);
          if (kind == GeminiErrorKind.config ||
              kind == GeminiErrorKind.location) {
            rethrow;
          }
          _onFailure(model, kind);
          errors.add(e);
          failedModels.add(model);
        } on TimeoutException catch (e) {
          _onFailure(model, GeminiErrorKind.timeout);
          errors.add(e);
          failedModels.add(model);
        } catch (e) {
          _onFailure(model, GeminiErrorKind.unknown);
          errors.add(e);
          failedModels.add(model);
        }
      }
      // Ulang sekali hanya bila SEMUA kegagalan bersifat sementara
      // (server sibuk/timeout). Kuota, model ditarik, atau error isi tidak
      // akan berubah dalam hitungan detik: tidak perlu membuang request.
      if (round == 1 || !errors.every(GeminiErrorMapper.isTransient)) break;
      await Future<void>.delayed(_retryDelay);
    }
    debugPrint(
      'Gemini [$context] semua model gagal: ${failedModels.toSet().join(', ')}',
    );
    throw GeminiErrorMapper.finalFailure(errors, context: context);
  }

  Future<GenerateContentResponse> _invoke({
    required String model,
    required String apiKey,
    required GenerationConfig generationConfig,
    required List<Content> contents,
  }) {
    final transport = _transport;
    if (transport != null) {
      return transport(
        model: model,
        apiKey: apiKey,
        generationConfig: generationConfig,
        contents: contents,
      );
    }
    return GenerativeModel(
      model: model,
      apiKey: apiKey,
      generationConfig: generationConfig,
    ).generateContent(contents);
  }

  /// Urutan kandidat: model favorit dulu, model kena penalti dikeluarkan.
  /// Bila SEMUA kena penalti, tetap kirim (server sumber kebenaran: bisa
  /// saja jendela kuota baru saja terbuka).
  List<String> _order({required bool ignorePenalty}) {
    final names = [..._candidates];
    final preferred = _preferred;
    if (preferred != null && names.remove(preferred)) {
      names.insert(0, preferred);
    }
    if (ignorePenalty) return names;
    final now = _clock();
    final active = names.where((name) {
      final until = _blockedUntil[name];
      return until == null || !until.isAfter(now);
    }).toList();
    return active.isEmpty ? names : active;
  }

  void _onSuccess(String model, String context) {
    _preferred = model;
    _blockedUntil.remove(model);
    debugPrint('Gemini [$context] sukses via model $model');
  }

  void _onFailure(String model, GeminiErrorKind kind) {
    final penalty = switch (kind) {
      GeminiErrorKind.quota => quotaPenalty,
      GeminiErrorKind.busy => busyPenalty,
      GeminiErrorKind.timeout => timeoutPenalty,
      GeminiErrorKind.retired => retiredPenalty,
      GeminiErrorKind.config ||
      GeminiErrorKind.location ||
      GeminiErrorKind.content ||
      GeminiErrorKind.unknown => Duration.zero,
    };
    if (penalty == Duration.zero) return;
    _blockedUntil[model] = _clock().add(penalty);
    debugPrint(
      'Gemini: model $model ditahan '
      '${penalty.inSeconds} detik karena ${kind.name}',
    );
  }
}
