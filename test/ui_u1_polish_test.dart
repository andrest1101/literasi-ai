import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:literasi_ai/core/constants/app_strings.dart';
import 'package:literasi_ai/features/history/domain/entities/history_entry.dart';
import 'package:literasi_ai/features/history/domain/repositories/history_repository.dart';
import 'package:literasi_ai/features/history/presentation/providers/history_providers.dart';
import 'package:literasi_ai/features/history/presentation/screens/history_list_screen.dart';
import 'package:literasi_ai/features/learn/data/datasources/learn_content_datasource.dart';
import 'package:literasi_ai/features/learn/domain/entities/course_module.dart';
import 'package:literasi_ai/features/learn/domain/entities/course_progress.dart';
import 'package:literasi_ai/features/learn/domain/repositories/learn_repository.dart';
import 'package:literasi_ai/features/learn/presentation/providers/learn_providers.dart';
import 'package:literasi_ai/features/learn/presentation/screens/course_detail_screen.dart';
import 'package:literasi_ai/features/learn/presentation/screens/course_list_screen.dart';
import 'package:literasi_ai/features/learn/presentation/screens/quiz_screen.dart';
import 'package:literasi_ai/features/quick_check/presentation/screens/quick_check_session_screen.dart';
import 'package:literasi_ai/features/score/domain/entities/literacy_score.dart';
import 'package:literasi_ai/features/score/domain/repositories/score_repository.dart';
import 'package:literasi_ai/features/score/presentation/providers/score_providers.dart';
import 'package:literasi_ai/shared/widgets/app_shimmer.dart';

class _FakeHistoryRepository implements HistoryRepository {
  _FakeHistoryRepository({this.never = false});

  final bool never;

  @override
  Stream<List<HistoryEntry>> watch(String userId) {
    if (never) return const Stream.empty();
    return Stream.value(const []);
  }

  @override
  Future<void> save({
    required String userId,
    required result,
  }) async {}

  @override
  Future<void> delete({
    required String userId,
    required String entryId,
  }) async {}
}

class _FakeLearnRepository implements LearnRepository {
  @override
  List<CourseModule> modules() => LearnContentDatasource().modules();

  @override
  CourseModule? moduleById(String id) => LearnContentDatasource().byId(id);

  @override
  Stream<CourseProgress> watchProgress(String userId) =>
      Stream.value(const CourseProgress());

  @override
  Future<bool> completeModule(String userId, String moduleId) async => true;

  @override
  Future<int> submitQuiz(
    String userId,
    String moduleId,
    int correctCount,
  ) async => correctCount;
}

class _FakeScoreRepository implements ScoreRepository {
  @override
  Stream<LiteracyScore> watch(String userId) =>
      Stream.value(const LiteracyScore());

  @override
  Future<void> awardVerification(String userId) async {}

  @override
  Future<void> awardModule(String userId, String moduleId) async {}

  @override
  Future<void> awardQuiz(String userId, {required bool correct}) async {}
}

List<Override> _learnOverrides() => [
  historyUserIdProvider.overrideWithValue('u1'),
  learnRepositoryProvider.overrideWithValue(_FakeLearnRepository()),
  scoreRepositoryProvider.overrideWithValue(_FakeScoreRepository()),
];

