import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:literasi_ai/core/errors/failures.dart';
import 'package:literasi_ai/core/utils/share_service.dart';
import 'package:literasi_ai/features/quick_check/domain/entities/image_attachment.dart';
import 'package:literasi_ai/features/quick_check/domain/entities/verification_result.dart';
import 'package:literasi_ai/features/quick_check/domain/repositories/verification_repository.dart';
import 'package:literasi_ai/features/quick_check/domain/usecases/verify_url_claim.dart';
import 'package:literasi_ai/features/quick_check/presentation/providers/verification_provider.dart';
import 'package:literasi_ai/features/quick_check/presentation/screens/quick_check_home_tab.dart';
import 'package:literasi_ai/features/quick_check/presentation/screens/quick_check_session_screen.dart';
import 'package:literasi_ai/features/quick_check/presentation/widgets/quick_check_result_section.dart';
import 'package:literasi_ai/features/quick_check/presentation/widgets/share_card.dart';
import 'package:literasi_ai/features/quick_check/presentation/widgets/verdict_presentation.dart';
import 'package:share_plus/share_plus.dart';

VerificationResult _urlResult({String url = 'https://contoh.id/berita'}) {
  return VerificationResult(
    claim: 'Judul uji artikel.',
    verdict: Verdict.perluDicek,
    confidence: 64,
    explanation: 'Penjelasan uji link.',
    suggestion: 'Saran uji link.',
    checkedAt: DateTime(2026, 9, 16),
    source: VerificationSource.url,
    sourceUrl: url,
    sourceTitle: 'Judul uji artikel.',
  );
}

class _FakeUrlRepository implements VerificationRepository {
  _FakeUrlRepository({this.failure, this.delay});

  final Object? failure;
  final Duration? delay;
  int urlCalls = 0;
  String? lastUrl;

  @override
  Future<VerificationResult> verifyTextClaim(String claim) {
    throw UnimplementedError();
  }

  @override
  Future<VerificationResult> verifyImageClaim({
    required ImageAttachment image,
    String caption = '',
  }) {
    throw UnimplementedError();
  }

  @override
  Future<VerificationResult> verifyUrlClaim({required String url}) async {
    urlCalls++;
    lastUrl = url;
    if (delay != null) await Future.delayed(delay!);
    if (failure != null) throw failure!;
    return _urlResult(url: url);
  }
}

