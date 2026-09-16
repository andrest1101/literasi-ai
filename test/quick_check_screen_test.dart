import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:literasi_ai/core/constants/app_colors.dart';
import 'package:literasi_ai/core/errors/failures.dart';
import 'package:literasi_ai/features/quick_check/domain/entities/image_attachment.dart';
import 'package:literasi_ai/features/quick_check/domain/entities/verification_result.dart';
import 'package:literasi_ai/features/quick_check/domain/repositories/verification_repository.dart';
import 'package:literasi_ai/features/quick_check/presentation/providers/verification_provider.dart';
import 'package:literasi_ai/features/quick_check/presentation/screens/quick_check_session_screen.dart';
import 'package:literasi_ai/features/quick_check/presentation/widgets/char_counter_text.dart';
import 'package:literasi_ai/features/quick_check/presentation/widgets/quick_check_result_section.dart';

class _FakeRepository implements VerificationRepository {
  _FakeRepository({this.result, this.failure, this.delay});

  final VerificationResult? result;
  final Object? failure;
  final Duration? delay;

  @override
  Future<VerificationResult> verifyTextClaim(String claim) async {
    if (delay != null) await Future.delayed(delay!);
    if (failure != null) throw failure!;
    return result ??
        VerificationResult(
          claim: claim,
          verdict: Verdict.hoaks,
          confidence: 87,
          explanation: 'Penjelasan dua kalimat untuk pengujian widget.',
          suggestion: 'Bandingkan dengan TurnBackHoax.',
          checkedAt: DateTime(2026, 9, 11),
        );
  }

  @override
  Future<VerificationResult> verifyImageClaim({
    required ImageAttachment image,
    String caption = '',
  }) async {
    if (delay != null) await Future.delayed(delay!);
    if (failure != null) throw failure!;
    return result ??
        VerificationResult(
          claim: caption.isEmpty ? 'Gambar: ${image.fileName}' : caption,
          verdict: Verdict.hoaks,
          confidence: 87,
          explanation: 'Penjelasan dua kalimat untuk pengujian widget.',
          suggestion: 'Bandingkan dengan TurnBackHoax.',
          checkedAt: DateTime(2026, 9, 11),
          source: VerificationSource.image,
          imageFileName: image.fileName,
        );
  }

  @override
  Future<VerificationResult> verifyUrlClaim({required String url}) async {
    if (delay != null) await Future.delayed(delay!);
    if (failure != null) throw failure!;
    return result ??
        VerificationResult(
          claim: url,
          verdict: Verdict.hoaks,
          confidence: 87,
          explanation: 'Penjelasan dua kalimat untuk pengujian widget.',
          suggestion: 'Bandingkan dengan TurnBackHoax.',
          checkedAt: DateTime(2026, 9, 11),
          source: VerificationSource.url,
          sourceUrl: url,
        );
  }
}

