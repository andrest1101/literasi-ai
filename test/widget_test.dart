import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:literasi_ai/main.dart';

void main() {
  testWidgets('Onboarding redesign: swipe, pill indicator, back & start',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: LiterasiAIApp()));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    // Slide 1: konten baru + tombol Lanjut + indikator 3 pill.
    expect(find.text('Cek Hoaks Instan dengan AI'), findsOneWidget);
    expect(find.text('Lanjut'), findsOneWidget);
    expect(find.text('Lewati'), findsOneWidget);

    // Swipe (fling) ke slide 2.
    await tester.fling(find.byType(PageView), const Offset(-300, 0), 800);
    await tester.pumpAndSettle();
    expect(find.text('Analisis Gambar & Link'), findsOneWidget);

    // Tombol back (ikon panah) kembali ke slide 1.
    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Cek Hoaks Instan dengan AI'), findsOneWidget);

    // Swipe 2x ke slide terakhir: tombol berubah jadi Mulai Sekarang.
    await tester.fling(find.byType(PageView), const Offset(-300, 0), 800);
    await tester.pumpAndSettle();
    await tester.fling(find.byType(PageView), const Offset(-300, 0), 800);
    await tester.pumpAndSettle();
    expect(find.text('Riwayat Terpercaya, Akses Mudah'), findsOneWidget);
    expect(find.text('Mulai Sekarang'), findsOneWidget);

    // Mulai Sekarang → Auth screen.
    await tester.tap(find.text('Mulai Sekarang'));
    await tester.pumpAndSettle();
    expect(find.text('Masuk ke LiterasiAI'), findsOneWidget);
  });
}
