import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:literasi_ai/features/history/domain/entities/history_entry.dart';
import 'package:literasi_ai/features/history/presentation/screens/history_detail_screen.dart';
import 'package:literasi_ai/features/history/presentation/widgets/history_card.dart';
import 'package:literasi_ai/features/quick_check/domain/entities/verification_result.dart';
import 'package:literasi_ai/features/quick_check/presentation/widgets/quick_check_result_section.dart';
import 'package:literasi_ai/features/trending/domain/entities/trending_item.dart';
import 'package:literasi_ai/features/trending/presentation/screens/trending_detail_screen.dart';
import 'package:literasi_ai/features/trending/presentation/widgets/trending_rail.dart';

VerificationResult _result({Verdict verdict = Verdict.hoaks}) {
  return VerificationResult(
    claim: 'Informasi uji hero yang cukup panjang.',
    verdict: verdict,
    confidence: 87,
    explanation: 'Penjelasan hasil uji.',
    suggestion: 'Saran hasil uji.',
    checkedAt: DateTime.utc(2026, 9, 21, 12, 0),
  );
}

TrendingItem _item({required String id, Verdict verdict = Verdict.hoaks}) {
  return TrendingItem(
    id: id,
    title: 'Judul uji hero $id yang cukup panjang.',
    summary: 'Ringkasan uji.',
    verdict: verdict,
    confidence: 87,
    category: 'Kesehatan',
    isHot: true,
    checkedAt: DateTime.utc(2026, 9, 21, 12, 0),
    reference: 'TurnBackHoax',
  );
}

void main() {
  testWidgets('history heroes carry unique tags per entry', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              HistoryCard(
                entry: HistoryEntry(id: 'hero-1', result: _result()),
                onTap: () {},
              ),
              HistoryCard(
                entry: HistoryEntry(
                  id: 'hero-2',
                  result: _result(verdict: Verdict.valid),
                ),
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );

    expect(
      find.byWidgetPredicate(
        (w) => w is Hero && w.tag == 'history-verdict-hero-1',
      ),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate(
        (w) => w is Hero && w.tag == 'history-verdict-hero-2',
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('history card tap flies hero to detail and back',
      (tester) async {
    final entry = HistoryEntry(id: 'hero-nav', result: _result());
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: HistoryCard(
              entry: entry,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => HistoryDetailScreen(entry: entry),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(HistoryCard));
    await tester.pumpAndSettle();
    expect(find.byType(QuickCheckResultSection), findsOneWidget);
    expect(find.byType(HistoryDetailScreen), findsOneWidget);

    // Detail memakai SessionBackButton kustom (bukan BackButton Material),
    // jadi pop dilakukan langsung via Navigator.
    tester.state<NavigatorState>(find.byType(Navigator)).pop();
    await tester.pumpAndSettle();
    expect(find.byType(HistoryCard), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('result section without heroTag renders no hero',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: QuickCheckResultSection(
              result: _result(),
              loading: false,
              onNewCheck: () {},
            ),
          ),
        ),
      ),
    );

    expect(find.byType(Hero), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('result section with heroTag renders one hero',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: QuickCheckResultSection(
              result: _result(),
              loading: false,
              onNewCheck: () {},
              heroTag: 'uji-tag',
            ),
          ),
        ),
      ),
    );

    expect(
      find.byWidgetPredicate((w) => w is Hero && w.tag == 'uji-tag'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('trending rail heroes are unique and open detail',
      (tester) async {
    final items = [_item(id: 'trend-1'), _item(id: 'trend-2')];
    // ProviderScope di luar MaterialApp agar route detail yang di-push
    // (TrendingDetailScreen kini ConsumerWidget) tetap di dalam scope.
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TrendingRail(
                items: items,
                onPick: (item) => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => TrendingDetailScreen(item: item),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    expect(
      find.byWidgetPredicate(
        (w) => w is Hero && w.tag == 'trending-verdict-trend-1',
      ),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate(
        (w) => w is Hero && w.tag == 'trending-verdict-trend-2',
      ),
      findsOneWidget,
    );

    await tester.tap(find.textContaining('trend-1'));
    await tester.pumpAndSettle();
    expect(find.byType(TrendingDetailScreen), findsOneWidget);
    expect(find.byType(QuickCheckResultSection), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
