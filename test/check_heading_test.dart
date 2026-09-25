import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:literasi_ai/features/quick_check/presentation/screens/quick_check_home_tab.dart';
import 'package:literasi_ai/features/quick_check/presentation/screens/quick_check_session_screen.dart';

/// Regresi P1: heading tab Cek ramping — tanpa wordmark, tanpa pill
/// eyebrow. Judul two-tone + subtitle padat + hairline; hero naik ke
/// lipatan layar 360×800.
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

  group('Heading compact P1', () {
    testWidgets('tanpa wordmark + pill, judul + subtitle tetap ada', (
      WidgetTester tester,
    ) async {
      await pumpHome(tester);
      expect(find.text('LiterasiAI'), findsNothing);
      expect(find.text('VERIFIKASI AI'), findsNothing);
      expect(find.text('Cek kebenaran'), findsOneWidget);
      expect(find.text('sebelum sebar.'), findsOneWidget);
      final accent = tester.widget<Text>(find.text('sebelum sebar.'));
      expect(accent.style?.fontStyle, FontStyle.italic);
      expect(tester.takeException(), isNull);
    });

    testWidgets('tinggi heading di bawah 150px (hemat ±80px)', (
      WidgetTester tester,
    ) async {
      await pumpHome(tester);
      final titleBox =
          tester.getRect(find.text('Cek kebenaran'));
      final subtitleBox = tester.getRect(
        find.textContaining('Satu sesi fokus'),
      );
      final headingHeight = subtitleBox.bottom - titleBox.top;
      expect(
        headingHeight,
        lessThan(150),
        reason: 'heading teks (judul + subtitle) harus ramping',
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('kartu hero mulai di atas lipatan 360×800', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      await pumpHome(tester);
      // Posisi global dengan scroll offset nol = posisi dalam viewport.
      final heroBox = tester.getRect(find.text('Siap memeriksa informasi?'));
      expect(
        heroBox.top,
        lessThan(800),
        reason: 'kartu hero harus mulai sebelum lipatan layar kecil',
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('CTA hero tetap buka sesi pemeriksaan', (
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
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();
      expect(find.byType(QuickCheckSessionScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
