import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:literasi_ai/core/constants/app_strings.dart';
import 'package:literasi_ai/core/utils/api_key_resolver.dart';
import 'package:literasi_ai/core/utils/api_key_store.dart';
import 'package:literasi_ai/features/history/presentation/providers/history_providers.dart';
import 'package:literasi_ai/features/learn/domain/entities/course_progress.dart';
import 'package:literasi_ai/features/learn/domain/repositories/learn_repository.dart';
import 'package:literasi_ai/features/learn/presentation/providers/learn_providers.dart';
import 'package:literasi_ai/features/learn/data/datasources/learn_content_datasource.dart';
import 'package:literasi_ai/features/learn/domain/entities/course_module.dart';
import 'package:literasi_ai/features/score/domain/entities/literacy_score.dart';
import 'package:literasi_ai/features/score/domain/repositories/score_repository.dart';
import 'package:literasi_ai/features/score/presentation/providers/score_providers.dart';
import 'package:literasi_ai/features/score/presentation/screens/api_key_screen.dart';
import 'package:literasi_ai/features/score/presentation/screens/profile_screen.dart';

class _MemoryKeyStore implements ApiKeyStore {
  String? value;

  @override
  Future<String?> read() async => value;

  @override
  Future<void> write(String key) async {
    value = key;
  }

  @override
  Future<void> clear() async {
    value = null;
  }
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
  _FakeScoreRepository({this.failTimes = 0});

  int failTimes;
  int calls = 0;

  @override
  Stream<LiteracyScore> watch(String userId) async* {
    calls++;
    if (calls <= failTimes) {
      throw Exception('stream putus');
    }
    yield const LiteracyScore();
  }

  @override
  Future<void> awardVerification(String userId) async {}

  @override
  Future<void> awardModule(String userId, String moduleId) async {}

  @override
  Future<void> awardQuiz(String userId, {required bool correct}) async {}
}

