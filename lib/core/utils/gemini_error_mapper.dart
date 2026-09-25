import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import '../errors/failures.dart';

/// Klasifikasi error Gemini untuk keputusan failover [GeminiModelPool].
enum GeminiErrorKind {
  /// Kunci/permission/billing/API mati — masalah proyek, hasilnya sama di
  /// model mana pun → tidak perlu coba model lain.
  config,

  /// Wilayah pengguna dibatasi Google — juga independen model.
  location,

  /// Kuota free tier (429) — ditandai PER MODEL di server → pindah model
  /// dengan kuota terpisah langsung menyelesaikan.
  quota,

  /// Server sibuk (503/5xx/overloaded) — sementara, layak ulang.
  busy,

  /// Model ditarik/tidak dikenal (404/no longer available) → pindah model.
  retired,

  /// Tidak ada jawaban dalam batas waktu → coba model lain.
  timeout,

  /// Isi permintaan ditolak (safety/400) — bukan salah model, tapi tetap
  /// layak dicoba sekali di model lain karena batas tiap model berbeda.
  content,

  /// Error tak terduga (format respons baru, bug SDK, dsb).
  unknown,
}


/// Pemetaan error Gemini → Failure terpusat (satu sumber kebenaran).
///
/// Dipakai ketiga datasource AI (teks, vision, chat) agar pesan yang sampai
/// ke user konsisten dan spesifik — bukan generik "tidak merespons".
/// Aturan prioritas (dari paling spesifik):
/// 1. Tipe SDK: [InvalidApiKey] → kunci ditolak; [UnsupportedUserLocation]
///    → region dibatasi; [ServerException] dipindai lagi isinya.
/// 2. Pindai teks pesan (lowercase, word-boundary agar `rate` tidak cocok
///    di dalam `generate`): api key, kuota/rate/429, safety/block, model
///    tak dikenal/404, permission/403, billing/400.
/// 3. Tak dikenal → sertakan cuplikan pesan mentah (maks 160 karakter)
///    agar user bisa melapor persis, plus [debugPrint] penuh untuk log.
abstract final class GeminiErrorMapper {
  static const int _rawPreviewLength = 160;

  /// Kata/pola kuota asli server (bukan substring generik).
  ///
  /// `rate`/`quota` WAJIB word-boundary: `contains('rate')` cocok di dalam
  /// kata `generate`/`separate` sehingga error apapun terlabel kuota.
  static final RegExp _quotaPattern = RegExp(
    r'quota|rate[ -]?limit|rate exceeded|too many requests|\b429\b|resource[ -]?exhausted|daily limit|per[ -]?minute',
    caseSensitive: false,
  );

  static ServerFailure map(GenerativeAIException error, {String? context}) {
    final raw = error.message;
    final message = _friendlyMessage(error, raw);
    debugPrint(
      'Gemini error${context != null ? ' [$context]' : ''} '
      '(${error.runtimeType}): $raw',
    );
    return ServerFailure(message);
  }

  /// Petakan error APAPUN (termasuk non-SDK) ke Failure yang bisa ditampilkan.
  ///
  /// Dipakai di `catch (_)` ketiga datasource + probe: sebelumnya error tak
  /// dikenal (mis. `GenerativeAISdkException` saat parsing respons error
  /// 4xx, `FormatException`, `StateError`) ditelan jadi generik
  /// "tidak merespons" tanpa jejak. Sekarang: [GenerativeAIException]
  /// dipetakan normal; sisanya jadi pesan "tak terduga + cuplikan" dengan
  /// [debugPrint] tipe + pesan penuh untuk log.
  static Failure mapAny(Object error, {String? context}) {
    if (error is Failure) return error;
    if (error is GenerativeAIException) {
      return map(error, context: context);
    }
    final raw = error.toString();
    debugPrint(
      'Gemini unknown error${context != null ? ' [$context]' : ''} '
      '(${error.runtimeType}): $raw',
    );
    return ServerFailure(
      'Respons AI tak terduga (${error.runtimeType}): ${_preview(raw)}',
    );
  }

