import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:literasi_ai/main.dart';

void main() {
  testWidgets('App boots to Splash then navigates to Onboarding',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: LiterasiAIApp()));
    await tester.pump();

    expect(find.text('LiterasiAI'), findsOneWidget);
    expect(find.byIcon(Icons.fact_check), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.text('Cek Fakta Instan'), findsOneWidget);
  });
}
