import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:literasi_ai/core/errors/failures.dart';
import 'package:literasi_ai/core/utils/gemini_error_mapper.dart';
import 'package:literasi_ai/core/utils/gemini_model_pool.dart';
import 'package:literasi_ai/features/chat/data/datasources/gemini_chat_datasource.dart';
import 'package:literasi_ai/features/quick_check/data/datasources/gemini_text_datasource.dart';
import 'package:literasi_ai/features/quick_check/data/datasources/gemini_vision_datasource.dart';

GenerateContentResponse _ok() => GenerateContentResponse(const [], null);

const _quotaError =
    'You exceeded your current quota. '
    'Quota exceeded for metric: generate_content_free_tier_requests, '
    'limit: 20, model: gemini-3.6-flash. Please retry in 30s.';

const _busyError =
    'This model is currently experiencing high demand. '
    'Please try again later.';

typedef _Transport = GeminiTransport;

/// Transport uji yang mencatat urutan model dan bisa gagal per model.
_Transport _transport({
  required List<String> calls,
  Set<String> failWithQuota = const {},
  Set<String> failWithBusy = const {},
  Future<GenerateContentResponse> Function(String model)? onCall,
}) {
  return ({
    required String model,
    required String apiKey,
    required GenerationConfig generationConfig,
    required List<Content> contents,
  }) async {
    calls.add(model);
    if (onCall != null) return onCall(model);
    if (failWithQuota.contains(model)) throw ServerException(_quotaError);
    if (failWithBusy.contains(model)) throw ServerException(_busyError);
    return _ok();
  };
}

