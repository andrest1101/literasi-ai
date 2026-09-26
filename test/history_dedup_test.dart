import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:literasi_ai/core/constants/app_strings.dart';
import 'package:literasi_ai/features/history/domain/entities/history_entry.dart';
import 'package:literasi_ai/features/history/domain/entities/history_filter.dart';
import 'package:literasi_ai/features/history/domain/repositories/history_repository.dart';
import 'package:literasi_ai/features/history/presentation/providers/history_providers.dart';
import 'package:literasi_ai/features/history/presentation/screens/history_detail_screen.dart';
import 'package:literasi_ai/features/history/presentation/screens/history_list_screen.dart';
import 'package:literasi_ai/features/history/presentation/widgets/history_card.dart';
import 'package:literasi_ai/features/history/presentation/widgets/history_filter_bar.dart';
import 'package:literasi_ai/features/quick_check/domain/entities/verification_result.dart';

/// Regresi anti-duplikasi Riwayat: pill filter adalah satu-satunya
/// representasi angka komposisi (kartu statistik terpisah dihapus),
/// swipe dua arah, dan hapus dari layar detail.
VerificationResult _result({Verdict verdict = Verdict.hoaks}) {
  return VerificationResult(
    claim: 'Informasi uji anti-duplikasi yang cukup panjang.',
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
  int deletes = 0;

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
  }) async {
    deletes++;
  }
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
  group('Satu sumber angka: hanya pill filter', () {
    testWidgets('tanpa kartu statistik, angka verdict tunggal', (
      tester,
    ) async {
      await _pumpList(
        tester,
        entries: [
          _entry(id: 'a', verdict: Verdict.hoaks),
          _entry(id: 'b', verdict: Verdict.valid),
        ],
      );
      // Tiap label verdict tepat satu (dulu dua: pill + kolom statistik).
      expect(find.text('Hoaks'), findsOneWidget);
      expect(find.text('Valid'), findsOneWidget);
      expect(find.text('Perlu Dicek'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('0'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('tap pill memindahkan filter daftar', (tester) async {
      await _pumpList(
        tester,
        entries: [
          _entry(id: 'a', verdict: Verdict.hoaks),
          _entry(id: 'b', verdict: Verdict.valid),
        ],
      );
      expect(find.byType(HistoryCard), findsNWidgets(2));

      final validPill = find.descendant(
        of: find.byType(HistoryFilterBar),
        matching: find.text(AppStrings.historyFilterValid),
      );
      await tester.tap(validPill);
      await tester.pumpAndSettle();

      expect(find.byType(HistoryCard), findsOneWidget);
      expect(find.text('VALID'), findsOneWidget);
      expect(find.text('HOAKS'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });

  group('Swipe dua arah menghapus', () {
    testWidgets('geser kiri menghapus + urungkan', (tester) async {
      await _pumpList(
        tester,
        entries: [_entry(id: 'a', verdict: Verdict.hoaks)],
      );
      await tester.drag(find.byType(HistoryCard), const Offset(-420, 0));
      await tester.pumpAndSettle();

      expect(find.byType(HistoryCard), findsNothing);
      expect(find.text(AppStrings.historyDeleted), findsOneWidget);
      expect(find.text(AppStrings.historyUndo), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('geser kanan menghapus + urungkan', (tester) async {
      await _pumpList(
        tester,
        entries: [_entry(id: 'a', verdict: Verdict.hoaks)],
      );
      await tester.drag(find.byType(HistoryCard), const Offset(420, 0));
      await tester.pumpAndSettle();

      expect(find.byType(HistoryCard), findsNothing);
      expect(find.text(AppStrings.historyDeleted), findsOneWidget);
      expect(find.text(AppStrings.historyUndo), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('Hapus dari layar detail', () {
    Future<void> pumpDetail(
      WidgetTester tester, {
      required HistoryRepository repository,
    }) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            historyRepositoryProvider.overrideWithValue(repository),
            historyUserIdProvider.overrideWithValue('user-1'),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: HistoryDetailScreen(entry: _entry(id: 'a')),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('ikon hapus + dialog konfirmasi + undo', (tester) async {
      final repository = _FakeHistoryRepository(
        entries: [_entry(id: 'a')],
      );
      await pumpDetail(tester, repository: repository);

      await tester.tap(find.byIcon(Icons.delete_outline_rounded));
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.historyDeleteTitle), findsOneWidget);

      await tester.tap(find.text(AppStrings.historyDeleteConfirm));
      await tester.pumpAndSettle();

      expect(repository.deletes, 1);
      expect(find.text(AppStrings.historyDeleted), findsOneWidget);
      expect(find.text(AppStrings.historyUndo), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('batal mempertahankan entri', (tester) async {
      final repository = _FakeHistoryRepository(
        entries: [_entry(id: 'a')],
      );
      await pumpDetail(tester, repository: repository);

      await tester.tap(find.byIcon(Icons.delete_outline_rounded));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.historyDeleteCancel));
      await tester.pumpAndSettle();

      expect(repository.deletes, 0);
      expect(find.byType(HistoryDetailScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