Future<void> _pumpProfile(WidgetTester tester, {Size? size}) async {
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
        apiKeyStoreProvider.overrideWithValue(_MemoryKeyStore()),
        historyUserIdProvider.overrideWithValue(null),
        learnRepositoryProvider.overrideWithValue(_FakeLearnRepository()),
        scoreRepositoryProvider.overrideWithValue(_FakeScoreRepository()),
      ],
      child: MaterialApp(
        home: const ProfileScreen(),
        routes: {ApiKeyScreen.route: (_) => const ApiKeyScreen()},
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _pumpProfileLoggedIn(
  WidgetTester tester, {
  required ScoreRepository scoreRepository,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        apiKeyStoreProvider.overrideWithValue(_MemoryKeyStore()),
        historyUserIdProvider.overrideWithValue('u1'),
        learnRepositoryProvider.overrideWithValue(_FakeLearnRepository()),
        scoreRepositoryProvider.overrideWithValue(scoreRepository),
      ],
      child: const MaterialApp(home: ProfileScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('resolveProfileName jujur dari data', () {
    test('displayName menang, prefix email fallback, tamu terakhir', () {
      expect(
        resolveProfileName('  Budi Santoso ', 'budi@x.id'),
        'Budi Santoso',
      );
      expect(resolveProfileName(null, 'budi.santoso@x.id'), 'budi.santoso');
      expect(resolveProfileName('   ', 'budi@x.id'), 'budi');
      expect(resolveProfileName(null, null), AppStrings.scoreGuestLabel);
      expect(resolveProfileName(null, ''), AppStrings.scoreGuestLabel);
    });
  });

  group('Menu pengaturan profil', () {
    testWidgets('identitas + skor grup + menu tampil sekali', (tester) async {
      await _pumpProfile(tester);

      // Kartu identitas: tamu (ikon person, tanpa huruf "T") + pill.
      expect(find.text(AppStrings.scoreGuestLabel), findsOneWidget);
      expect(find.textContaining(AppStrings.scoreLevelPrefix), findsOneWidget);
      expect(find.text(AppStrings.profileGuestPill), findsOneWidget);
      expect(find.byIcon(Icons.person_outline_rounded), findsOneWidget);
      expect(find.text('T'), findsNothing);
      // Grup skor: ring + rincian tanpa judul ganda.
      expect(find.text('Skor & sumber poin'), findsNothing);
      expect(find.text('Sumber poin'), findsNothing);
      expect(find.text('0 x 10'), findsOneWidget);
      expect(find.text('0 x 20'), findsOneWidget);
      expect(find.text('0 x 5'), findsOneWidget);
      expect(find.text(AppStrings.scoreModuleSoon), findsOneWidget);
      // Grup menu tamu: 2 baris fungsi nyata, tanpa baris Keluar.
      expect(find.text(AppStrings.profileMenuTitle), findsOneWidget);
      expect(find.text(AppStrings.profileApiKeyRow), findsOneWidget);
      expect(find.text(AppStrings.profileAboutRow), findsOneWidget);
      expect(find.text(AppStrings.profileLogoutRow), findsNothing);
      // Tanpa tombol gaya lama yang sudah digabung ke baris menu.
      expect(find.text(AppStrings.apiKeyOpenSettings), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('baris kunci menuju layar pengaturan', (tester) async {
      await _pumpProfile(tester);

      final row = find.text(AppStrings.profileApiKeyRow);
      await tester.ensureVisible(row);
      await tester.pumpAndSettle();
      await tester.tap(row);
      await tester.pumpAndSettle();
      expect(find.byType(ApiKeyScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('baris tentang membuka dialog versi', (tester) async {
      await _pumpProfile(tester);

      final row = find.text(AppStrings.profileAboutRow);
      await tester.ensureVisible(row);
      await tester.pumpAndSettle();
      await tester.tap(row);
      await tester.pumpAndSettle();
      // Dialog satu keluarga: ikon + judul + body + tombol tutup.
      expect(find.text(AppStrings.profileAboutBody), findsOneWidget);
      expect(find.byIcon(Icons.info_outline_rounded), findsWidgets);
      await tester.tap(find.text(AppStrings.profileAboutClose));
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.profileAboutBody), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('tamu tanpa baris keluar: tidak ada sesi dibersihkan', (
      tester,
    ) async {
      await _pumpProfile(tester);

      // Tamu tidak login: tidak ada baris destruktif apa pun. Aksi akun
      // tamu cukup CTA "Masuk untuk sinkron" di kartu identitas.
      expect(find.text(AppStrings.profileLogoutRow), findsNothing);
      expect(find.text(AppStrings.scoreLoginCta), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('login error: pill Offline netral + kartu error', (
      tester,
    ) async {
      await _pumpProfileLoggedIn(
        tester,
        scoreRepository: _FakeScoreRepository(failTimes: 99),
      );

      // Stream selalu gagal (melewati retry + timeout): kartu error tampil
      // dengan copy diagnostik yang tetap ramah, pill status Offline.
      expect(find.text(AppStrings.scoreLoadFailed), findsOneWidget);
      expect(find.text(AppStrings.scoreLoadFailedSubtitle), findsOneWidget);
      expect(find.text(AppStrings.profileOfflineLabel), findsOneWidget);
      expect(find.text(AppStrings.profileSyncedLabel), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('login retry: gagal 2x lalu sukses tampil data', (
      tester,
    ) async {
      final repo = _FakeScoreRepository(failTimes: 2);
      await _pumpProfileLoggedIn(tester, scoreRepository: repo);

      // Retry otomatis 2x backoff menyembuhkan stream putus sesaat
      // (kasus Alt+Tab): data tampil, tanpa kartu error.
      expect(find.text(AppStrings.scoreLoadFailed), findsNothing);
      expect(find.text('0 x 10'), findsOneWidget);
      expect(repo.calls, 3);
      expect(tester.takeException(), isNull);
    });

    for (final size in [const Size(360, 800), const Size(412, 915)]) {
      testWidgets('render ${size.width.toInt()}px tanpa exception', (
        tester,
      ) async {
        await _pumpProfile(tester, size: size);

        expect(find.text(AppStrings.scoreGuestLabel), findsOneWidget);
        await tester.ensureVisible(find.text(AppStrings.profileAboutRow));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }
  });
}