Future<void> _pumpQuickCheck(
  WidgetTester tester,
  VerificationRepository repository,
) async {
  tester.view.physicalSize = const Size(800, 1400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
  await tester.pumpWidget(
    ProviderScope(
      overrides: [verificationRepositoryProvider.overrideWithValue(repository)],
      child: const MaterialApp(home: QuickCheckSessionScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _tapVerify(WidgetTester tester) async {
  final finder = find.text('Verifikasi Sekarang');
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
}

void main() {
  test('character counter formats Indonesian thousands', () {
    expect(CharCounterText.format(0), '0');
    expect(CharCounterText.format(999), '999');
    expect(CharCounterText.format(2000), '2.000');
  });

  testWidgets('verify disabled for too short claim', (
    WidgetTester tester,
  ) async {
    await _pumpQuickCheck(tester, _FakeRepository());

    await tester.enterText(find.byType(TextField), 'pendek');
    await tester.pump();

    final buttonFinder = find.ancestor(
      of: find.text('Verifikasi Sekarang'),
      matching: find.byWidgetPredicate((w) => w is FilledButton),
    );
    final button = tester.widget<FilledButton>(buttonFinder);
    expect(button.onPressed, isNull);
  });

  testWidgets('verify button uses clean disabled palette', (
    WidgetTester tester,
  ) async {
    await _pumpQuickCheck(tester, _FakeRepository());

    await tester.enterText(find.byType(TextField), 'pendek');
    await tester.pump();

    final buttonFinder = find.ancestor(
      of: find.text('Verifikasi Sekarang'),
      matching: find.byWidgetPredicate((w) => w is FilledButton),
    );
    final button = tester.widget<FilledButton>(buttonFinder);
    final style = button.style;
    expect(style, isNotNull);
    expect(
      style!.backgroundColor!.resolve({WidgetState.disabled}),
      const Color(0xFFE8EDF5),
    );
    expect(
      style.foregroundColor!.resolve({WidgetState.disabled}),
      const Color(0xFF5B6B80),
    );
    expect(style.backgroundColor!.resolve({}), AppColors.primary);
    expect(style.animationDuration, const Duration(milliseconds: 250));
  });

  testWidgets('shows analyzing then verdict result', (
    WidgetTester tester,
  ) async {
    await _pumpQuickCheck(
      tester,
      _FakeRepository(delay: const Duration(milliseconds: 300)),
    );

    await tester.enterText(
      find.byType(TextField),
      'Klaim uji yang cukup panjang untuk validasi widget.',
    );
    await tester.pump();
    await _tapVerify(tester);
    await tester.pump();

    expect(find.text('Memahami informasi'), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.byType(QuickCheckResultSection), findsOneWidget);
    expect(find.text('HOAKS'), findsOneWidget);
    expect(find.text('87%'), findsOneWidget);
  });

  testWidgets('verify button disabled until claim long enough', (
    WidgetTester tester,
  ) async {
    await _pumpQuickCheck(tester, _FakeRepository());

    Finder verifyButton() {
      return find.ancestor(
        of: find.text('Verifikasi Sekarang'),
        matching: find.byWidgetPredicate((w) => w is FilledButton),
      );
    }

    // Klaim pendek: tombol nonaktif.
    await tester.enterText(find.byType(TextField), 'pendek');
    await tester.pump();
    var button = tester.widget<FilledButton>(verifyButton());
    expect(button.onPressed, isNull);

    // Klaim valid: tombol aktif.
    await tester.enterText(
      find.byType(TextField),
      'Klaim uji yang cukup panjang untuk validasi widget.',
    );
    await tester.pump();
    button = tester.widget<FilledButton>(verifyButton());
    expect(button.onPressed, isNotNull);
  });

  testWidgets('shows retryable error card on network failure', (
    WidgetTester tester,
  ) async {
    await _pumpQuickCheck(
      tester,
      _FakeRepository(failure: const NetworkFailure()),
    );

    await tester.enterText(
      find.byType(TextField),
      'Klaim uji yang cukup panjang untuk validasi widget.',
    );
    await tester.pump();
    await _tapVerify(tester);
    await tester.pumpAndSettle();

    expect(find.text('Verifikasi gagal'), findsOneWidget);
    expect(find.text('Koneksi lambat, coba lagi.'), findsOneWidget);
    expect(find.text('Coba lagi'), findsOneWidget);
  });

  testWidgets('uncertain verdict renders as success result', (
    WidgetTester tester,
  ) async {
    await _pumpQuickCheck(
      tester,
      _FakeRepository(
        result: VerificationResult.uncertain(
          'Klaim uji yang cukup panjang untuk validasi widget.',
        ),
      ),
    );

    await tester.enterText(
      find.byType(TextField),
      'Klaim uji yang cukup panjang untuk validasi widget.',
    );
    await tester.pump();
    await _tapVerify(tester);
    await tester.pumpAndSettle();

    expect(find.byType(QuickCheckResultSection), findsOneWidget);
    expect(find.text('TIDAK DAPAT DIPASTIKAN'), findsOneWidget);
    expect(find.text('Verifikasi gagal'), findsNothing);
  });
}
