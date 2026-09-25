import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:literasi_ai/app/home_screen.dart';
import 'package:literasi_ai/features/chat/presentation/screens/chat_screen.dart';
import 'package:literasi_ai/features/chat/presentation/widgets/chat_fab.dart';
import 'package:literasi_ai/features/quick_check/presentation/screens/quick_check_home_tab.dart';
import 'package:literasi_ai/features/quick_check/presentation/screens/quick_check_session_screen.dart';
import 'package:literasi_ai/shared/widgets/bottom_nav_bar.dart';

void main() {
  testWidgets('navbar has 4 destinations and floating chat FAB', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: const HomeScreen(),
          routes: {ChatScreen.route: (_) => const ChatScreen()},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AppBottomNavBar), findsOneWidget);
    expect(find.text('Cek'), findsOneWidget);
    expect(find.text('Riwayat'), findsOneWidget);
    expect(find.text('Belajar'), findsOneWidget);
    expect(find.text('Profil'), findsOneWidget);
    expect(find.text('Chat'), findsNothing);

    expect(find.byTooltip('Chat dengan AI Literasi'), findsOneWidget);
    expect(find.byType(ChatFab), findsOneWidget);
    expect(find.byIcon(Icons.verified_user_rounded), findsWidgets);
    expect(find.byIcon(Icons.auto_awesome_rounded), findsOneWidget);
    expect(find.byIcon(Icons.smart_toy_outlined), findsNothing);

    // FAB melayang di atas pill navbar: tidak ada irisan rect dengan nav.
    final fabRect = tester.getRect(find.byType(ChatFab));
    final navRect = tester.getRect(find.byType(AppBottomNavBar));
    expect(fabRect.overlaps(navRect), isFalse);
    expect(fabRect.bottom, lessThanOrEqualTo(navRect.top - 8));

    await tester.tap(find.byTooltip('Chat dengan AI Literasi'));
    await tester.pumpAndSettle();
    expect(find.byType(ChatScreen), findsOneWidget);
    expect(find.text('Halo, aku asisten literasimu.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('FAB chat: tekan menyusut lalu kembali + tap buka chat', (
    WidgetTester tester,
  ) async {
    var tapped = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: const SizedBox.expand(),
          floatingActionButton: ChatFab(onTap: () => tapped++),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Identitas shield dipertahankan (bukan robot generik).
    expect(find.byIcon(Icons.verified_user_rounded), findsOneWidget);
    expect(find.byIcon(Icons.smart_toy_outlined), findsNothing);

    // Tekan-tahan-tanpa-lepas tidak crash (press controller jalan).
    // gesture.up() melengkapi satu tap (tapped=1), tap berikutnya = 2.
    final fabCenter = tester.getCenter(find.byType(ChatFab));
    final gesture = await tester.startGesture(fabCenter);
    await tester.pump(const Duration(milliseconds: 60));
    await gesture.up();
    await tester.pumpAndSettle();
    expect(tapped, 1);
    await tester.tap(find.byType(ChatFab));
    await tester.pumpAndSettle();
    expect(tapped, 2);
    expect(tester.takeException(), isNull);
  });

  testWidgets('landing tiles and examples open matching session', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: QuickCheckHomeTab())),
    );
    await tester.pumpAndSettle();

    expect(find.text('Pilih cara memeriksa'), findsOneWidget);
    expect(find.text('Coba contoh sekali ketuk'), findsOneWidget);
    expect(find.text('Alur yang jelas'), findsNothing);

    final imageTile = find.text('Cek gambar');
    await tester.ensureVisible(imageTile);
    await tester.pumpAndSettle();
    await tester.tap(imageTile);
    await tester.pumpAndSettle();
    expect(find.byType(QuickCheckSessionScreen), findsOneWidget);
    expect(find.text('Gambar yang diperiksa'), findsOneWidget);

    await tester.tap(find.byTooltip('Kembali ke Beranda'));
    await tester.pumpAndSettle();
    expect(find.byType(QuickCheckHomeTab), findsOneWidget);

    final exampleCard = find.text('Cek ini').first;
    await tester.ensureVisible(exampleCard);
    await tester.pumpAndSettle();
    await tester.tap(exampleCard);
    await tester.pumpAndSettle();
    expect(find.byType(QuickCheckSessionScreen), findsOneWidget);
    expect(find.textContaining('menyembuhkan'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('session honors initial mode and seeded claim', (
    WidgetTester tester,
  ) async {
    const seed =
        'Apakah benar minum air rebusan daun tertentu dapat menyembuhkan semua penyakit?';
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: QuickCheckSessionScreen(
            initialMode: QuickCheckInitialMode.text,
            initialClaim: seed,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final fields = tester.widgetList<TextField>(find.byType(TextField));
    expect(fields.any((f) => f.controller?.text == seed), isTrue);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: QuickCheckSessionScreen(
            initialMode: QuickCheckInitialMode.image,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Gambar yang diperiksa'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('bottom nav switches across 4 tabs without chat', (
    WidgetTester tester,
  ) async {
    int current = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: AppBottomNavBar(
            currentIndex: current,
            onTap: (i) => current = i,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AppBottomNavBar), findsOneWidget);
    // Tap via key slot tab agar tidak ambigu dengan label lain.
    await tester.tap(find.byKey(const ValueKey('nav-tab-1')));
    await tester.pumpAndSettle();
    expect(current, 1);
    expect(tester.takeException(), isNull);
  });
}
