import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:literasi_ai/features/quick_check/presentation/screens/quick_check_home_tab.dart';

/// Regresi U4: pola hero ter-render di belakang konten tanpa menutupi CTA.
void main() {
  Future<void> pumpHome(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: const Scaffold(body: QuickCheckHomeTab()),
          onGenerateRoute: (settings) => MaterialPageRoute(
            builder: (_) =>
                Scaffold(body: Text('rute: ${settings.name}')),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('Tekstur hero U4', () {
    testWidgets('CustomPaint pola ada di balik konten hero', (
      WidgetTester tester,
    ) async {
      await pumpHome(tester);
      final paints = find.byType(CustomPaint).evaluate();
      expect(paints, isNotEmpty);
      // Pola hero adalah CustomPaint dengan painter non-null milik sendiri.
      final heroPaints = paints.where((e) {
        final widget = e.widget as CustomPaint;
        return widget.painter != null;
      });
      expect(heroPaints, isNotEmpty);
      expect(tester.takeException(), isNull);
    });

    testWidgets('CTA hero tetap bisa di-tap (tidak tertutup pola)', (
      WidgetTester tester,
    ) async {
      await pumpHome(tester);
      final cta = find.byType(FilledButton);
      expect(cta, findsOneWidget);
      await tester.tap(cta);
      await tester.pumpAndSettle();
      expect(find.textContaining('/quick-check-session'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
