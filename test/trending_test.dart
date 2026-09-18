import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:literasi_ai/app/home_screen.dart';
import 'package:literasi_ai/features/quick_check/domain/entities/verification_result.dart';
import 'package:literasi_ai/features/quick_check/presentation/screens/quick_check_home_tab.dart';
import 'package:literasi_ai/features/trending/domain/entities/trending_item.dart';
import 'package:literasi_ai/features/trending/presentation/providers/trending_providers.dart';
import 'package:literasi_ai/features/trending/presentation/screens/trending_detail_screen.dart';
import 'package:literasi_ai/features/trending/presentation/widgets/trending_rail.dart';

void main() {
  group('Konten trending curated', () {
    test('valid: 7 item, verdict dan rujukan ada', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final items = container.read(trendingItemsProvider);
      expect(items, hasLength(7));
      for (final item in items) {
        expect(item.title.isNotEmpty, isTrue);
        expect(item.summary.isNotEmpty, isTrue);
        expect(item.reference.isNotEmpty, isTrue);
        expect(item.confidence, inInclusiveRange(0, 100));
      }
      final hot = container.read(trendingHotProvider);
      expect(hot.isNotEmpty, isTrue);
      expect(hot.every((item) => item.isHot), isTrue);
    });

    test('konversi ke hasil reuse kartu dan share', () {
      final item = TrendingItem(
        id: 'uji',
        title: 'Klaim uji trending.',
        summary: 'Ringkasan uji.',
        verdict: Verdict.hoaks,
        confidence: 90,
        category: 'Uji',
        isHot: true,
        checkedAt: DateTime(2026, 9, 25),
        reference: 'TurnBackHoax',
      );
      final result = item.toResult();
      expect(result.verdict, Verdict.hoaks);
      expect(result.suggestion, contains('TurnBackHoax'));
    });
  });

  testWidgets('tab cek memuat rail trending di bawah contoh', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: QuickCheckHomeTab())),
    );
    await tester.pumpAndSettle();
    expect(find.text('Trending hoaks'), findsOneWidget);
    expect(find.byType(TrendingRail), findsOneWidget);
    expect(find.text('HOT'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tap rail membuka detail dengan rujukan dan aksi', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: HomeScreen())),
    );
    await tester.pumpAndSettle();

    final card = find.text('Pesan bantuan tunai Rp 5 juta minta data rekening');
    await tester.ensureVisible(card);
    await tester.pumpAndSettle();
    await tester.tap(card);
    await tester.pumpAndSettle();

    expect(find.byType(TrendingDetailScreen), findsOneWidget);
    expect(find.textContaining('TurnBackHoax'), findsWidgets);
    expect(find.text('Verifikasi serupa'), findsOneWidget);
    expect(find.text('Bagikan Hasil'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
