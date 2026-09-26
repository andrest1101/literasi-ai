import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:literasi_ai/core/constants/app_colors.dart';
import 'package:literasi_ai/features/history/domain/entities/history_entry.dart';
import 'package:literasi_ai/features/history/domain/entities/history_filter.dart';
import 'package:literasi_ai/features/history/domain/repositories/history_repository.dart';
import 'package:literasi_ai/features/history/presentation/providers/history_providers.dart';
import 'package:literasi_ai/features/history/presentation/screens/history_list_screen.dart';
import 'package:literasi_ai/features/history/presentation/utils/history_time_ago.dart';
import 'package:literasi_ai/features/history/presentation/widgets/history_card.dart';
import 'package:literasi_ai/features/quick_check/domain/entities/verification_result.dart';

/// Regresi refined Riwayat: sub-konteks data-driven, focus ring search,
/// tint statistik, spine kartu, badge TERBARU, helper waktu bersama.
VerificationResult _result({Verdict verdict = Verdict.hoaks}) {
  return VerificationResult(
    claim: 'Informasi uji riwayat refined yang cukup panjang.',
    verdict: verdict,
    confidence: 87,
    explanation: 'Penjelasan hasil uji.',
    suggestion: 'Saran hasil uji.',
    checkedAt: DateTime.utc(2026, 9, 16, 12, 0),
    source: VerificationSource.text,
  );
}

HistoryEntry _entry({String id = 'entry-1', Verdict verdict = Verdict.hoaks}) {
  return HistoryEntry(id: id, result: _result(verdict: verdict));
}

class _FakeHistoryRepository implements HistoryRepository {
  _FakeHistoryRepository({this.entries = const []});

  final List<HistoryEntry> entries;

  @override
  Stream<List<HistoryEntry>> watch(String userId) =>
      Stream.value(entries);

  @override
  Future<void> save({
    required String userId,
    required VerificationResult result,
  }) async {}

  @override
  Future<void> delete({
    required String userId,
    required String entryId,
  }) async {}
}

Future<void> _pumpList(
  WidgetTester tester, {
  required List<HistoryEntry> entries,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        historyRepositoryProvider.overrideWithValue(
          _FakeHistoryRepository(entries: entries),
        ),
        historyUserIdProvider.overrideWithValue('user-1'),
        historyFilterProvider.overrideWith((ref) => HistoryFilter.all),
      ],
      child: const MaterialApp(home: Scaffold(body: HistoryListScreen())),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('Helper historyTimeAgo bersama', () {
    test('menit, jam, hari, tanggal penuh', () {
      final now = DateTime(2026, 9, 26, 12, 0);
      expect(
        historyTimeAgo(now.subtract(const Duration(seconds: 10)),
            clockNow: now),
        'Baru saja',
      );
      expect(
        historyTimeAgo(now.subtract(const Duration(minutes: 5)),
            clockNow: now),
        '5 mnt',
      );
      expect(
        historyTimeAgo(now.subtract(const Duration(hours: 2)),
            clockNow: now),
        '2 jam',
      );
      expect(
        historyTimeAgo(now.subtract(const Duration(days: 3)),
            clockNow: now),
        '3 hari',
      );
      expect(
        historyTimeAgo(DateTime(2026, 9, 16, 12, 0), clockNow: now),
        '16/09/2026',
      );
    });
  });

  group('Sub-konteks toolbar Riwayat', () {
    testWidgets('total + terakhir dari seluruh riwayat', (tester) async {
      await _pumpList(
        tester,
        entries: [
          _entry(id: 'a', verdict: Verdict.hoaks),
          _entry(id: 'b', verdict: Verdict.valid),
        ],
      );
      expect(find.textContaining('2 pemeriksaan'), findsOneWidget);
      expect(find.textContaining('terakhir'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('kosong menampilkan pesan jujur', (tester) async {
      await _pumpList(tester, entries: const []);
      expect(find.text('Belum ada yang tersimpan.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('Spine + badge TERBARU kartu', () {
    testWidgets('spine warna verdict menempel di kiri kartu', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: HistoryCard(entry: _entry(), onTap: () {})),
        ),
      );
      await tester.pumpAndSettle();

      var found = false;
      for (final element in find.byType(Stack).evaluate()) {
        final stack = element.widget as Stack;
        if (stack.children.length != 2) continue;
        final first = stack.children.first;
        if (first is! Positioned) continue;
        Widget? inner = first.child;
        if (inner is ExcludeSemantics) inner = inner.child;
        final decoration = (inner as Container?)?.decoration;
        if (decoration is BoxDecoration &&
            decoration.color == AppColors.danger) {
          found = true;
        }
      }
      expect(found, isTrue, reason: 'spine HOAKS merah tidak ditemukan');
      expect(tester.takeException(), isNull);
    });

    testWidgets('badge TERBARU hanya bila isLatest true', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                HistoryCard(entry: _entry(id: 'a'), onTap: () {}),
                HistoryCard(
                  entry: _entry(id: 'b'),
                  isLatest: true,
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('TERBARU'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('daftar utuh menandai entri pertama saja', (tester) async {
      await _pumpList(
        tester,
        entries: [
          _entry(id: 'a', verdict: Verdict.hoaks),
          _entry(id: 'b', verdict: Verdict.valid),
        ],
      );
      expect(find.text('TERBARU'), findsOneWidget);
      expect(find.byType(HistoryCard), findsNWidgets(2));
      expect(tester.takeException(), isNull);
    });

    testWidgets('daftar tunggal tanpa badge TERBARU', (tester) async {
      await _pumpList(
        tester,
        entries: [_entry(id: 'a', verdict: Verdict.hoaks)],
      );
      expect(find.text('TERBARU'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });

  group('Search focus ring', () {
    testWidgets('border menebal dan ikon menint saat focus', (tester) async {
      await _pumpList(
        tester,
        entries: [_entry(id: 'a', verdict: Verdict.hoaks)],
      );
      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();

      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.focusNode?.hasFocus, isTrue);
      final icon = tester.widget<Icon>(find.byIcon(Icons.search_rounded));
      expect(icon.color, AppColors.primaryDeep);
      expect(tester.takeException(), isNull);
    });
  });
}