void main() {
  group('VerifyUrlClaim', () {
    test('rejects too short url', () async {
      await expectLater(
        () => VerifyUrlClaim(_FakeUrlRepository()).call('http://a'),
        throwsA(isA<UnknownFailure>()),
      );
    });

    test('rejects non http scheme', () async {
      await expectLater(
        () => VerifyUrlClaim(
          _FakeUrlRepository(),
        ).call('ftp://contoh.id/berita-penting-sekali-ya'),
        throwsA(isA<UnknownFailure>()),
      );
    });

    test('rejects url without authority', () async {
      await expectLater(
        () => VerifyUrlClaim(_FakeUrlRepository()).call('https://'),
        throwsA(isA<UnknownFailure>()),
      );
    });

    test('trims whitespace before repository call', () async {
      final repo = _FakeUrlRepository();
      final result = await VerifyUrlClaim(
        repo,
      ).call('  https://contoh.id/berita-penting  ');

      expect(repo.urlCalls, 1);
      expect(repo.lastUrl, 'https://contoh.id/berita-penting');
      expect(result.source, VerificationSource.url);
      expect(result.sourceUrl, 'https://contoh.id/berita-penting');
    });

    test('passes uppercase scheme', () async {
      final repo = _FakeUrlRepository();
      await VerifyUrlClaim(repo).call('HTTPS://contoh.id/berita-penting');

      expect(repo.urlCalls, 1);
    });

    test('isParsable mirrors usecase validation', () {
      expect(VerifyUrlClaim.isParsable('https://contoh.id/berita'), isTrue);
      expect(VerifyUrlClaim.isParsable('bukan-link'), isFalse);
      expect(VerifyUrlClaim.isParsable('ftp://contoh.id/berita'), isFalse);
      expect(VerifyUrlClaim.isParsable('https://'), isFalse);
    });

    test('normalize strips inner whitespace', () {
      expect(
        VerifyUrlClaim.normalize('  https://contoh.id/berita  '),
        'https://contoh.id/berita',
      );
    });
  });

  group('QuickCheckController url', () {
    test('verifyUrl stores url source', () async {
      final container = ProviderContainer(
        overrides: [
          verificationRepositoryProvider.overrideWithValue(
            _FakeUrlRepository(),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container
          .read(quickCheckControllerProvider.notifier)
          .verifyUrl('https://contoh.id/berita-penting');

      final state = container.read(quickCheckControllerProvider);
      expect(state.hasValue, isTrue);
      expect(state.value?.source, VerificationSource.url);
      expect(
        state.value?.sourceUrl,
        'https://contoh.id/berita-penting',
      );
    });

    test('retry reuses last url after failure', () async {
      final repo = _FakeUrlRepository(failure: const NetworkFailure());
      final container = ProviderContainer(
        overrides: [verificationRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);

      final notifier = container.read(quickCheckControllerProvider.notifier);
      await notifier.verifyUrl('https://contoh.id/berita-penting');
      await notifier.retry();

      expect(repo.urlCalls, 2);
    });
  });

  group('ShareService', () {
    test('buildShareText contains verdict and disclaimer', () {
      final text = ShareService.buildShareText(_urlResult());

      expect(text, contains('PERLU DICEK'));
      expect(text, contains('64%'));
      expect(text, contains('LiterasiAI'));
    });

    test('shareImage sends png file via share fn', () async {
      ShareParams? captured;
      final service = ShareService(
        shareFn: (params) async {
          captured = params;
          return const ShareResult('', ShareResultStatus.success);
        },
      );

      await service.shareImage(
        imageBytes: Uint8List.fromList([1, 2, 3]),
        text: 'teks uji',
      );

      expect(captured, isNotNull);
      expect(captured!.files, isNotNull);
      expect(captured!.files!, hasLength(1));
      expect(captured!.files!.first.mimeType, 'image/png');
    });

    test('shareImage rejects empty bytes', () {
      final service = ShareService(
        shareFn: (params) async =>
            const ShareResult('', ShareResultStatus.success),
      );

      expect(
        () => service.shareImage(
          imageBytes: Uint8List(0),
          text: 'teks uji',
        ),
        throwsArgumentError,
      );
    });
  });

  group('VerdictPresentation', () {
    test('maps all verdicts to distinct accents', () {
      final accents = Verdict.values
          .map((v) => VerdictPresentation.of(v).accent)
          .toSet();

      expect(accents, hasLength(4));
    });
  });

  testWidgets('landing url banner opens url session', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: QuickCheckHomeTab())),
    );
    await tester.pumpAndSettle();

    final banner = find.text('Cek link');
    await tester.ensureVisible(banner);
    await tester.pumpAndSettle();
    await tester.tap(banner);
    await tester.pumpAndSettle();

    expect(find.byType(QuickCheckSessionScreen), findsOneWidget);
    expect(find.text('Link artikel yang diperiksa'), findsOneWidget);
    expect(find.text('Teks'), findsOneWidget);
    expect(find.text('Gambar'), findsOneWidget);
    expect(find.text('Link'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('session url mode shows analyzing then url result', (
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
            _FakeUrlRepository(delay: const Duration(milliseconds: 300)),
          ),
        ],
        child: const MaterialApp(
          home: QuickCheckSessionScreen(initialMode: QuickCheckInitialMode.url),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final field = find.byType(TextField);
    await tester.enterText(field, 'https://contoh.id/berita-penting');
    await tester.pump();

    final verifyFinder = find.text('Verifikasi Sekarang');
    await tester.ensureVisible(verifyFinder);
    await tester.pumpAndSettle();
    await tester.tap(verifyFinder);
    await tester.pump();

    expect(find.text('Memuat link'), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.byType(QuickCheckResultSection), findsOneWidget);
    expect(find.text('Sumber: Link'), findsOneWidget);
    expect(
      find.text('Link diperiksa: https://contoh.id/berita-penting'),
      findsOneWidget,
    );
    expect(find.text('Bagikan Hasil'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('session url mode rejects invalid link locally', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          verificationRepositoryProvider.overrideWithValue(
            _FakeUrlRepository(),
          ),
        ],
        child: const MaterialApp(
          home: QuickCheckSessionScreen(initialMode: QuickCheckInitialMode.url),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextField),
      'bukan-link-artikel-sama-sekali',
    );
    await tester.pump();

    final verifyFinder = find.text('Verifikasi Sekarang');
    await tester.ensureVisible(verifyFinder);
    await tester.pumpAndSettle();
    await tester.tap(verifyFinder);
    await tester.pumpAndSettle();

    expect(find.textContaining('Link tidak valid'), findsOneWidget);
    expect(find.byType(QuickCheckResultSection), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('share button captures image and calls share fn', (
    WidgetTester tester,
  ) async {
    var shared = 0;
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: QuickCheckResultSection(
              result: _urlResult(),
              loading: false,
              onNewCheck: () {},
              shareService: ShareService(
                shareFn: (params) async {
                  shared++;
                  return const ShareResult('', ShareResultStatus.success);
                },
              ),
              onCaptureImage: () async =>
                  Uint8List.fromList(List.filled(16, 7)),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final shareFinder = find.text('Bagikan Hasil');
    await tester.ensureVisible(shareFinder);
    await tester.pumpAndSettle();
    await tester.tap(shareFinder);
    await tester.pumpAndSettle();

    expect(shared, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('share card renders verdict brand and claim', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(child: ShareCard(result: _urlResult())),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('PERLU DICEK'), findsOneWidget);
    expect(find.text('64%'), findsOneWidget);
    expect(find.text('LiterasiAI'), findsWidgets);
    expect(find.text('Cek sendiri di LiterasiAI'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
