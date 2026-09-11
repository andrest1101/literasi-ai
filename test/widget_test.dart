import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:literasi_ai/features/auth/presentation/screens/auth_screen.dart';
import 'package:literasi_ai/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:literasi_ai/features/auth/presentation/screens/register_screen.dart';
import 'package:literasi_ai/features/auth/presentation/widgets/auth_form_parts.dart';
import 'package:literasi_ai/features/auth/presentation/widgets/google_g_logo.dart';
import 'package:literasi_ai/main.dart';

void main() {
  testWidgets('Onboarding: swipe, press-glow, back & start', (
    WidgetTester tester,
  ) async {
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
    expect(find.text('Masuk dengan email'), findsOneWidget);
    expect(
      find.text(
        'Masuk untuk menyimpan riwayat cek faktamu di semua perangkat.',
      ),
      findsOneWidget,
    );
    expect(find.text('Masuk dengan Google'), findsOneWidget);
    expect(find.text('Lanjut tanpa akun'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.byType(AuthFormCard), findsOneWidget);

    // Toggle tampilkan sandi tetap berfungsi tanpa maskot.
    await tester.tap(find.widgetWithText(TextFormField, 'Kata sandi'));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);

    await tester.tap(find.byIcon(Icons.visibility_outlined));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);

    // Validasi: email kosong + sandi pendek memicu pesan error.
    await tester.ensureVisible(find.text('Masuk'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Masuk'));
    await tester.pumpAndSettle();
    expect(find.text('Masukkan alamat email yang valid.'), findsOneWidget);
    expect(find.text('Kata sandi minimal 6 karakter.'), findsOneWidget);

    // Lanjut tanpa akun → Home. Di test env Firebase absen sehingga
    // jalur gagal yang jalan (tetap ke Home); snackbar info sukses hanya
    // muncul di perangkat nyata.
    await tester.ensureVisible(find.text('Lanjut tanpa akun'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lanjut tanpa akun'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    // Tab Quick Check sekarang landing ringkas dengan CTA sesi dedicated.
    expect(find.text('Quick Check'), findsOneWidget);
    expect(find.text('Mulai Pemeriksaan'), findsOneWidget);
    await tester.tap(find.text('Mulai Pemeriksaan'));
    await tester.pumpAndSettle();
    expect(find.text('Sesi pemeriksaan'), findsOneWidget);
    expect(find.text('Verifikasi Sekarang'), findsOneWidget);
  });

  testWidgets('GoogleGLogo renders official asset without error', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Center(child: GoogleGLogo(size: 24))),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(GoogleGLogo), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Auth triangle: login to register to forgot and back', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: LiterasiAIApp()));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    await tester.fling(find.byType(PageView), const Offset(-300, 0), 800);
    await tester.pumpAndSettle();
    await tester.fling(find.byType(PageView), const Offset(-300, 0), 800);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mulai Sekarang'));
    await tester.pumpAndSettle();

    // Masuk punya tautan daftar dan lupa sandi. RichText dicari utuh.
    expect(
      find.text('Belum punya akun? Daftar', findRichText: true),
      findsOneWidget,
    );
    expect(find.text('Lupa kata sandi?'), findsOneWidget);

    // Ke halaman Daftar: syarat sandi live + validasi.
    await tester.ensureVisible(
      find.text('Belum punya akun? Daftar', findRichText: true),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Belum punya akun? Daftar', findRichText: true));
    await tester.pumpAndSettle();
    expect(find.text('Buat Akun LiterasiAI'), findsOneWidget);
    expect(find.text('Data akun baru'), findsOneWidget);
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Kata sandi'),
      'abc123',
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Daftar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Daftar'));
    await tester.pumpAndSettle();
    expect(find.text('Masukkan namamu.'), findsOneWidget);
    expect(find.text('Kata sandi tidak sama. Coba lagi.'), findsOneWidget);

    // Toggle konfirmasi sandi tetap tersedia di card form.
    expect(find.byIcon(Icons.visibility_outlined), findsNWidgets(2));

    // Kembali masuk, lalu ke Lupa Sandi.
    await tester.ensureVisible(
      find.text('Sudah punya akun? Masuk', findRichText: true),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sudah punya akun? Masuk', findRichText: true));
    await tester.pumpAndSettle();
    expect(find.text('Masuk ke LiterasiAI'), findsOneWidget);
    await tester.ensureVisible(find.text('Lupa kata sandi?'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lupa kata sandi?'));
    await tester.pumpAndSettle();
    expect(find.text('Lupa Kata Sandi'), findsOneWidget);
    expect(find.text('Kirim Tautan'), findsOneWidget);

    // Validasi email kosong memicu pesan error.
    await tester.tap(find.text('Kirim Tautan'));
    await tester.pumpAndSettle();
    expect(find.text('Masukkan alamat email yang valid.'), findsOneWidget);
  });

  testWidgets('Auth hero medallion overlays card on all auth pages', (
    WidgetTester tester,
  ) async {
    Future<void> pumpPage(Widget page, EdgeInsets insets) async {
      // Pertahankan ukuran layar asli: hanya override viewInsets agar body
      // menyusut seperti keyboard sungguhan (bukan Size.zero).
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Builder(
              builder: (context) => MediaQuery(
                data: MediaQuery.of(context).copyWith(viewInsets: insets),
                child: page,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    // Masuk: medallion berada di atas kartu dan tidak menutup field utama.
    await pumpPage(const AuthScreen(), EdgeInsets.zero);
    expect(find.byType(AuthTrustMedallion), findsOneWidget);
    expect(find.byType(AuthFormCard), findsOneWidget);
    expect(find.byType(AuthSecondaryPanel), findsOneWidget);
    final medallionBottom = tester.getBottomRight(
      find.byType(AuthTrustMedallion),
    );
    final cardTop = tester.getTopLeft(find.byType(AuthFormCard));
    final emailTop = tester.getTopLeft(
      find.widgetWithText(TextFormField, 'Email'),
    );
    expect(medallionBottom.dy, greaterThan(cardTop.dy));
    expect(emailTop.dy, greaterThan(medallionBottom.dy));

    // Daftar: punya tombol kembali dan medallion proporsional.
    await pumpPage(const RegisterScreen(), EdgeInsets.zero);
    expect(find.byType(AuthTrustMedallion), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
    expect(tester.takeException(), isNull);

    // Lupa sandi: keyboard terbuka tetap tidak overflow.
    await pumpPage(
      const ForgotPasswordScreen(),
      const EdgeInsets.only(bottom: 400),
    );
    expect(find.byType(AuthTrustMedallion), findsOneWidget);
    expect(find.byType(AuthFormCard), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