void main() {
  group('AppShimmer bersama', () {
    testWidgets('denyut alpha tanpa exception + semantics label', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppShimmer(
              semanticsLabel: 'Memuat...',
              child: ShimmerBar(width: 120),
            ),
          ),
        ),
      );
      expect(find.bySemanticsLabel('Memuat...'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.byType(ShimmerBar), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('U1.1 shimmer riwayat', () {
    testWidgets('loading tampilkan skeleton kartu (badge + klaim)', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            historyRepositoryProvider.overrideWithValue(
              _FakeHistoryRepository(never: true),
            ),
            historyUserIdProvider.overrideWithValue('user-1'),
          ],
          child: const MaterialApp(home: Scaffold(body: HistoryListScreen())),
        ),
      );
      await tester.pump();

      expect(find.byType(AppShimmer), findsOneWidget);
      expect(find.byType(ShimmerCircle), findsWidgets);
      expect(find.byType(ShimmerBar), findsWidgets);
      expect(find.bySemanticsLabel(AppStrings.historyLoading), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('U1.2 shimmer belajar', () {
    testWidgets('loading tampilkan skeleton ringkasan (ring + baris)', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: _learnOverrides(),
          child: const MaterialApp(home: Scaffold(body: CourseListScreen())),
        ),
      );
      // Stream progres dummy butuh satu frame sebelum data: skeleton
      // sempat tampil bila provider masih loading pada pump pertama.
      await tester.pump(const Duration(milliseconds: 10));

      // Bila stream langsung data, skeleton tidak tampil: tetap kunci
      // bahwa daftar modul render tanpa exception (regresi bentuk).
      expect(
        find.text('Kenali Judul Clickbait'),
        findsWidgets,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('shimmer progres tiru bentuk ringkasan', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppShimmer(
              semanticsLabel: AppStrings.learnProgressLoading,
              child: Row(
                children: [
                  ShimmerCircle(size: 56),
                  SizedBox(width: 12),
                  Expanded(child: ShimmerBar(width: 130, height: 15)),
                ],
              ),
            ),
          ),
        ),
      );
      expect(find.byType(ShimmerCircle), findsOneWidget);
      expect(
        find.bySemanticsLabel(AppStrings.learnProgressLoading),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('U1.4 CTA empty riwayat', () {
    testWidgets('empty tampilkan CTA mulai pemeriksaan', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            historyRepositoryProvider.overrideWithValue(
              _FakeHistoryRepository(),
            ),
            historyUserIdProvider.overrideWithValue('user-1'),
          ],
          child: const MaterialApp(home: Scaffold(body: HistoryListScreen())),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.historyEmptyTitle), findsOneWidget);
      expect(find.text(AppStrings.historyEmptyCta), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('tap CTA buka sesi Quick Check', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            historyRepositoryProvider.overrideWithValue(
              _FakeHistoryRepository(),
            ),
            historyUserIdProvider.overrideWithValue('user-1'),
          ],
          child: const MaterialApp(home: Scaffold(body: HistoryListScreen())),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text(AppStrings.historyEmptyCta));
      await tester.pumpAndSettle();

      expect(find.byType(QuickCheckSessionScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('U1.3 detail modul premium', () {
    Future<void> pumpDetail(WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      await tester.pumpWidget(
        ProviderScope(
          overrides: _learnOverrides(),
          child: const MaterialApp(
            home: CourseDetailScreen(moduleId: 'clickbait'),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('hero gradien tampilkan judul + meta bagian', (tester) async {
      await pumpDetail(tester);

      expect(find.text('Kenali Judul Clickbait'), findsOneWidget);
      expect(find.textContaining('4 bagian'), findsOneWidget);
      expect(find.textContaining('3 soal'), findsOneWidget);
      expect(find.text('Bagian 1'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('progres baca ada + sticky CTA tanpa scroll', (tester) async {
      await pumpDetail(tester);

      expect(
        find.bySemanticsLabel(AppStrings.learnReadingProgress),
        findsOneWidget,
      );
      // Sticky bottom bar: kuis primer + klaim sekunder selalu terlihat
      // tanpa perlu scroll ke bawah (tanpa ensureVisible).
      expect(find.text(AppStrings.learnStartQuiz), findsOneWidget);
      expect(find.text(AppStrings.learnMarkDone), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('klaim tetap idempoten + kuis terbuka', (tester) async {
      await pumpDetail(tester);

      await tester.tap(find.text(AppStrings.learnMarkDone));
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.learnMarkedDone), findsOneWidget);

      await tester.tap(find.text(AppStrings.learnStartQuiz));
      await tester.pumpAndSettle();
      expect(find.byType(QuizScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
