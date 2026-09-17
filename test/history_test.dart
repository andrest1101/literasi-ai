import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:literasi_ai/core/constants/app_strings.dart';
import 'package:literasi_ai/features/history/data/models/history_doc_model.dart';
import 'package:literasi_ai/features/history/domain/entities/history_entry.dart';
import 'package:literasi_ai/features/history/domain/entities/history_filter.dart';
import 'package:literasi_ai/features/history/domain/repositories/history_repository.dart';
import 'package:literasi_ai/features/history/domain/usecases/delete_history.dart';
import 'package:literasi_ai/features/history/domain/usecases/save_history.dart';
import 'package:literasi_ai/features/history/presentation/providers/history_providers.dart';
import 'package:literasi_ai/features/history/presentation/screens/history_detail_screen.dart';
import 'package:literasi_ai/features/history/presentation/screens/history_list_screen.dart';
import 'package:literasi_ai/features/history/presentation/widgets/history_card.dart';
import 'package:literasi_ai/features/history/presentation/widgets/history_empty_state.dart';
import 'package:literasi_ai/features/history/presentation/widgets/history_filter_bar.dart';
import 'package:literasi_ai/features/quick_check/domain/entities/verification_result.dart';
import 'package:literasi_ai/features/quick_check/domain/repositories/verification_repository.dart';
import 'package:literasi_ai/features/quick_check/domain/entities/image_attachment.dart';
import 'package:literasi_ai/features/quick_check/presentation/providers/verification_provider.dart';

VerificationResult _result({Verdict verdict = Verdict.hoaks}) {
  return VerificationResult(
    claim: 'Informasi uji untuk riwayat yang cukup panjang.',
    verdict: verdict,
    confidence: 87,
    explanation: 'Penjelasan hasil uji.',
    suggestion: 'Saran hasil uji.',
    checkedAt: DateTime.utc(2026, 9, 16, 12, 0),
    source: VerificationSource.url,
    sourceUrl: 'https://contoh.id/berita',
    sourceTitle: 'Judul uji artikel.',
  );
}

HistoryEntry _entry({String id = 'entry-1', Verdict verdict = Verdict.hoaks}) {
  return HistoryEntry(id: id, result: _result(verdict: verdict));
}

class _FakeHistoryRepository implements HistoryRepository {
  _FakeHistoryRepository({this.entries = const [], this.failure});

  final List<HistoryEntry> entries;
  final Object? failure;
  int saves = 0;
  int deletes = 0;
  String? lastSavedUser;

  @override
  Stream<List<HistoryEntry>> watch(String userId) {
    if (failure != null) return Stream.error(failure!);
    return Stream.value(entries);
  }

  @override
  Future<void> save({
    required String userId,
    required VerificationResult result,
  }) async {
    saves++;
    lastSavedUser = userId;
    if (failure != null) throw failure!;
  }

  @override
  Future<void> delete({required String userId, required String entryId}) async {
    deletes++;
    if (failure != null) throw failure!;
  }
}

class _FakeVerifyRepository implements VerificationRepository {
  @override
  Future<VerificationResult> verifyTextClaim(String claim) async =>
      _result(verdict: Verdict.valid);

  @override
  Future<VerificationResult> verifyImageClaim({
    required ImageAttachment image,
    String caption = '',
  }) async => _result(verdict: Verdict.valid);

  @override
  Future<VerificationResult> verifyUrlClaim({required String url}) async =>
      _result(verdict: Verdict.valid);
}

