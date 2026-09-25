import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:literasi_ai/app/home_screen.dart';
import 'package:literasi_ai/core/constants/app_colors.dart';
import 'package:literasi_ai/features/chat/presentation/screens/chat_screen.dart';
import 'package:literasi_ai/features/chat/presentation/widgets/chat_fab.dart';
import 'package:literasi_ai/shared/widgets/bottom_nav_bar.dart';

/// Style label slot tab: dibaca dari [AnimatedDefaultTextStyle] di dalam
/// slot (Text.style sendiri null karena diwariskan animasi).
TextStyle _slotLabelStyle(WidgetTester tester, int index) {
  final animated = find.descendant(
    of: find.byKey(ValueKey('nav-tab-$index')),
    matching: find.byType(AnimatedDefaultTextStyle),
  );
  return tester.widget<AnimatedDefaultTextStyle>(animated).style;
}

/// Kiri badge aktif: dibaca dari [Positioned] ancestor karena badge
/// kini digerakkan nilai animasi + notch sinkron (bukan AnimatedPositioned).
double _badgeLeft(WidgetTester tester) {
  final positioned = find.ancestor(
    of: find.byKey(const ValueKey('nav-active-badge')),
    matching: find.byType(Positioned),
  );
  return tester.widget<Positioned>(positioned).left ?? 0;
}

/// Pump navbar mandiri dengan index yang bisa berubah.
Future<void> _pumpNav(
  WidgetTester tester, {
  required int index,
  ValueChanged<int>? onTap,
}) {
  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: const SizedBox.expand(),
        bottomNavigationBar: AppBottomNavBar(
          currentIndex: index,
          onTap: onTap ?? (_) {},
        ),
      ),
    ),
  );
}