  /// True bila error bersifat sementara dan layak dicoba ulang otomatis
  /// sekali: server sibuk (503/overloaded), respons 5xx, atau timeout
  /// jaringan. Kuota 429 SENGAJA dikecualikan — retry 3 detik tidak akan
  /// mengisi ulang kuota (perlu menit/jam), hanya membuang 1 request +
  /// menambah waktu tunggu. Kunci salah, permission, dan billing TIDAK
  /// transient.
  static bool isTransient(Object error) {
    if (error is TimeoutException) return true;
    if (error is! GenerativeAIException) return false;
    final lower = error.message.toLowerCase();
    return _has(lower, [
      'overloaded',
      'high demand',
      'try again later',
      'tryagain',
      'temporarily',
      '503',
      '502',
      '500',
      'internal error',
      'backend error',
    ]);
  }

  /// Klasifikasi error untuk keputusan failover di [GeminiModelPool].
  ///
  /// Dipakai untuk memutuskan: pindah model (kuota/sibuk/ditarik/timeout),
  /// langsung berhenti (kunci/wilayah), atau tetap lanjut tanpa penalti
  /// (isi/tak dikenal). Urutan pemeriksaan mengikuti prioritas pesan
  /// [_friendlyMessage] agar klasifikasi dan pesan tidak pernah berbeda.
  static GeminiErrorKind kindOf(Object error) {
    if (error is TimeoutException) return GeminiErrorKind.timeout;
    if (error is! GenerativeAIException) return GeminiErrorKind.unknown;
    final raw = error.message;
    final lower = raw.toLowerCase();
    if (error is InvalidApiKey || _has(lower, ['api key', 'api_key'])) {
      return GeminiErrorKind.config;
    }
    if (error is UnsupportedUserLocation) return GeminiErrorKind.location;
    if (_quotaPattern.hasMatch(raw)) return GeminiErrorKind.quota;
    if (_has(lower, [
      'overloaded',
      'high demand',
      'try again later',
      'tryagain',
      'temporarily',
      '503',
      '502',
      '500',
      'internal error',
      'backend error',
    ])) {
      return GeminiErrorKind.busy;
    }
    if (_has(lower, ['blocked', 'safety', 'harm'])) {
      return GeminiErrorKind.content;
    }
    if (_has(lower, [
      'not found',
      '404',
      'not supported',
      'unknown model',
      'no longer available',
      'no longer supported',
      'deprecated',
      'has been removed',
      'retired',
    ])) {
      return GeminiErrorKind.retired;
    }
    if (_has(lower, [
      'permission',
      '403',
      'forbidden',
      'billing',
      'payment',
      'account',
      'api disabled',
      'service disabled',
      'has not been used',
      'invalid argument',
      '400',
    ])) {
      return GeminiErrorKind.config;
    }
    return GeminiErrorKind.unknown;
  }

  /// Pilih kegagalan paling informatif dari upaya seluruh kandidat model.
  ///
  /// Prioritas: isi permintaan/tak terduga (masalah nyata, bukan soal
  /// model) → masalah proyek (kunci/billing) → server sibuk → timeout →
  /// terakhir semua kuota (diberi catatan bahwa model cadangan sudah ikut
  /// dicoba otomatis, agar user tidak menyalahkan satu model saja).
  static Failure finalFailure(List<Object> errors, {String? context}) {
    Object? content;
    Object? project;
    Object? busy;
    Object? timedOut;
    Object? quota;
    for (final error in errors) {
      switch (kindOf(error)) {
        case GeminiErrorKind.quota:
          quota ??= error;
        case GeminiErrorKind.busy:
          busy ??= error;
        case GeminiErrorKind.timeout:
          timedOut ??= error;
        case GeminiErrorKind.content:
        case GeminiErrorKind.unknown:
          content ??= error;
        case GeminiErrorKind.config:
        case GeminiErrorKind.location:
          project ??= error;
        case GeminiErrorKind.retired:
          // Semua model ditarik → paling mendesak, tampilkan segera.
          project ??= error;
      }
    }
    final chosen = content ?? project ?? busy ?? timedOut ?? quota;
    if (chosen == null) return const ServerFailure();
    if (chosen is TimeoutException) return const NetworkFailure();
    if (chosen is! GenerativeAIException) {
      return mapAny(chosen, context: context);
    }
    if (identical(chosen, quota)) {
      final base = map(chosen, context: context);
      return ServerFailure(
        '${base.message} Aplikasi sudah mencoba beberapa model cadangan '
        'secara otomatis dan semuanya ikut terkena batas yang sama.',
      );
    }
    return map(chosen, context: context);
  }

