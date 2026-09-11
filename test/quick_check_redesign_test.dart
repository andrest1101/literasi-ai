import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:literasi_ai/features/quick_check/domain/entities/image_attachment.dart';
import 'package:literasi_ai/features/quick_check/domain/entities/verification_result.dart';
import 'package:literasi_ai/features/quick_check/domain/repositories/verification_repository.dart';
import 'package:literasi_ai/features/quick_check/presentation/providers/verification_provider.dart';
import 'package:literasi_ai/features/quick_check/presentation/screens/quick_check_home_tab.dart';
import 'package:literasi_ai/features/quick_check/presentation/screens/quick_check_session_screen.dart';
import 'package:literasi_ai/features/quick_check/presentation/widgets/quick_check_analyzing_indicator.dart';
import 'package:literasi_ai/features/quick_check/presentation/widgets/quick_check_input_section.dart';
import 'package:literasi_ai/features/quick_check/presentation/widgets/quick_check_result_section.dart';

class _FakeRepository implements VerificationRepository {
  _FakeRepository({this.delay});

  final Duration? delay;

  @override
  Future<VerificationResult> verifyTextClaim(String claim) async {
    if (delay != null) await Future.delayed(delay!);
    return VerificationResult(
      claim: claim,
      verdict: Verdict.valid,
      confidence: 92,
      explanation: 'Penjelasan uji untuk redesign.',
      suggestion: 'Saran uji untuk redesign.',
      checkedAt: DateTime(2026, 9, 11),
    );
  }

  @override
  Future<VerificationResult> verifyImageClaim({
    required ImageAttachment image,
    String caption = '',
  }) async {
    if (delay != null) await Future.delayed(delay!);
    return VerificationResult(
      claim: caption.isEmpty ? 'Gambar: ${image.fileName}' : caption,
      verdict: Verdict.valid,
      confidence: 92,
      explanation: 'Penjelasan uji untuk redesign.',
      suggestion: 'Saran uji untuk redesign.',
      checkedAt: DateTime(2026, 9, 11),
      source: VerificationSource.image,
      imageFileName: image.fileName,
    );
  }
}

void main() {
  testWidgets('landing CTA opens dedicated session screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: const Scaffold(body: QuickCheckHomeTab()),
          routes: {
            QuickCheckSessionScreen.route: (_) =>
                const QuickCheckSessionScreen(),
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Cek kebenaran sebelum sebar'), findsOneWidget);
    await tester.tap(find.text('Mulai Pemeriksaan'));
    await tester.pumpAndSettle();

    expect(find.byType(QuickCheckSessionScreen), findsOneWidget);
    expect(find.byType(QuickCheckInputSection), findsOneWidget);
    expect(find.text('Input'), findsOneWidget);
    expect(find.text('Analisis'), findsOneWidget);
    expect(find.text('Hasil'), findsOneWidget);
  });

  testWidgets('session shows analyzing indicator then result section', (
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
            _FakeRepository(delay: const Duration(milliseconds: 300)),
          ),
        ],
        child: const MaterialApp(home: QuickCheckSessionScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextField),
      'Klaim uji yang cukup panjang untuk redesign.',
    );
    await tester.pump();
    final verifyFinder = find.text('Verifikasi Sekarang');
    await tester.ensureVisible(verifyFinder);
    await tester.pumpAndSettle();
    await tester.tap(verifyFinder);
    await tester.pump();

    expect(find.byType(QuickCheckAnalyzingIndicator), findsOneWidget);
    expect(find.text('Menilai bukti'), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.byType(QuickCheckResultSection), findsOneWidget);
    expect(find.text('VALID'), findsOneWidget);
    expect(find.text('92%'), findsOneWidget);
  });

  testWidgets('all verdict styles render without exception', (
    WidgetTester tester,
  ) async {
    const verdicts = [
      Verdict.hoaks,
      Verdict.valid,
      Verdict.perluDicek,
      Verdict.tidakDapatDipastikan,
    ];

    for (final verdict in verdicts) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: QuickCheckResultSection(
                result: VerificationResult(
                  claim: 'Klaim uji verdict.',
                  verdict: verdict,
                  confidence: 75,
                  explanation: 'Penjelasan uji.',
                  suggestion: 'Saran uji.',
                  checkedAt: DateTime(2026, 9, 11),
                ),
                loading: false,
                onNewCheck: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(QuickCheckResultSection), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });
}