void main() {
  group('Navbar pill putih + badge naik', () {
    test('math slot: pusat simetris + badge terpusat', () {
      const width = 400.0;
      const count = 4;
      final centers = [
        for (var i = 0; i < count; i++)
          AppBottomNavBar.slotCenter(width, i, count),
      ];
      expect(centers, [50.0, 150.0, 250.0, 350.0]);
      // Geser antar slot seragam 100px: gerakan mulus bisa ditempuh
      // tween linear.
      for (var i = 1; i < centers.length; i++) {
        expect(centers[i] - centers[i - 1], 100.0);
      }
      expect(AppBottomNavBar.badgeLeftFor(150.0, 48.0), 126.0);
      expect(AppBottomNavBar.badgeLeftFor(50.0, 44.0), 28.0);
    });
    testWidgets('render 4 tab + badge di slot aktif + semantics', (
      tester,
    ) async {
      await _pumpNav(tester, index: 0);
      await tester.pumpAndSettle();

      for (final key in ['nav-tab-0', 'nav-tab-1', 'nav-tab-2', 'nav-tab-3']) {
        expect(find.byKey(ValueKey(key)), findsOneWidget);
      }
      expect(find.byKey(const ValueKey('nav-active-badge')), findsOneWidget);
      expect(find.bySemanticsLabel('Cek aktif'), findsOneWidget);
      expect(find.byIcon(Icons.fact_check_rounded), findsOneWidget);
      expect(find.byIcon(Icons.history_outlined), findsOneWidget);
      expect(find.byIcon(Icons.school_outlined), findsOneWidget);
      expect(find.byIcon(Icons.person_outline), findsOneWidget);
      // Widget bawaan tidak dipakai lagi: bukan tampilan standar.
      expect(find.byType(NavigationBar), findsNothing);
      expect(find.byType(NavigationDestination), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('tap pindah badge + callback + semantics + aksen', (
      tester,
    ) async {
      var index = 0;
      var calls = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) => Scaffold(
              body: const SizedBox.expand(),
              bottomNavigationBar: AppBottomNavBar(
                currentIndex: index,
                onTap: (i) {
                  calls++;
                  setState(() => index = i);
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final before = _badgeLeft(tester);
      await tester.tap(find.byKey(const ValueKey('nav-tab-2')));
      await tester.pumpAndSettle();

      expect(calls, 1);
      expect(index, 2);
      expect(find.byIcon(Icons.school_rounded), findsOneWidget);
      expect(find.bySemanticsLabel('Belajar aktif'), findsOneWidget);
      final after = _badgeLeft(tester);
      expect(after, greaterThan(before));
      // Label aktif Belajar memakai aksen hijau identitas tab.
      final labelStyle = _slotLabelStyle(tester, 2);
      expect(labelStyle.color, AppColors.successDark);
      expect(labelStyle.fontWeight, FontWeight.w800);
      expect(tester.takeException(), isNull);
    });

    testWidgets('tap tab aktif tidak memanggil ulang + aksen tiap tab', (
      tester,
    ) async {
      var calls = 0;
      await _pumpNav(tester, index: 1, onTap: (_) => calls++);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('nav-tab-1')));
      await tester.pumpAndSettle();
      expect(calls, 0);

      final accents = {
        'Cek': AppColors.primary,
        'Riwayat': AppColors.primaryDeep,
        'Belajar': AppColors.successDark,
        'Profil': AppColors.primaryDark,
      };
      for (var i = 0; i < accents.length; i++) {
        final entry = accents.entries.elementAt(i);
        await _pumpNav(tester, index: i);
        await tester.pumpAndSettle();
        expect(_slotLabelStyle(tester, i).color, entry.value);
      }
      expect(tester.takeException(), isNull);
    });

    testWidgets('viewport 360px tanpa overflow', (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      await _pumpNav(tester, index: 3);
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('nav-active-badge')), findsOneWidget);
      expect(find.bySemanticsLabel('Profil aktif'), findsOneWidget);
      // Badge kompak 44px: tetap di dalam bar (tidak keluar kiri/kanan).
      final badgeRect = tester.getRect(
        find.byKey(const ValueKey('nav-active-badge')),
      );
      final navRect = tester.getRect(find.byType(AppBottomNavBar));
      expect(badgeRect.left, greaterThanOrEqualTo(navRect.left));
      expect(badgeRect.right, lessThanOrEqualTo(navRect.right));
      expect(tester.takeException(), isNull);
    });

    testWidgets('tap cepat tengah jalan tetap mulus ke target akhir', (
      tester,
    ) async {
      var index = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) => Scaffold(
              body: const SizedBox.expand(),
              bottomNavigationBar: AppBottomNavBar(
                currentIndex: index,
                onTap: (i) => setState(() => index = i),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap tab 3 lalu langsung tab 1 sebelum animasi 480ms selesai.
      // Satu frame pemicu dulu agar tap diproses + animasi jalan,
      // baru majukan 120ms untuk membaca posisi tengah jalan.
      final start = _badgeLeft(tester);
      await tester.tap(find.byKey(const ValueKey('nav-tab-3')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 120));
      final mid = _badgeLeft(tester);
      await tester.tap(find.byKey(const ValueKey('nav-tab-1')));
      await tester.pumpAndSettle();

      // Posisi tengah jalan sudah bergerak ke kanan dari slot 0 (tidak diam
      // / tidak melompat ke target baru), posisi akhir tepat di slot 1.
      final end = _badgeLeft(tester);
      expect(mid, greaterThan(start));
      expect(end, lessThan(mid));
      expect(find.bySemanticsLabel('Riwayat aktif'), findsOneWidget);
      expect(find.byIcon(Icons.history_rounded), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('geser 3 slot: badge tiba di ujung', (tester) async {
      var index = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) => Scaffold(
              body: const SizedBox.expand(),
              bottomNavigationBar: AppBottomNavBar(
                currentIndex: index,
                onTap: (i) => setState(() => index = i),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final start = _badgeLeft(tester);
      await tester.tap(find.byKey(const ValueKey('nav-tab-3')));
      await tester.pumpAndSettle();

      final end = _badgeLeft(tester);
      expect(end - start, greaterThan(200));
      expect(find.bySemanticsLabel('Profil aktif'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('badge menempel di atas bar, FAB tidak menimpa keduanya', (
      tester,
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

      final badgeRect = tester.getRect(
        find.byKey(const ValueKey('nav-active-badge')),
      );
      final navRect = tester.getRect(find.byType(AppBottomNavBar));
      final fabRect = tester.getRect(find.byType(ChatFab));

      // Badge setengah keluar di atas pill: titik tengah badge harus
      // berada di atas titik tengah keseluruhan widget navbar.
      final navCenterY = navRect.top + navRect.height / 2;
      expect(badgeRect.center.dy, lessThan(navCenterY));
      // FAB di atas pill, badge tidak bersentuhan dengan FAB.
      expect(fabRect.overlaps(navRect), isFalse);
      expect(badgeRect.overlaps(fabRect), isFalse);
      expect(tester.takeException(), isNull);
    });

    testWidgets('pindah 4 tab via navbar di HomeScreen', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: HomeScreen())),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('nav-tab-1')));
      await tester.pumpAndSettle();
      expect(find.textContaining('Jejak'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('nav-tab-2')));
      await tester.pumpAndSettle();
      expect(find.textContaining('Naikkan'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('nav-tab-3')));
      await tester.pumpAndSettle();
      expect(find.textContaining('Kelola'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('nav-tab-0')));
      await tester.pumpAndSettle();
      expect(find.text('Cek kebenaran'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
