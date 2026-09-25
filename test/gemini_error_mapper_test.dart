import 'package:flutter_test/flutter_test.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:literasi_ai/core/errors/failures.dart';
import 'package:literasi_ai/core/utils/gemini_error_mapper.dart';

void main() {
  group('GeminiErrorMapper — pesan spesifik, bukan generik', () {
    test('tipe SDK InvalidApiKey → kunci ditolak', () {
      final failure = GeminiErrorMapper.map(
        InvalidApiKey('API key not valid.'),
      );
      expect(failure.message, contains('ditolak'));
      expect(failure.message, contains('AI Studio'));
    });

    test('tipe SDK UnsupportedUserLocation → ganti jaringan/VPN', () {
      final failure = GeminiErrorMapper.map(UnsupportedUserLocation());
      expect(failure.message, contains('VPN'));
    });

    test('kuota asli → pesan kuota actionable (bukan sekadar tunggu)', () {
      for (final raw in [
        'Quota exceeded for quota metric',
        'Rate limit hit, retry later',
        'Server Error [429]: slow down',
        'Resource exhausted: daily limit reached',
      ]) {
        final failure = GeminiErrorMapper.map(ServerException(raw));
        expect(failure.message, contains('Batas pemakaian'), reason: raw);
        expect(failure.message, contains('1–2 menit'), reason: raw);
        expect(failure.message, contains('kunci baru'), reason: raw);
      }
    });

    test('false positive: kata generate/separate BUKAN kuota', () {
      for (final raw in [
        'Failed to generate content upstream',
        'Separate backend error occurred',
        'Regenerate response failed with code 500',
      ]) {
        final failure = GeminiErrorMapper.map(ServerException(raw));
        expect(
          failure.message,
          isNot(contains('Batas pemakaian')),
          reason: raw,
        );
      }
    });

    test('safety/block → ubah redaksi', () {
      final failure = GeminiErrorMapper.map(
        ServerException('Prompt blocked by safety filters'),
      );
      expect(failure.message, contains('keamanan'));
    });

    test('model tak dikenal/404/ditarik → model tidak ditemukan', () {
      for (final raw in [
        'Server Error [404]: model not found',
        'Unknown model gemini-9.9-turbo',
        'This model models/gemini-2.0-flash is no longer available. '
            'Please update your code to use models/gemini-3.6-flash.',
      ]) {
        final failure = GeminiErrorMapper.map(ServerException(raw));
        expect(failure.message, contains('Model AI'), reason: raw);
      }
    });

    test('permission/403 → aktifkan API di console', () {
      final failure = GeminiErrorMapper.map(
        ServerException('Permission denied [403]: API not enabled'),
      );
      expect(failure.message, contains('Google Cloud Console'));
    });

    test('billing/account → periksa project', () {
      final failure = GeminiErrorMapper.map(
        ServerException('Billing account disabled for project'),
      );
      expect(failure.message, contains('billing'));
    });

    test('api disabled → aktifkan + tunggu', () {
      final failure = GeminiErrorMapper.map(
        ServerException(
          'Generative Language API has not been used in project before. '
          'Enable it by visiting console.',
        ),
      );
      expect(failure.message, contains('belum aktif'));
    });

    test('server sibuk 503/overloaded → tunggu 1 menit', () {
      for (final raw in [
        'Server Error [503]: This model is currently experiencing high demand. Try again later.',
        'Model overloaded, tryagain later please',
        'Server Error [502]: backend error, try again',
      ]) {
        final failure = GeminiErrorMapper.map(ServerException(raw));
        expect(failure.message, contains('sibuk'), reason: raw);
        expect(failure.message, contains('1 menit'), reason: raw);
      }
    });

    test('isTransient: sibuk true; kuota/kunci/permission false', () {
      expect(
        GeminiErrorMapper.isTransient(
          ServerException('Server Error [503]: overloaded'),
        ),
        isTrue,
      );
      // Kuota SENGAJA non-transient: retry 3 detik tidak mengisi kuota.
      expect(
        GeminiErrorMapper.isTransient(
          ServerException('Quota exceeded, slow down'),
        ),
        isFalse,
      );
      expect(
        GeminiErrorMapper.isTransient(
          ServerException('Server Error [429]: rate limit'),
        ),
        isFalse,
      );
      expect(
        GeminiErrorMapper.isTransient(InvalidApiKey('API key not valid.')),
        isFalse,
      );
      expect(
        GeminiErrorMapper.isTransient(
          ServerException('Permission denied [403]'),
        ),
        isFalse,
      );
      expect(GeminiErrorMapper.isTransient(Exception('acak')), isFalse);
    });

    test('tak dikenal → cuplikan raw, bukan generik buta', () {
      const raw = 'Weird new server behavior xyz-123 happened upstream';
      final failure = GeminiErrorMapper.map(ServerException(raw));
      expect(failure.message, contains('di luar dugaan'));
      expect(failure.message, contains('xyz-123'));
      expect(failure.message, isNot('Server AI tidak merespons, coba lagi.'));
    });

    test('pesan kosong → fallback generik lama', () {
      final failure = GeminiErrorMapper.map(ServerException(''));
      expect(failure.message, 'Server AI tidak merespons, coba lagi.');
    });

    test('mapAny: error non-SDK → tak terduga + cuplikan, bukan generik', () {
      final failure = GeminiErrorMapper.mapAny(
        FormatException('Unexpected token xyz-999 at 1:1'),
      );
      expect(failure, isA<ServerFailure>());
      expect(failure.message, contains('tak terduga'));
      expect(failure.message, contains('xyz-999'));
      expect(
        failure.message,
        isNot('Server AI tidak merespons, coba lagi.'),
      );
    });

    test('mapAny: Failure diteruskan utuh', () {
      const original = NetworkFailure();
      expect(GeminiErrorMapper.mapAny(original), same(original));
    });

    test('mapAny: GenerativeAIException dipetakan normal', () {
      final failure = GeminiErrorMapper.mapAny(
        InvalidApiKey('API key not valid.'),
      );
      expect(failure, isA<ServerFailure>());
      expect(failure.message, contains('ditolak'));
    });
  });
}
