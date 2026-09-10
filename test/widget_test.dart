import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:literasi_ai/main.dart';

void main() {
  testWidgets('Onboarding: swipe, press-glow, back & start',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: LiterasiAIApp()));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    // Slide 1: eyebrow + konten generik + tombol Lanjut.
    expect(find.text('VERIFIKASI TEKS'), findsOneWidget);
    expect(find.text('Cek Hoaks Instan dengan AI'), findsOneWidget);
    expect(find.text('Lanjut'), findsOneWidget);
    expect(find.text('Lewati'), findsOneWidget);

    // Press-glow: tap visual tidak error, glow kembali normal.
    await tester.tap(find.byType(PageView).first);
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();
    expect(find.text('Cek Hoaks Instan dengan AI'), findsOneWidget);

    // Swipe (fling) ke slide 2.
    await tester.fling(find.byType(PageView), const Offset(-300, 0), 800);
    await tester.pumpAndSettle();
    expect(find.text('Analisis Gambar & Link'), findsOneWidget);
    expect(find.text('MULTI-FORMAT'), findsOneWidget);

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

    // Mulai Sekarang → Auth screen baru.
    await tester.tap(find.text('Mulai Sekarang'));
    await tester.pumpAndSettle();
    expect(find.text('Masuk ke LiterasiAI'), findsOneWidget);
    expect(find.text('MASUK GRATIS'), findsOneWidget);
    expect(
        find.text('Masuk untuk menyimpan riwayat cek faktamu di semua perangkat.'),
        findsOneWidget);
    expect(find.text('Masuk dengan Google'), findsOneWidget);
    expect(find.text('Lanjut tanpa akun'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));

    // Maskot menutup mata saat kolom sandi fokus.
    await tester.tap(find.widgetWithText(TextFormField, 'Kata sandi'));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);

    // Toggle tampilkan sandi: maskot mengintip.
    await tester.tap(find.byIcon(Icons.visibility_outlined));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);

    // Validasi: email kosong + sandi pendek memicu pesan error.
    await tester.tap(find.text('Masuk'));
    await tester.pumpAndSettle();
    expect(find.text('Masukkan alamat email yang valid.'), findsOneWidget);
    expect(find.text('Kata sandi minimal 6 karakter.'), findsOneWidget);

    // Lanjut tanpa akun → Home (fallback offline bila Firebase absen).
    await tester.ensureVisible(find.text('Lanjut tanpa akun'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lanjut tanpa akun'));
    await tester.pumpAndSettle();
    expect(find.text('Quick Check'), findsOneWidget);
  });
}
