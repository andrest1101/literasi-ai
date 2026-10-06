import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:literasi_ai/app/home_screen.dart';
import 'package:literasi_ai/core/constants/app_strings.dart';
import 'package:literasi_ai/features/quick_check/domain/entities/verification_result.dart';
import 'package:literasi_ai/features/quick_check/presentation/screens/quick_check_home_tab.dart';
import 'package:literasi_ai/features/trending/data/datasources/trending_local_datasource.dart';
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
      final ids = items.map((item) => item.id).toList();
      expect(ids.toSet(), hasLength(7));
      for (final item in items) {
        expect(item.title.isNotEmpty, isTrue);
        expect(item.summary.isNotEmpty, isTrue);
        expect(item.reference.isNotEmpty, isTrue);
        expect(item.referenceUrl.startsWith('https://'), isTrue);
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
        referenceUrl: 'https://turnbackhoax.id/',
      );
      final result = item.toResult();
      expect(result.verdict, Verdict.hoaks);
      expect(result.suggestion, contains('TurnBackHoax'));
    });

    test('paket konten offline sinkron dan jujur', () {
      expect(TrendingLocalDatasource.packVersion, isNotEmpty);
      expect(
        TrendingLocalDatasource.packUpdatedAt.isAfter(DateTime(2026, 9, 30)),
        isTrue,
      );
      final examples = [
        (AppStrings.quickCheckExampleTag1, AppStrings.quickCheckExample1),
        (AppStrings.quickCheckExampleTag2, AppStrings.quickCheckExample2),
        (AppStrings.quickCheckExampleTag3, AppStrings.quickCheckExample3),
        (AppStrings.quickCheckExampleTag4, AppStrings.quickCheckExample4),
        (AppStrings.quickCheckExampleTag5, AppStrings.quickCheckExample5),
      ];
      expect(examples.map((e) => e.$1).toSet(), hasLength(5));
      expect(examples.map((e) => e.$2).toSet(), hasLength(5));
      for (final example in examples) {
        expect(example.$1.isNotEmpty, isTrue);
        expect(example.$2.length, lessThanOrEqualTo(160));
      }
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

    final card = find.text(
      'Pesan bantuan tunai Rp5 juta yang minta data rekening',
    );
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
