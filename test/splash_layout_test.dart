import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:literasi_ai/core/constants/app_strings.dart';
import 'package:literasi_ai/features/auth/domain/repositories/onboarding_repository.dart';
import 'package:literasi_ai/features/auth/presentation/providers/onboarding_provider.dart';
import 'package:literasi_ai/main.dart';

class _FakeOnboardingRepository implements OnboardingRepository {
  @override
  Future<bool> isCompleted() async => false;

  @override
  Future<void> markCompleted() async {}
}

/// Regresi tata letak splash.
///
/// Dua keluhan nyata yang dikunci di sini:
///   * tagline 14sp selebar ~342dp hampir menyentuh tepi layar 360dp,
///   * mark splash punya margin transparan sehingga judul terdorong jauh.
void main() {
  Future<void> pumpSplash(WidgetTester tester, Size size) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = size;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          onboardingRepositoryProvider.overrideWith(
            (ref) => _FakeOnboardingRepository(),
          ),
        ],
        child: const LiterasiAIApp(),
      ),
    );
    await tester.pump();
  }

  /// Menuntaskan timer splash (2 detik) supaya tidak ada pending timer.
  Future<void> drainSplash(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
  }

  for (final width in <double>[320, 360, 411]) {
    testWidgets('tagline splash punya margin di layar ${width.toInt()}dp', (
      tester,
    ) async {
      await pumpSplash(tester, Size(width, 640));

      final tagline = tester.getRect(find.text(AppStrings.tagline));
      expect(
        tagline.left,
        greaterThanOrEqualTo(24),
        reason: 'tagline menempel ke tepi kiri',
      );
      expect(
        tagline.right,
        lessThanOrEqualTo(width - 24),
        reason: 'tagline menempel ke tepi kanan',
      );

      await drainSplash(tester);
    });
  }

  testWidgets('mark splash rapat ke judul tanpa margin transparan', (
    tester,
  ) async {
    await pumpSplash(tester, const Size(360, 640));

    final mark = tester.getRect(find.byType(Image));
    final title = tester.getRect(find.text(AppStrings.appName));

    // Aset 392x300 sudah rapat ke glyph: lebar 100dp = glyph ~98dp.
    expect(mark.width, closeTo(100, 0.5));
    // Jarak kotak mark ke judul hanya SizedBox 20dp (tanpa margin aset).
    expect(title.top - mark.bottom, closeTo(20, 0.5));

    await drainSplash(tester);
  });
}
