import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:literasi_ai/app/home_screen.dart';
import 'package:literasi_ai/features/history/presentation/providers/history_providers.dart';
import 'package:literasi_ai/features/quick_check/presentation/screens/quick_check_home_tab.dart';
import 'package:literasi_ai/features/score/data/models/score_doc_model.dart';
import 'package:literasi_ai/features/score/domain/entities/literacy_level.dart';
import 'package:literasi_ai/features/score/domain/entities/literacy_score.dart';
import 'package:literasi_ai/features/score/domain/repositories/score_repository.dart';
import 'package:literasi_ai/features/score/domain/usecases/award_score.dart';
import 'package:literasi_ai/features/score/presentation/providers/score_providers.dart';
import 'package:literasi_ai/features/score/presentation/screens/profile_screen.dart';
import 'package:literasi_ai/features/score/presentation/widgets/score_breakdown.dart';
import 'package:literasi_ai/features/score/presentation/widgets/score_check_chip.dart';
import 'package:literasi_ai/features/score/presentation/widgets/score_ring.dart';

class _FakeScoreRepository implements ScoreRepository {
  _FakeScoreRepository({this.score = const LiteracyScore()});

  LiteracyScore score;
  int verifications = 0;
  int modules = 0;
  int quizzes = 0;

  @override
  Stream<LiteracyScore> watch(String userId) => Stream.value(score);

  @override
  Future<void> awardVerification(String userId) async {
    verifications++;
  }

  @override
  Future<void> awardModule(String userId, String moduleId) async {
    modules++;
  }

  @override
  Future<void> awardQuiz(String userId, {required bool correct}) async {
    if (correct) quizzes++;
  }
}

void main() {
  group('LiteracyLevel ambang Standar', () {
    test('maps totals to levels', () {
      expect(LiteracyLevel.of(0), LiteracyLevel.pemula);
      expect(LiteracyLevel.of(49), LiteracyLevel.pemula);
      expect(LiteracyLevel.of(50), LiteracyLevel.waspada);
      expect(LiteracyLevel.of(149), LiteracyLevel.waspada);
      expect(LiteracyLevel.of(150), LiteracyLevel.kritis);
      expect(LiteracyLevel.of(299), LiteracyLevel.kritis);
      expect(LiteracyLevel.of(300), LiteracyLevel.ahli);
      expect(LiteracyLevel.of(9999), LiteracyLevel.ahli);
    });
  });

  group('LiteracyScore entity', () {
    test('totals follow PRD rates', () {
      const score = LiteracyScore(
        verifications: 3,
        modulesDone: ['clickbait'],
        quizCorrect: 2,
      );
      expect(score.verificationTotal, 30);
      expect(score.moduleTotal, 20);
      expect(score.quizTotal, 10);
      expect(score.total, 60);
      expect(score.level, LiteracyLevel.waspada);
      expect(score.pointsToNext, 90);
    });

    test('ahli has no next level', () {
      const score = LiteracyScore(verifications: 30);
      expect(score.total, 300);
      expect(score.level, LiteracyLevel.ahli);
      expect(score.pointsToNext, 0);
      expect(score.progressInLevel, 1.0);
    });
  });

  group('ScoreDocModel', () {
    test('fromMap restores counters', () {
      final score = ScoreDocModel.fromMap({
        'verifications': 5,
        'modulesDone': ['clickbait'],
        'quizCorrect': 2,
      });
      expect(score.verifications, 5);
      expect(score.modulesDone, ['clickbait']);
      expect(score.total, 80);
    });

    test('fromMap falls back safely for corrupt docs', () {
      final score = ScoreDocModel.fromMap({
        'verifications': -3,
        'modulesDone': 'bukan-list',
        'quizCorrect': 'NaN',
      });
      expect(score.total, 0);
      expect(score.level, LiteracyLevel.pemula);
    });
  });

  group('Award usecases', () {
    test('ignore empty user without calling repository', () async {
      final repo = _FakeScoreRepository();
      await AwardVerification(repo)('');
      await AwardModule(repo)('', 'm1');
      await AwardQuiz(repo)('', correct: true);
      expect(repo.verifications, 0);
      expect(repo.modules, 0);
      expect(repo.quizzes, 0);
    });

    test('forward valid awards', () async {
      final repo = _FakeScoreRepository();
      await AwardVerification(repo)('u1');
      await AwardModule(repo)('u1', 'clickbait');
      await AwardQuiz(repo)('u1', correct: true);
      await AwardQuiz(repo)('u1', correct: false);
      expect(repo.verifications, 1);
      expect(repo.modules, 1);
      expect(repo.quizzes, 1);
    });
  });

  group('Score providers', () {
    test('emits zero score without login', () async {
      final container = ProviderContainer(
        overrides: [historyUserIdProvider.overrideWithValue(null)],
      );
      addTearDown(container.dispose);
      final score = await container.read(scoreProvider.future);
      expect(score.total, 0);
    });

    test('emits repository score for logged user', () async {
      final container = ProviderContainer(
        overrides: [
          historyUserIdProvider.overrideWithValue('u1'),
          scoreRepositoryProvider.overrideWithValue(
            _FakeScoreRepository(
              score: const LiteracyScore(verifications: 6),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);
      final score = await container.read(scoreProvider.future);
      expect(score.total, 60);
      expect(score.level, LiteracyLevel.waspada);
    });
  });

  testWidgets('ring and breakdown render score honestly', (
    WidgetTester tester,
  ) async {
    const score = LiteracyScore(verifications: 6);
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: Column(
              children: [ScoreRing(score: score), ScoreBreakdown(score: score)],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('60'), findsOneWidget);
    expect(find.text('Waspada'), findsOneWidget);
    expect(find.text('90 poin lagi ke Kritis.'), findsOneWidget);
    expect(find.text('6 x 10'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('profile shows score and honest account card', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          historyUserIdProvider.overrideWithValue(null),
          scoreRepositoryProvider.overrideWithValue(_FakeScoreRepository()),
        ],
        child: const MaterialApp(home: ProfileScreen()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('Kelola'), findsOneWidget);
    expect(find.text('Pemula'), findsOneWidget);
    expect(find.text('Sumber poin'), findsOneWidget);
    expect(find.text('Tamu LiterasiAI'), findsOneWidget);
    expect(find.text('Masuk untuk sinkron'), findsOneWidget);
    expect(find.textContaining('tanpa akun'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('check chip navigates to profile tab', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: HomeScreen())),
    );
    await tester.pumpAndSettle();
    expect(find.byType(ScoreCheckChip), findsOneWidget);
    // Header compact U2: label level + poin terpisah, bukan satu string.
    expect(find.text('Pemula'), findsOneWidget);
    expect(find.textContaining('0 poin'), findsOneWidget);

    await tester.tap(find.byType(ScoreCheckChip));
    await tester.pumpAndSettle();
    expect(find.textContaining('Kelola'), findsOneWidget);
    expect(find.text('Sumber poin'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('quick check tab renders chip without profile callback', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: QuickCheckHomeTab())),
    );
    await tester.pumpAndSettle();
    expect(find.byType(ScoreCheckChip), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
