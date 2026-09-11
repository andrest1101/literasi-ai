import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:literasi_ai/core/errors/failures.dart';
import 'package:literasi_ai/features/quick_check/data/models/verification_result_model.dart';
import 'package:literasi_ai/features/quick_check/domain/entities/image_attachment.dart';
import 'package:literasi_ai/features/quick_check/domain/entities/verification_result.dart';
import 'package:literasi_ai/features/quick_check/domain/repositories/verification_repository.dart';
import 'package:literasi_ai/features/quick_check/domain/usecases/verify_claim.dart';
import 'package:literasi_ai/features/quick_check/presentation/providers/verification_provider.dart';

class _FakeRepository implements VerificationRepository {
  _FakeRepository({this.failure});

  final Object? failure;
  int calls = 0;

  @override
  Future<VerificationResult> verifyTextClaim(String claim) async {
    calls++;
    if (failure != null) throw failure!;
    return VerificationResult(
      claim: claim,
      verdict: Verdict.valid,
      confidence: 90,
      explanation: 'Penjelasan uji.',
      suggestion: 'Saran uji.',
      checkedAt: DateTime(2026, 9, 11),
    );
  }

  @override
  Future<VerificationResult> verifyImageClaim({
    required ImageAttachment image,
    String caption = '',
  }) async {
    calls++;
    if (failure != null) throw failure!;
    return VerificationResult(
      claim: caption.isEmpty ? 'Gambar: ${image.fileName}' : caption,
      verdict: Verdict.valid,
      confidence: 90,
      explanation: 'Penjelasan uji.',
      suggestion: 'Saran uji.',
      checkedAt: DateTime(2026, 9, 11),
      source: VerificationSource.image,
      imageFileName: image.fileName,
    );
  }
}

void main() {
  group('VerificationResultModel', () {
    const claim = 'Klaim uji yang cukup panjang untuk validasi.';

    test('parses valid JSON', () {
      final result = VerificationResultModel.fromRawText(
        '{"verdict":"HOAKS","confidence":87,'
        '"explanation":"Penjelasan dua kalimat.","suggestion":"Cek sumber resmi."}',
        claim,
      );

      expect(result.verdict, Verdict.hoaks);
      expect(result.confidence, 87);
      expect(result.claim, claim);
    });

    test('parses JSON wrapped in markdown fence', () {
      final result = VerificationResultModel.fromRawText(
        '```json\n{"verdict":"PERLU_DICEK","confidence":64,'
        '"explanation":"Butuh sumber tambahan.","suggestion":"Cek media arus utama."}\n```',
        claim,
      );

      expect(result.verdict, Verdict.perluDicek);
      expect(result.confidence, 64);
    });

    test('treats unknown verdict as parsing failure', () {
      expect(
        () => VerificationResultModel.fromRawText(
          '{"verdict":"MUNGKIN","confidence":50,'
          '"explanation":"x","suggestion":"y"}',
          claim,
        ),
        throwsA(isA<ParsingFailure>()),
      );
    });

    test('rejects confidence outside 0-100', () {
      expect(
        () => VerificationResultModel.fromRawText(
          '{"verdict":"VALID","confidence":120,'
          '"explanation":"x","suggestion":"y"}',
          claim,
        ),
        throwsA(isA<ParsingFailure>()),
      );
    });

    test('rejects empty raw text', () {
      expect(
        () => VerificationResultModel.fromRawText('   ', claim),
        throwsA(isA<ParsingFailure>()),
      );
    });

    test('rejects empty explanation', () {
      expect(
        () => VerificationResultModel.fromRawText(
          '{"verdict":"VALID","confidence":80,"explanation":" ","suggestion":"y"}',
          claim,
        ),
        throwsA(isA<ParsingFailure>()),
      );
    });
  });

  group('VerifyClaim usecase', () {
    test('rejects too short claim', () async {
      final usecase = VerifyClaim(_FakeRepository());

      await expectLater(
        () => usecase('pendek'),
        throwsA(isA<UnknownFailure>()),
      );
    });

    test('rejects too long claim', () async {
      final usecase = VerifyClaim(_FakeRepository());
      final long = List.filled(2001, 'a').join();

      await expectLater(() => usecase(long), throwsA(isA<UnknownFailure>()));
    });

    test('normalizes whitespace before repository call', () async {
      final repo = _FakeRepository();
      final usecase = VerifyClaim(repo);

      final result = await usecase('  klaim   dengan   spasi  cukup panjang  ');

      expect(repo.calls, 1);
      expect(result.claim, 'klaim dengan spasi cukup panjang');
    });
  });

  group('QuickCheckController', () {
    test('verify stores data result', () async {
      final container = ProviderContainer(
        overrides: [
          verificationRepositoryProvider.overrideWithValue(_FakeRepository()),
        ],
      );
      addTearDown(container.dispose);

      await container
          .read(quickCheckControllerProvider.notifier)
          .verify('Klaim uji yang cukup panjang untuk validasi.');

      final state = container.read(quickCheckControllerProvider);
      expect(state.hasValue, isTrue);
      expect(state.value?.verdict, Verdict.valid);
    });

    test('verify surfaces failure as error state', () async {
      final container = ProviderContainer(
        overrides: [
          verificationRepositoryProvider.overrideWithValue(
            _FakeRepository(failure: const NetworkFailure()),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container
          .read(quickCheckControllerProvider.notifier)
          .verify('Klaim uji yang cukup panjang untuk validasi.');

      final state = container.read(quickCheckControllerProvider);
      expect(state.hasError, isTrue);
      expect(state.error, isA<NetworkFailure>());
    });

    test('retry reuses last claim after failure', () async {
      final repo = _FakeRepository(failure: const NetworkFailure());
      final container = ProviderContainer(
        overrides: [verificationRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);

      final notifier = container.read(quickCheckControllerProvider.notifier);
      await notifier.verify('Klaim uji yang cukup panjang untuk validasi.');
      await notifier.retry();

      expect(repo.calls, 2);
    });
  });
}
