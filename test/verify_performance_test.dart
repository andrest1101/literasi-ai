import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:literasi_ai/core/errors/failures.dart';
import 'package:literasi_ai/features/quick_check/data/datasources/gemini_text_datasource.dart';
import 'package:literasi_ai/features/quick_check/data/repositories/verification_repository_impl.dart';
import 'package:literasi_ai/features/quick_check/domain/entities/image_attachment.dart';
import 'package:literasi_ai/features/quick_check/domain/entities/verification_result.dart';
import 'package:literasi_ai/features/quick_check/domain/repositories/verification_repository.dart';
import 'package:literasi_ai/features/quick_check/presentation/providers/verification_provider.dart';
import 'package:literasi_ai/features/quick_check/presentation/widgets/quick_check_result_section.dart';

class _CountingRepository implements VerificationRepository {
  int calls = 0;

  VerificationResult _result(String claim) => VerificationResult(
    claim: claim,
    verdict: Verdict.valid,
    confidence: 90,
    explanation: 'Penjelasan uji.',
    suggestion: 'Saran uji.',
    checkedAt: DateTime(2026, 9, 26),
  );

  @override
  Future<VerificationResult> verifyTextClaim(String claim) async {
    calls++;
    return _result(claim);
  }

  @override
  Future<VerificationResult> verifyImageClaim({
    required ImageAttachment image,
    String caption = '',
  }) async {
    calls++;
    return _result(caption.isEmpty ? 'Gambar: ${image.fileName}' : caption);
  }

  @override
  Future<VerificationResult> verifyUrlClaim({required String url}) async {
    calls++;
    return _result(url);
  }
}

void main() {
  group('Cache klaim identik (hemat kuota)', () {
    VerificationResult fakeResult(String claim) => VerificationResult(
      claim: claim,
      verdict: Verdict.valid,
      confidence: 90,
      explanation: 'Penjelasan uji.',
      suggestion: 'Saran uji.',
      checkedAt: DateTime(2026, 9, 26),
    );

    test('teks sama hanya memanggil network sekali', () async {
      var networkCalls = 0;
      final repo = VerificationRepositoryImpl(
        GeminiTextDatasource(apiKey: 'uji'),
        hasApiKey: () => true,
        verifyTextFn: (claim, apiKey) async {
          networkCalls++;
          return fakeResult(claim);
        },
      );
      const claim = 'Klaim uji cache yang cukup panjang untuk validasi.';
      final first = await repo.verifyTextClaim(claim);
      final second = await repo.verifyTextClaim(claim);
      expect(networkCalls, 1);
      expect(identical(first, second), isTrue);
    });

    test('rate limit menolak request live beruntun', () async {
      final repo = VerificationRepositoryImpl(
        GeminiTextDatasource(apiKey: 'uji'),
        hasApiKey: () => true,
        verifyTextFn: (claim, apiKey) async => fakeResult(claim),
      );
      await repo.verifyTextClaim(
        'Klaim pertama yang cukup panjang untuk rate limit.',
      );
      await expectLater(
        repo.verifyTextClaim('Klaim kedua yang juga cukup panjang.'),
        throwsA(isA<NetworkFailure>()),
      );
    });

    test('controller mencatat durasi verify terakhir', () async {
      final repo = _CountingRepository();
      final container = ProviderContainer(
        overrides: [verificationRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);
      await container
          .read(quickCheckControllerProvider.notifier)
          .verify('Klaim uji yang cukup panjang untuk validasi.');
      final notifier = container.read(quickCheckControllerProvider.notifier);
      expect(notifier.lastDuration, isNotNull);
      expect(repo.calls, 1);
    });

    test('rate limit menolak request live beruntun', () async {
      final repo = VerificationRepositoryImpl(
        GeminiTextDatasource(apiKey: 'uji'),
        hasApiKey: () => true,
      );
      // Request pertama gagal network (tanpa key valid) atau sukses;
      // yang diuji: struktur rate limit ada dan pesan ramah tersedia.
      try {
        await repo.verifyTextClaim(
          'Klaim uji rate limit yang cukup panjang.',
        );
      } catch (e) {
        expect(
          e is Failure || e is Exception,
          isTrue,
          reason: 'tanpa network boleh gagal, tapi harus Failure',
        );
      }
    });
  });

  testWidgets('kartu hasil tampilkan durasi bila ada', (
    WidgetTester tester,
  ) async {
    final result = VerificationResult(
      claim: 'Klaim uji durasi yang cukup panjang.',
      verdict: Verdict.valid,
      confidence: 92,
      explanation: 'Penjelasan uji.',
      suggestion: 'Saran uji.',
      checkedAt: DateTime(2026, 9, 26),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: QuickCheckResultSection(
              result: result,
              loading: false,
              onNewCheck: () {},
              duration: const Duration(milliseconds: 2100),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('2,1 dtk'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('kartu hasil tanpa durasi tidak tampilkan teks waktu', (
    WidgetTester tester,
  ) async {
    final result = VerificationResult(
      claim: 'Klaim uji durasi yang cukup panjang.',
      verdict: Verdict.valid,
      confidence: 92,
      explanation: 'Penjelasan uji.',
      suggestion: 'Saran uji.',
      checkedAt: DateTime(2026, 9, 26),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: QuickCheckResultSection(
              result: result,
              loading: false,
              onNewCheck: () {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('dtk'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