Future<void> _pumpHistory(
  WidgetTester tester, {
  required HistoryRepository repository,
  String? userId,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        historyRepositoryProvider.overrideWithValue(repository),
        historyUserIdProvider.overrideWithValue(userId),
        historyFilterProvider.overrideWith((ref) => HistoryFilter.all),
      ],
      child: const MaterialApp(home: Scaffold(body: HistoryListScreen())),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('HistoryDocModel', () {
    test('toDocument writes utc iso8601 and url fields', () {
      final doc = HistoryDocModel.toDocument(_result());

      expect(doc['verdict'], 'HOAKS');
      expect(doc['confidence'], 87);
      expect(doc['source'], 'url');
      expect(doc['sourceUrl'], 'https://contoh.id/berita');
      expect(doc['sourceTitle'], 'Judul uji artikel.');
      expect(doc['checkedAt'], '2026-09-16T12:00:00.000Z');
    });

    test('fromMap restores verdict, source, and timestamps', () {
      final entry = HistoryDocModel.fromMap('doc-1', {
        'claim': 'Klaim tersimpan.',
        'verdict': 'VALID',
        'confidence': 90,
        'explanation': 'Penjelasan.',
        'suggestion': 'Saran.',
        'checkedAt': '2026-09-15T10:00:00.000Z',
        'source': 'url',
        'sourceUrl': 'https://contoh.id/berita',
        'sourceTitle': 'Judul tersimpan.',
      });

      expect(entry.id, 'doc-1');
      expect(entry.result.verdict, Verdict.valid);
      expect(entry.result.source, VerificationSource.url);
      expect(entry.result.sourceUrl, 'https://contoh.id/berita');
      expect(entry.result.checkedAt.toUtc().toIso8601String(),
          '2026-09-15T10:00:00.000Z');
    });

    test('fromMap falls back safely for corrupt docs', () {
      final entry = HistoryDocModel.fromMap('doc-2', const {});

      expect(entry.id, 'doc-2');
      expect(entry.result.verdict, Verdict.tidakDapatDipastikan);
      expect(entry.result.source, VerificationSource.text);
      expect(entry.result.confidence, 0);
    });
  });

  group('SaveHistory/DeleteHistory usecases', () {
    test('save forwards uid and result', () async {
      final repo = _FakeHistoryRepository();
      await SaveHistory(repo)(userId: 'user-1', result: _result());

      expect(repo.saves, 1);
      expect(repo.lastSavedUser, 'user-1');
    });

    test('delete forwards uid and entry id', () async {
      final repo = _FakeHistoryRepository();
      await DeleteHistory(repo)(userId: 'user-1', entryId: 'entry-1');

      expect(repo.deletes, 1);
    });
  });

  group('History providers', () {
    test('filter defaults to all', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(historyFilterProvider), HistoryFilter.all);
    });

    test('entries stream emits repository values', () async {
      final container = ProviderContainer(
        overrides: [
          historyRepositoryProvider.overrideWithValue(
            _FakeHistoryRepository(entries: [_entry(), _entry(id: 'entry-2')]),
          ),
          historyUserIdProvider.overrideWithValue('user-1'),
        ],
      );
      addTearDown(container.dispose);

      final entries = await container.read(historyEntriesProvider.future);

      expect(entries, hasLength(2));
    });

    test('delete action marks error on failure', () async {
      final container = ProviderContainer(
        overrides: [
          historyRepositoryProvider.overrideWithValue(
            _FakeHistoryRepository(failure: Exception('firestore down')),
          ),
          historyUserIdProvider.overrideWithValue('user-1'),
        ],
      );
      addTearDown(container.dispose);

      await container
          .read(historyActionProvider.notifier)
          .delete('entry-1');

      expect(container.read(historyActionProvider).hasError, isTrue);
    });
  });

  group('HistoryFilter', () {
    test('matches intended verdicts', () {
      expect(HistoryFilter.all.matches(Verdict.tidakDapatDipastikan), isTrue);
      expect(HistoryFilter.hoaks.matches(Verdict.hoaks), isTrue);
      expect(HistoryFilter.valid.matches(Verdict.valid), isTrue);
      expect(HistoryFilter.perluDicek.matches(Verdict.perluDicek), isTrue);
      expect(HistoryFilter.valid.matches(Verdict.hoaks), isFalse);
    });
  });

  testWidgets('history card shows verdict, confidence, host, and claim',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: HistoryCard(entry: _entry(), onTap: () {})),
      ),
    );

    expect(find.text('HOAKS'), findsOneWidget);
    expect(find.text('87%'), findsOneWidget);
    expect(find.text('contoh.id'), findsOneWidget);
    expect(find.textContaining('Informasi uji'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('empty state distinguishes no data from empty filter',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: HistoryEmptyState(filtered: false)),
      ),
    );
    expect(find.text(AppStrings.historyEmptyTitle), findsOneWidget);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: HistoryEmptyState(filtered: true)),
      ),
    );
    expect(find.text(AppStrings.historyEmptyFilteredTitle), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('filter bar switches active verdict', (tester) async {
    HistoryFilter? selected;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HistoryFilterBar(
            selected: HistoryFilter.all,
            onSelected: (value) => selected = value,
          ),
        ),
      ),
    );

    await tester.tap(find.text(AppStrings.historyFilterHoaks));
    expect(selected, HistoryFilter.hoaks);
    expect(tester.takeException(), isNull);
  });

  testWidgets('list filters cards by verdict', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          historyRepositoryProvider.overrideWithValue(
            _FakeHistoryRepository(entries: [
              _entry(id: 'hoaks', verdict: Verdict.hoaks),
              _entry(id: 'valid', verdict: Verdict.valid),
            ]),
          ),
          historyUserIdProvider.overrideWithValue('user-1'),
        ],
        child: const MaterialApp(home: Scaffold(body: HistoryListScreen())),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(HistoryCard), findsNWidgets(2));

    await tester.tap(find.text(AppStrings.historyFilterHoaks));
    await tester.pumpAndSettle();

    expect(find.byType(HistoryCard), findsOneWidget);
    expect(find.text('HOAKS'), findsOneWidget);
    expect(find.text('VALID'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('list shows empty state without login', (tester) async {
    await _pumpHistory(
      tester,
      repository: _FakeHistoryRepository(entries: [_entry()]),
      userId: null,
    );

    expect(find.text(AppStrings.historyEmptyTitle), findsOneWidget);
    expect(find.byType(HistoryCard), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('list surfaces retryable error', (tester) async {
    await _pumpHistory(
      tester,
      repository: _FakeHistoryRepository(failure: Exception('down')),
      userId: 'user-1',
    );

    expect(find.text('Verifikasi gagal'), findsOneWidget);
    expect(find.text(AppStrings.quickCheckRetry), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('swipe delete removes card and offers undo', (tester) async {
    await _pumpHistory(
      tester,
      repository: _FakeHistoryRepository(entries: [_entry()]),
      userId: 'user-1',
    );

    await tester.drag(find.byType(HistoryCard), const Offset(-420, 0));
    await tester.pumpAndSettle();

    expect(find.byType(HistoryCard), findsNothing);
    expect(find.text(AppStrings.historyDeleted), findsOneWidget);
    expect(find.text(AppStrings.historyUndo), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tap opens detail with share action', (tester) async {
    await _pumpHistory(
      tester,
      repository: _FakeHistoryRepository(entries: [_entry()]),
      userId: 'user-1',
    );

    await tester.tap(find.byType(HistoryCard));
    await tester.pumpAndSettle();

    expect(find.byType(HistoryDetailScreen), findsOneWidget);
    expect(find.text(AppStrings.historyDetailTitle), findsOneWidget);
    expect(find.text(AppStrings.quickCheckShare), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('successful verify auto-saves history', (tester) async {
    final history = _FakeHistoryRepository();
    final container = ProviderContainer(
      overrides: [
        verificationRepositoryProvider.overrideWithValue(
          _FakeVerifyRepository(),
        ),
        historyRepositoryProvider.overrideWithValue(history),
        historyUserIdProvider.overrideWithValue('user-1'),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: Scaffold()),
      ),
    );

    await container
        .read(quickCheckControllerProvider.notifier)
        .verify('Klaim uji yang cukup panjang untuk validasi.');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(history.saves, 1);
    expect(history.lastSavedUser, 'user-1');
    expect(tester.takeException(), isNull);
  });
}
