import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:literasi_ai/core/constants/app_strings.dart';
import 'package:literasi_ai/core/utils/url_fetcher.dart';
import 'package:literasi_ai/features/history/domain/entities/history_entry.dart';
import 'package:literasi_ai/features/history/domain/entities/history_filter.dart';
import 'package:literasi_ai/features/history/domain/repositories/history_repository.dart';
import 'package:literasi_ai/features/history/presentation/providers/history_providers.dart';
import 'package:literasi_ai/features/history/presentation/screens/history_list_screen.dart';
import 'package:literasi_ai/features/history/presentation/widgets/history_card.dart';
import 'package:literasi_ai/features/quick_check/data/datasources/gemini_text_datasource.dart';
import 'package:literasi_ai/features/quick_check/domain/entities/verification_result.dart';
import 'package:literasi_ai/features/quick_check/presentation/widgets/quick_check_analyzing_indicator.dart';
import 'package:literasi_ai/features/quick_check/presentation/widgets/quick_check_result_section.dart';
import 'package:literasi_ai/features/quick_check/presentation/widgets/verdict_presentation.dart';

VerificationResult _result({Verdict verdict = Verdict.hoaks}) {
  return VerificationResult(
    claim: 'Klaim uji upgrade premium yang cukup panjang.',
    verdict: verdict,
    confidence: 87,
    explanation: 'Penjelasan uji.',
    suggestion: 'Saran uji.',
    checkedAt: DateTime(2026, 9, 27),
  );
}

HistoryEntry _entry({String id = 'e1', Verdict verdict = Verdict.hoaks}) {
  return HistoryEntry(id: id, result: _result(verdict: verdict));
}

class _FakeHistoryRepository implements HistoryRepository {
  _FakeHistoryRepository(this.entries);

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

void main() {
  group('VerdictPresentation premium', () {
    test('headline unik per verdict dan aksen tetap 4 warna', () {
      final headlines =
          Verdict.values.map((v) => VerdictPresentation.of(v).headline);
      expect(headlines.toSet(), hasLength(4));
      expect(VerdictPresentation.of(Verdict.hoaks).headline, isNotEmpty);

      final accents =
          Verdict.values.map((v) => VerdictPresentation.of(v).accent).toSet();
      expect(accents, hasLength(4));
    });
  });

  group('GeminiTextDatasource sanitasi + OG fetcher', () {
    test('datasource dibuat untuk model flash publik', () {
      expect(GeminiTextDatasource.defaultModelName, 'gemini-3.6-flash');
    });

    test('fetcher memakai og:title bila title kosong', () async {
      final client = MockClient((request) async {
        return http.Response(
          '<html><head>'
          '<meta property="og:title" content="Judul OG Uji">'
          '<meta property="og:description" content="Deskripsi OG Uji">'
          '</head></html>',
          200,
        );
      });
      final metadata = await UrlFetcher(
        client: client,
      ).fetchMetadata('https://contoh.id/berita');
      expect(metadata.title, 'Judul OG Uji');
      expect(metadata.description, 'Deskripsi OG Uji');
    });

    test('fetcher membersihkan entity html', () async {
      final client = MockClient((request) async {
        return http.Response(
          '<html><head><title>Judul &amp; Uji</title></head></html>',
          200,
        );
      });
      final metadata = await UrlFetcher(
        client: client,
      ).fetchMetadata('https://contoh.id/berita');
      expect(metadata.title, 'Judul & Uji');
    });
  });

  testWidgets('kartu hasil tampilkan headline + tombol salin', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: QuickCheckResultSection(
              result: _result(verdict: Verdict.hoaks),
              loading: false,
              onNewCheck: () {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text(VerdictPresentation.of(Verdict.hoaks).headline),
      findsOneWidget,
    );
    expect(find.text(AppStrings.quickCheckCopy), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('analyzing jujur: detik berjalan tanpa persen palsu', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: QuickCheckAnalyzingIndicator()),
      ),
    );
    await tester.pump();

    expect(find.text('0 dtk'), findsOneWidget);
    expect(find.textContaining('%'), findsNothing);
    expect(find.text('Memahami informasi'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('riwayat tampilkan search + ringkasan + filter gabungan', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          historyRepositoryProvider.overrideWithValue(
            _FakeHistoryRepository([
              _entry(id: 'hoaks-1', verdict: Verdict.hoaks),
              _entry(id: 'valid-1', verdict: Verdict.valid),
            ]),
          ),
          historyUserIdProvider.overrideWithValue('user-1'),
        ],
        child: const MaterialApp(home: Scaffold(body: HistoryListScreen())),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.historySearchHint), findsOneWidget);
    // Pill filter adalah satu-satunya representasi angka (kartu statistik
    // terpisah dihapus agar tidak ganda): Semua=2, Hoaks=1, Valid=1,
    // Perlu Dicek=0. Label verdict hanya di pill.
    expect(find.text('Semua'), findsOneWidget);
    expect(find.text('Hoaks'), findsOneWidget);
    expect(find.text('Valid'), findsOneWidget);
    expect(find.text('Perlu Dicek'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('0'), findsOneWidget);
    expect(find.byType(HistoryCard), findsNWidgets(2));

    await tester.enterText(
      find.byType(TextField).first,
      'tidak ada yang cocok xyz',
    );
    await tester.pumpAndSettle();
    expect(find.byType(HistoryCard), findsNothing);
    expect(tester.takeException(), isNull);
  });

  test('search provider default kosong', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    expect(container.read(historySearchProvider), '');
  });

  test('filter verdict tetap 4 nilai sesuai PRD', () {
    expect(HistoryFilter.values, hasLength(4));
    expect(HistoryFilter.hoaks.matches(Verdict.hoaks), isTrue);
  });
}
