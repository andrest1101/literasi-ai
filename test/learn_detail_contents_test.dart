import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:literasi_ai/core/constants/app_colors.dart';
import 'package:literasi_ai/core/constants/app_strings.dart';
import 'package:literasi_ai/features/history/presentation/providers/history_providers.dart';
import 'package:literasi_ai/features/learn/data/datasources/learn_content_datasource.dart';
import 'package:literasi_ai/features/learn/domain/entities/course_module.dart';
import 'package:literasi_ai/features/learn/domain/entities/course_progress.dart';
import 'package:literasi_ai/features/learn/domain/repositories/learn_repository.dart';
import 'package:literasi_ai/features/learn/presentation/providers/learn_providers.dart';
import 'package:literasi_ai/features/learn/presentation/screens/course_detail_screen.dart';
import 'package:literasi_ai/features/score/domain/entities/literacy_score.dart';
import 'package:literasi_ai/features/score/domain/repositories/score_repository.dart';
import 'package:literasi_ai/features/score/presentation/providers/score_providers.dart';

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

Future<void> _pumpDetail(
  WidgetTester tester, {
  String moduleId = 'clickbait',
  Size? size,
}) async {
  if (size != null) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        historyUserIdProvider.overrideWithValue('u1'),
        learnRepositoryProvider.overrideWithValue(_FakeLearnRepository()),
        scoreRepositoryProvider.overrideWithValue(_FakeScoreRepository()),
      ],
      child: MaterialApp(home: CourseDetailScreen(moduleId: moduleId)),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('D1 kartu Isi modul dari data', () {
    testWidgets('judul + 4 heading seksi tampil sekali', (tester) async {
      await _pumpDetail(tester);

      expect(find.text(AppStrings.learnContentsTitle), findsOneWidget);
      final module = LearnContentDatasource().byId('clickbait')!;
      for (final section in module.sections) {
        // Judul seksi muncul 2x: baris daftar isi + kartu artikel.
        expect(find.text(section.heading), findsNWidgets(2));
      }
      expect(tester.takeException(), isNull);
    });

    testWidgets('urutan: hero, isi, artikel, CTA sticky utuh', (tester) async {
      await _pumpDetail(tester);

      final heroTitle = tester.getTopLeft(find.text('Kenali Judul Clickbait'));
      final contents = tester.getTopLeft(
        find.text(AppStrings.learnContentsTitle),
      );
      final firstSection = tester.getTopLeft(find.text('Bagian 1'));
      expect(heroTitle.dy, lessThan(contents.dy));
      expect(contents.dy, lessThan(firstSection.dy));
      // CTA + klaim tetap sticky terlihat tanpa scroll.
      expect(find.text(AppStrings.learnStartQuiz), findsOneWidget);
      expect(find.text(AppStrings.learnMarkDone), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('D2 ritme seksi: rel nomor + tint motif', () {
    testWidgets('label Bagian 1-4 tetap + medallion tint modul', (
      tester,
    ) async {
      await _pumpDetail(tester);

      for (var n = 1; n <= 4; n++) {
        expect(find.text('Bagian $n'), findsOneWidget);
      }
      // Medallion memakai tint identitas modul, bukan primer generik:
      // seksi 2 (non-featured) modul clickbait berikon primaryDark,
      // warna tint motif seed 0.
      final secondIcon = tester.widget<Icon>(
        find.byIcon(Icons.timer_outlined),
      );
      expect(secondIcon.color, AppColors.primaryDark);
      expect(tester.takeException(), isNull);
    });

    for (final size in [const Size(360, 800), const Size(412, 915)]) {
      testWidgets('render ${size.width.toInt()}px tanpa exception', (
        tester,
      ) async {
        await _pumpDetail(tester, size: size);

        expect(find.text('Kenali Judul Clickbait'), findsOneWidget);
        await tester.ensureVisible(find.text('Bagian 4'));
        await tester.pumpAndSettle();
        expect(find.text('Bagian 4'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  });
}