void main() {
  group('GeminiModelPool — failover antar model (inti perbaikan 429)', () {
    test('kuota di model utama → otomatis pindah ke cadangan', () async {
      final calls = <String>[];
      final pool = GeminiModelPool(
        retryDelay: Duration.zero,
        transport: _transport(
          calls: calls,
          failWithQuota: {GeminiModelPool.primaryModel},
        ),
      );

      final response = await pool.generate(
        apiKey: 'kunci-uji',
        generationConfig: GenerationConfig(),
        contents: const [],
        context: 'uji',
      );

      expect(response.candidates, isEmpty);
      expect(calls, [GeminiModelPool.primaryModel, 'gemini-3.5-flash']);
      expect(pool.preferred, 'gemini-3.5-flash');
    });

    test('model utama kena penalti → tidak dipanggil lagi di request berikut',
        () async {
      final calls = <String>[];
      final pool = GeminiModelPool(
        retryDelay: Duration.zero,
        transport: _transport(
          calls: calls,
          failWithQuota: {GeminiModelPool.primaryModel},
        ),
      );
      await pool.generate(
        apiKey: 'kunci-uji',
        generationConfig: GenerationConfig(),
        contents: const [],
        context: 'uji',
      );
      expect(
        pool.activeCandidates(),
        isNot(contains(GeminiModelPool.primaryModel)),
        reason: 'model kena kuota harus ditahan, tidak dipanggil lagi',
      );
      expect(
        pool.blockedUntil[GeminiModelPool.primaryModel],
        isNotNull,
        reason: 'penalti kuota tercatat dengan waktu kedaluwarsa',
      );
    });

    test('model favorit dicoba paling awal pada pool yang sama', () async {
      final calls = <String>[];
      final pool = GeminiModelPool(
        retryDelay: Duration.zero,
        transport: _transport(
          calls: calls,
          failWithQuota: {GeminiModelPool.primaryModel},
        ),
      );
      await pool.generate(
        apiKey: 'kunci-uji',
        generationConfig: GenerationConfig(),
        contents: const [],
        context: 'uji',
      );
      calls.clear();
      await pool.generate(
        apiKey: 'kunci-uji',
        generationConfig: GenerationConfig(),
        contents: const [],
        context: 'uji',
      );
      expect(calls, ['gemini-3.5-flash']);
    });

    test('kunci ditolak → HENTI, jangan buang request ke model lain',
        () async {
      final calls = <String>[];
      final pool = GeminiModelPool(
        retryDelay: Duration.zero,
        transport: ({
          required String model,
          required String apiKey,
          required GenerationConfig generationConfig,
          required List<Content> contents,
        }) async {
          calls.add(model);
          throw InvalidApiKey('API key not valid.');
        },
      );

      await expectLater(
        pool.generate(
          apiKey: 'kunci-salah',
          generationConfig: GenerationConfig(),
          contents: const [],
          context: 'uji',
        ),
        throwsA(isA<InvalidApiKey>()),
      );
      expect(calls, hasLength(1));
    });

    test('SEMUA model kena kuota → pesan kuota + konteks model cadangan',
        () async {
      final calls = <String>[];
      final pool = GeminiModelPool(
        retryDelay: Duration.zero,
        transport: _transport(
          calls: calls,
          failWithQuota: {
            for (final m in GeminiModelPool.defaultCandidates) m,
          },
        ),
      );

      await expectLater(
        pool.generate(
          apiKey: 'kunci-uji',
          generationConfig: GenerationConfig(),
          contents: const [],
          context: 'uji',
        ),
        throwsA(
          isA<ServerFailure>().having(
            (f) => f.message,
            'message',
            allOf(
              contains('Batas pemakaian'),
              contains('cadangan'),
            ),
          ),
        ),
      );
      expect(
        calls,
        GeminiModelPool.defaultCandidates,
        reason: 'kuota tidak transient → tanpa putaran ulang',
      );
    });

    test('semua model sibuk (503) → ulang sekali lalu pesan sibuk', () async {
      final calls = <String>[];
      final pool = GeminiModelPool(
        retryDelay: Duration.zero,
        transport: _transport(
          calls: calls,
          failWithBusy: {
            for (final m in GeminiModelPool.defaultCandidates) m,
          },
        ),
      );

      await expectLater(
        pool.generate(
          apiKey: 'kunci-uji',
          generationConfig: GenerationConfig(),
          contents: const [],
          context: 'uji',
        ),
        throwsA(
          isA<ServerFailure>().having(
            (f) => f.message,
            'message',
            contains('sibuk'),
          ),
        ),
      );
      expect(
        calls.length,
        GeminiModelPool.defaultCandidates.length * 2,
        reason: 'error transient layak dicoba ulang sekali',
      );
    });

    test('timeout di model pertama → lanjut ke model berikutnya', () async {
      final calls = <String>[];
      final pool = GeminiModelPool(
        retryDelay: Duration.zero,
        transport: ({
          required String model,
          required String apiKey,
          required GenerationConfig generationConfig,
          required List<Content> contents,
        }) async {
          calls.add(model);
          if (model == GeminiModelPool.primaryModel) {
            await Future<void>.delayed(const Duration(milliseconds: 400));
          }
          return _ok();
        },
      );

      final response = await pool.generate(
        apiKey: 'kunci-uji',
        generationConfig: GenerationConfig(),
        contents: const [],
        context: 'uji',
        timeout: const Duration(milliseconds: 80),
      );

      expect(response.candidates, isEmpty);
      expect(calls, [GeminiModelPool.primaryModel, 'gemini-3.5-flash']);
      expect(pool.preferred, 'gemini-3.5-flash');
    });

    test('SEMUA model kena penalti tetap dicoba ulang (jangan buta)', () async {
      var now = DateTime(2026, 9, 25, 10);
      final calls = <String>[];
      final pool = GeminiModelPool(
        retryDelay: Duration.zero,
        clock: () => now,
        transport: _transport(
          calls: calls,
          failWithQuota: {
            for (final m in GeminiModelPool.defaultCandidates) m,
          },
        ),
      );
      await expectLater(
        pool.generate(
          apiKey: 'kunci-uji',
          generationConfig: GenerationConfig(),
          contents: const [],
          context: 'uji',
        ),
        throwsA(isA<ServerFailure>()),
      );
      expect(calls, GeminiModelPool.defaultCandidates);
      expect(pool.activeCandidates(), GeminiModelPool.defaultCandidates);

      // Lewat masa penalti (10 menit) → kandidat kembali normal.
      now = now.add(const Duration(minutes: 11));
      expect(pool.activeCandidates(), GeminiModelPool.defaultCandidates);
    });

    test('daftar kandidat memuat model yang terbukti hidup saat diagnosa',
        () async {
      expect(GeminiModelPool.primaryModel, 'gemini-3.6-flash');
      expect(
        GeminiModelPool.defaultCandidates,
        containsAll([
          'gemini-3.5-flash',
          'gemini-3.7-flash',
          'gemini-flash-latest',
          'gemini-flash-lite-latest',
        ]),
      );
      expect(
        GeminiModelPool.defaultCandidates.first,
        GeminiModelPool.primaryModel,
      );
    });
  });

  group('kindOf — klasifikasi error menentukan jalur failover', () {
    test('kuota asli server (429) → quota', () {
      expect(
        GeminiErrorMapper.kindOf(ServerException(_quotaError)),
        GeminiErrorKind.quota,
      );
    });

    test('server sibuk (503) → busy', () {
      expect(
        GeminiErrorMapper.kindOf(ServerException(_busyError)),
        GeminiErrorKind.busy,
      );
    });

    test('model ditarik (404) → retired', () {
      expect(
        GeminiErrorMapper.kindOf(
          ServerException(
            'This model models/gemini-2.5-flash is no longer available.',
          ),
        ),
        GeminiErrorKind.retired,
      );
    });

    test('kunci salah / wilayah → berhenti, bukan failover', () {
      expect(
        GeminiErrorMapper.kindOf(InvalidApiKey('API key not valid.')),
        GeminiErrorKind.config,
      );
      expect(
        GeminiErrorMapper.kindOf(
          ServerException('API key not valid. Please pass a valid API key.'),
        ),
        GeminiErrorKind.config,
      );
      expect(
        GeminiErrorMapper.kindOf(UnsupportedUserLocation()),
        GeminiErrorKind.location,
      );
    });

    test('timeout → timeout; safety → content; sisanya unknown', () {
      expect(
        GeminiErrorMapper.kindOf(TimeoutException('lambat')),
        GeminiErrorKind.timeout,
      );
      expect(
        GeminiErrorMapper.kindOf(
          ServerException('Prompt blocked by safety filters'),
        ),
        GeminiErrorKind.content,
      );
      expect(
        GeminiErrorMapper.kindOf(ServerException('teks aneh baru')),
        GeminiErrorKind.unknown,
      );
    });
  });

  group('finalFailure — pilih kegagalan paling informatif', () {
    test('isi ditolak menang atas kuota (bukan salah model)', () {
      final failure = GeminiErrorMapper.finalFailure([
        ServerException(_quotaError),
        ServerException('Prompt blocked by safety filters'),
      ]);
      expect(failure.message, contains('keamanan'));
      expect(failure.message, isNot(contains('Batas pemakaian')));
    });

    test('hanya timeout → NetworkFailure', () {
      final failure = GeminiErrorMapper.finalFailure([
        TimeoutException('lambat'),
      ]);
      expect(failure, isA<NetworkFailure>());
    });

    test('semua kuota → pesan kuota tetap memuat frasa wajib', () {
      final failure = GeminiErrorMapper.finalFailure([
        ServerException(_quotaError),
        ServerException(_quotaError),
      ]);
      expect(failure.message, contains('Batas pemakaian'));
      expect(failure.message, contains('1–2 menit'));
      expect(failure.message, contains('kunci baru'));
      expect(failure.message, contains('cadangan'));
    });

    test('daftar kosong → ServerFailure generik terkontrol', () {
      final failure = GeminiErrorMapper.finalFailure([]);
      expect(failure, isA<ServerFailure>());
    });
  });

  group('Regresi konfigurasi — akar masalah jawaban terpotong', () {
    test('teks: maxOutputTokens 2048 (512 lama mematikan JSON thinking)',
        () {
      final datasource = GeminiTextDatasource(apiKey: 'kunci-uji');
      expect(GeminiTextDatasource.maxOutputTokens, 2048);
      expect(
        datasource.generationConfig.maxOutputTokens,
        greaterThanOrEqualTo(2048),
      );
      expect(datasource.generationConfig.responseMimeType, 'application/json');
      expect(GeminiTextDatasource.defaultModelName, 'gemini-3.6-flash');
    });

    test('chat: maxOutputTokens 2048 agar jawaban tidak terpotong', () {
      final datasource = GeminiChatDatasource(apiKey: 'kunci-uji');
      expect(
        datasource.generationConfig.maxOutputTokens,
        greaterThanOrEqualTo(2048),
      );
      expect(datasource.generationConfig.temperature, 0.7);
    });

    test('gambar: maxOutputTokens 2048 + JSON verdict', () {
      final datasource = GeminiVisionDatasource(apiKey: 'kunci-uji');
      expect(
        datasource.generationConfig.maxOutputTokens,
        greaterThanOrEqualTo(2048),
      );
      expect(datasource.generationConfig.responseMimeType, 'application/json');
    });

    test('emptyResponseMessage: MAX_TOKENS → pesan terpotong, bukan generik',
        () {
      final truncated = GenerateContentResponse(
        [
          Candidate(
            Content.text('{"verdict":'),
            null,
            null,
            FinishReason.maxTokens,
            null,
          ),
        ],
        null,
      );
      expect(
        GeminiErrorMapper.emptyResponseMessage(truncated),
        contains('terpotong'),
      );

      final empty = GenerateContentResponse(const [], null);
      expect(
        GeminiErrorMapper.emptyResponseMessage(empty),
        'Server AI tidak mengembalikan hasil. Coba lagi.',
      );
      expect(
        GeminiErrorMapper.emptyResponseMessage(
          empty,
          emptyMessage: 'Server AI tidak mengembalikan jawaban. Coba lagi.',
        ),
        'Server AI tidak mengembalikan jawaban. Coba lagi.',
      );
    });
  });
}
