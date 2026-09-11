import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:literasi_ai/core/errors/failures.dart';
import 'package:literasi_ai/features/quick_check/domain/entities/image_attachment.dart';
import 'package:literasi_ai/features/quick_check/domain/entities/verification_result.dart';
import 'package:literasi_ai/features/quick_check/domain/repositories/image_picker_service.dart';
import 'package:literasi_ai/features/quick_check/domain/repositories/verification_repository.dart';
import 'package:literasi_ai/features/quick_check/domain/usecases/verify_image_claim.dart';
import 'package:literasi_ai/features/quick_check/presentation/providers/verification_provider.dart';
import 'package:literasi_ai/features/quick_check/presentation/screens/quick_check_session_screen.dart';
import 'package:literasi_ai/features/quick_check/presentation/widgets/quick_check_result_section.dart';

ImageAttachment _image({
  int bytes = 1024,
  String mime = 'image/jpeg',
  String name = 'klaim.png',
}) {
  return ImageAttachment(
    bytes: Uint8List.fromList(List.filled(bytes, 7)),
    mimeType: mime,
    fileName: name,
  );
}

class _FakeImageRepository implements VerificationRepository {
  _FakeImageRepository({this.failure});

  final Object? failure;
  int imageCalls = 0;

  @override
  Future<VerificationResult> verifyTextClaim(String claim) {
    throw UnimplementedError();
  }

  @override
  Future<VerificationResult> verifyImageClaim({
    required ImageAttachment image,
    String caption = '',
  }) async {
    imageCalls++;
    if (failure != null) throw failure!;
    return VerificationResult(
      claim: caption.isEmpty ? 'Gambar: ${image.fileName}' : caption,
      verdict: Verdict.perluDicek,
      confidence: 64,
      explanation: 'Penjelasan uji gambar.',
      suggestion: 'Saran uji gambar.',
      checkedAt: DateTime(2026, 9, 11),
      source: VerificationSource.image,
      imageFileName: image.fileName,
    );
  }
}

class _FakePicker implements ImagePickerService {
  _FakePicker(this.attachment);

  final ImageAttachment? attachment;

  @override
  Future<ImageAttachment?> pickImage(ImagePickSource source) async =>
      attachment;
}

void main() {
  group('ImageAttachment', () {
    test('accepts supported image within limit', () {
      expect(_image().isValid, isTrue);
      expect(_image().formattedSize, '1 KB');
    });

    test('rejects empty bytes', () {
      expect(_image(bytes: 0).isValid, isFalse);
    });

    test('rejects unsupported mime', () {
      expect(_image(mime: 'image/gif').isValid, isFalse);
    });

    test('rejects oversize image', () {
      expect(_image(bytes: ImageAttachment.maxBytes + 1).isValid, isFalse);
    });
  });

  group('VerifyImageClaim', () {
    test('accepts image without caption', () async {
      final repo = _FakeImageRepository();
      final result = await VerifyImageClaim(repo).call(image: _image());

      expect(repo.imageCalls, 1);
      expect(result.source, VerificationSource.image);
      expect(result.imageFileName, 'klaim.png');
    });

    test('accepts valid caption', () async {
      final repo = _FakeImageRepository();
      final result = await VerifyImageClaim(
        repo,
      ).call(image: _image(), caption: 'Caption uji yang cukup panjang.');

      expect(result.claim, 'Caption uji yang cukup panjang.');
    });

    test('rejects too short caption', () async {
      await expectLater(
        () => VerifyImageClaim(
          _FakeImageRepository(),
        ).call(image: _image(), caption: 'pendek'),
        throwsA(isA<UnknownFailure>()),
      );
    });

    test('rejects invalid image', () async {
      await expectLater(
        () => VerifyImageClaim(
          _FakeImageRepository(),
        ).call(image: _image(bytes: 0)),
        throwsA(isA<UnknownFailure>()),
      );
    });
  });

  group('QuickCheckController image', () {
    test('verifyImage stores source and filename', () async {
      final container = ProviderContainer(
        overrides: [
          verificationRepositoryProvider.overrideWithValue(
            _FakeImageRepository(),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container
          .read(quickCheckControllerProvider.notifier)
          .verifyImage(image: _image());

      final state = container.read(quickCheckControllerProvider);
      expect(state.hasValue, isTrue);
      expect(state.value?.source, VerificationSource.image);
      expect(state.value?.imageFileName, 'klaim.png');
    });

    test('retry reuses last image after failure', () async {
      final repo = _FakeImageRepository(failure: const NetworkFailure());
      final container = ProviderContainer(
        overrides: [verificationRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);

      final notifier = container.read(quickCheckControllerProvider.notifier);
      await notifier.verifyImage(image: _image());
      await notifier.retry();

      expect(repo.imageCalls, 2);
    });
  });

  testWidgets('image mode pick, verify, and source label', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          verificationRepositoryProvider.overrideWithValue(
            _FakeImageRepository(),
          ),
          imagePickerServiceProvider.overrideWithValue(_FakePicker(_image())),
        ],
        child: const MaterialApp(home: QuickCheckSessionScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Gambar'));
    await tester.pumpAndSettle();
    expect(find.text('Gambar klaim'), findsOneWidget);

    final galleryFinder = find.text('Galeri').first;
    await tester.ensureVisible(galleryFinder);
    await tester.pumpAndSettle();
    await tester.tap(galleryFinder);
    await tester.pumpAndSettle();
    expect(find.text('klaim.png'), findsOneWidget);

    final verifyFinder = find.text('Verifikasi Sekarang');
    await tester.ensureVisible(verifyFinder);
    await tester.pumpAndSettle();
    await tester.tap(verifyFinder);
    await tester.pumpAndSettle();

    expect(find.byType(QuickCheckResultSection), findsOneWidget);
    expect(find.text('PERLU DICEK'), findsOneWidget);
    expect(find.text('SUMBER: GAMBAR'), findsOneWidget);
    expect(find.text('Gambar terlampir: klaim.png'), findsOneWidget);
  });

  testWidgets('image verify disabled without attachment', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: QuickCheckSessionScreen())),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Gambar'));
    await tester.pumpAndSettle();

    final buttonFinder = find.ancestor(
      of: find.text('Verifikasi Sekarang'),
      matching: find.byWidgetPredicate((w) => w is FilledButton),
    );
    expect(tester.widget<FilledButton>(buttonFinder).onPressed, isNull);
  });
}