  /// Pesan untuk respons sukses HTTP tetapi tanpa isi teks.
  ///
  /// Membedakan "terpotong di batas token" (finishReason MAX_TOKENS —
  /// model thinking memakai ratusan token untuk berpikir) dari respons
  /// kosong biasa, agar user tahu akar masalahnya.
  static String emptyResponseMessage(
    GenerateContentResponse response, {
    String emptyMessage = 'Server AI tidak mengembalikan hasil. Coba lagi.',
  }) {
    final finishReason = response.candidates.isEmpty
        ? null
        : response.candidates.first.finishReason;
    if (finishReason == FinishReason.maxTokens) {
      return 'Respons AI terpotong di tengah karena kehabisan batas token. '
          'Coba lagi, atau kirim teks yang lebih singkat.';
    }
    return emptyMessage;
  }

  /// Cuplikan pesan mentah untuk pesan tak dikenal — tanpa membocorkan
  /// kunci (kunci tidak pernah ada di pesan error server).
  static String _preview(String raw) {
    final cleaned = raw.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (cleaned.length <= _rawPreviewLength) return cleaned;
    return '${cleaned.substring(0, _rawPreviewLength)}…';
  }

  static String _friendlyMessage(GenerativeAIException error, String raw) {
    final lower = raw.toLowerCase();
    if (error is InvalidApiKey || _has(lower, ['api key', 'api_key'])) {
      return 'Kunci API Gemini ditolak server. Salin ulang kunci dari '
          'Google AI Studio tanpa spasi, lalu simpan ulang di Pengaturan.';
    }
    if (error is UnsupportedUserLocation) {
      return 'Wilayah/jaringan ini dibatasi oleh Google untuk API Gemini. '
          'Coba ganti jaringan (Wi-Fi/data seluler) atau matikan VPN.';
    }
    if (_quotaPattern.hasMatch(raw)) {
      return 'Batas pemakaian AI tercapai (kuota harian/menit kunci ini habis). '
          'Tunggu 1–2 menit lalu coba lagi. Bila sering terjadi, buat kunci '
          'baru di Google AI Studio (kuota gratis per kunci, bukan per aplikasi).';
    }
    if (_has(lower, [
      'overloaded',
      'high demand',
      'try again later',
      'tryagain',
      'temporarily unavailable',
      '503',
      '502',
      '500',
      'internal error',
      'backend error',
    ])) {
      return 'Server AI sedang sibuk (lonjakan pemakaian, biasanya sementara). '
          'Tunggu sekitar 1 menit lalu coba lagi.';
    }
    if (_has(lower, ['blocked', 'safety', 'harm'])) {
      return 'Konten tidak dapat diproses filter keamanan. Coba ubah redaksinya.';
    }
    if (_has(lower, [
      'not found',
      '404',
      'not supported',
      'unknown model',
      'no longer available',
      'no longer supported',
      'deprecated',
      'has been removed',
      'retired',
    ])) {
      return 'Model AI tidak ditemukan untuk kunci ini. Coba lagi nanti '
          'atau laporkan ke developer.';
    }
    if (_has(lower, ['permission', '403', 'forbidden'])) {
      return 'Kunci API tidak punya izin memakai model ini. Aktifkan '
          'Generative Language API di Google Cloud Console untuk project kunci tersebut.';
    }
    if (_has(lower, ['billing', 'payment', 'account'])) {
      return 'Akun Google Cloud kunci ini bermasalah (billing/dinonaktifkan). '
          'Periksa status project di Google Cloud Console.';
    }
    if (_has(lower, ['api disabled', 'service disabled', 'has not been used'])) {
      return 'Generative Language API belum aktif untuk project kunci ini. '
          'Aktifkan di Google Cloud Console, tunggu beberapa menit, lalu coba lagi.';
    }
    if (_has(lower, ['invalid argument', '400'])) {
      return 'Permintaan ditolak server. Coba sederhanakan teks lalu kirim ulang.';
    }
    if (lower.isEmpty) {
      return 'Server AI tidak merespons, coba lagi.';
    }
    return 'Server AI menjawab di luar dugaan: ${_preview(lower)}';
  }

  static bool _has(String lower, List<String> needles) {
    for (final needle in needles) {
      if (lower.contains(needle)) return true;
    }
    return false;
  }
}
