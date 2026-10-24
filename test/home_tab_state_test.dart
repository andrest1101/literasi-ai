import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:literasi_ai/app/home_screen.dart';
import 'package:literasi_ai/features/history/presentation/screens/history_list_screen.dart';
import 'package:literasi_ai/features/learn/presentation/screens/course_list_screen.dart';
import 'package:literasi_ai/features/quick_check/presentation/screens/quick_check_home_tab.dart';
import 'package:literasi_ai/features/score/presentation/screens/profile_screen.dart';

/// Regresi shell: tab harus bertahan saat berpindah.
///
/// Sebelumnya body HomeScreen memakai `switch (_index)` sehingga tab lama
/// dibuang seluruhnya: posisi scroll, kata kunci pencarian, dan state lokal
/// lain hilang setiap kali pengguna menekan navbar.
void main() {
  Future<void> pumpHome(WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: HomeScreen())),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tapTab(WidgetTester tester, int index) async {
    await tester.tap(find.byKey(ValueKey('nav-tab-$index')));
    await tester.pumpAndSettle();
  }

  group('State tab bertahan (lazy IndexedStack)', () {
    testWidgets('posisi scroll tab Cek bertahan setelah pindah-pulang', (
      tester,
    ) async {
      await pumpHome(tester);

      final anchor = find.text('Pilih cara memeriksa');
      final before = tester.getTopLeft(anchor).dy;

      await tester.dragFrom(tester.getCenter(anchor), const Offset(0, -240));
      await tester.pumpAndSettle();

      final scrolled = tester.getTopLeft(anchor).dy;
      expect(
        scrolled,
        lessThan(before - 100),
        reason: 'drag harus benar-benar menggulir konten',
      );

      await tapTab(tester, 1);
      await tapTab(tester, 0);

      expect(find.text('Pilih cara memeriksa'), findsOneWidget);
      expect(
        tester.getTopLeft(anchor).dy,
        closeTo(scrolled, 0.5),
        reason: 'offset scroll harus sama seperti sebelum pindah tab',
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('kata kunci pencarian Riwayat tidak hilang saat pindah tab', (
      tester,
    ) async {
      await pumpHome(tester);
      await tapTab(tester, 1);

      final search = find.byType(EditableText).first;
      await tester.enterText(search, 'vaksin');
      await tester.pumpAndSettle();
      expect(tester.widget<EditableText>(search).controller.text, 'vaksin');

      await tapTab(tester, 0);
      await tapTab(tester, 1);

      expect(
        tester
            .widget<EditableText>(find.byType(EditableText).first)
            .controller
            .text,
        'vaksin',
        reason: 'controller pencarian hidup kembali dari nol kalau tab dibuang',
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('tab yang belum pernah dibuka belum dibangun', (tester) async {
      await pumpHome(tester);

      expect(
        find.byType(QuickCheckHomeTab, skipOffstage: false),
        findsOneWidget,
      );
      expect(find.byType(HistoryListScreen, skipOffstage: false), findsNothing);
      expect(find.byType(CourseListScreen, skipOffstage: false), findsNothing);
      expect(find.byType(ProfileScreen, skipOffstage: false), findsNothing);

      await tapTab(tester, 2);

      expect(
        find.byType(CourseListScreen, skipOffstage: false),
        findsOneWidget,
      );
      expect(find.byType(HistoryListScreen, skipOffstage: false), findsNothing);
      expect(find.byType(ProfileScreen, skipOffstage: false), findsNothing);
    });

    testWidgets('tab tersembunyi tidak ikut ter-finder default', (
      tester,
    ) async {
      await pumpHome(tester);
      await tapTab(tester, 1);

      // Kontrak IndexedStack: hanya child aktif yang onstage, jadi tidak ada
      // judul/konten tab Cek yang ikut terbaca atau tertangkap finder.
      expect(find.byType(QuickCheckHomeTab), findsNothing);
      expect(find.byType(HistoryListScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('back dari tab lain kembali ke Cek tanpa membuang tab', (
      tester,
    ) async {
      await pumpHome(tester);
      await tapTab(tester, 2);
      expect(find.byType(CourseListScreen), findsOneWidget);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(find.byType(QuickCheckHomeTab), findsOneWidget);
      expect(find.byType(CourseListScreen), findsNothing);
      // Tab 2 tetap ter-mount di belakang agar state-nya tidak hilang.
      expect(
        find.byType(CourseListScreen, skipOffstage: false),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });
  });
}
