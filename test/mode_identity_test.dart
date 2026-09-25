import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:literasi_ai/core/constants/app_colors.dart';
import 'package:literasi_ai/features/quick_check/presentation/screens/quick_check_home_tab.dart';

/// Regresi U5: identitas visual per mode + entrance hero + CTA tetap jalan.
void main() {
  Future<void> pumpHome(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: const Scaffold(body: QuickCheckHomeTab()),
          onGenerateRoute: (settings) => MaterialPageRoute(
            builder: (_) => Scaffold(
              body: Text('rute: ${settings.name}'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// Warna medallion 44px di sekitar ikon mode.
  Color? medallionColor(WidgetTester tester, IconData icon) {
    final containers = find
        .byWidgetPredicate(
          (w) =>
              w is Container &&
              w.constraints?.maxWidth == 44 &&
              w.decoration is BoxDecoration,
        )
        .evaluate();
    for (final element in containers) {
      final container = element.widget as Container;
      final decoration = container.decoration as BoxDecoration;
      if (find
          .descendant(of: find.byWidget(container), matching: find.byIcon(icon))
          .evaluate()
          .isNotEmpty) {
        return decoration.color;
      }
    }
    return null;
  }

  group('Identitas mode + entrance U5', () {
    testWidgets('medallion teks biru, gambar biru-tua (alpha 10%)', (
      WidgetTester tester,
    ) async {
      await pumpHome(tester);
      expect(
        medallionColor(tester, Icons.text_snippet_outlined),
        AppColors.primary.withValues(alpha: 0.1),
      );
      expect(
        medallionColor(tester, Icons.image_outlined),
        AppColors.primaryDeep.withValues(alpha: 0.1),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('CTA hero ada animasi entrance + tap buka sesi', (
      WidgetTester tester,
    ) async {
      await pumpHome(tester);
      expect(find.byType(FadeTransition), findsWidgets);
      expect(find.byType(SlideTransition), findsWidgets);
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();
      expect(find.textContaining('/quick-check-session'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
