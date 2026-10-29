import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../history/presentation/providers/history_providers.dart';
import '../../../score/presentation/providers/score_providers.dart';
import '../../data/datasources/learn_content_datasource.dart';
import '../../data/datasources/learn_local_datasource.dart';
import '../../data/datasources/learn_remote_datasource.dart';
import '../../data/repositories/learn_repository_impl.dart';
import '../../domain/entities/course_module.dart';
import '../../domain/entities/course_progress.dart';
import '../../domain/entities/quiz_submission.dart';
import '../../domain/repositories/learn_repository.dart';

final learnContentProvider = Provider<List<CourseModule>>((ref) {
  return LearnContentDatasource().modules();
});

final learnDatasourceProvider = Provider<LearnRemoteDatasource>((ref) {
  return LearnRemoteDatasource();
});

final learnRepositoryProvider = Provider<LearnRepository>((ref) {
  return LearnRepositoryImpl(ref.watch(learnDatasourceProvider));
});

final learnLocalDatasourceProvider = Provider<LearnLocalDatasource>((ref) {
  try {
    return LearnLocalDatasource(SharedPreferences.getInstance());
  } catch (_) {
    // Flutter widget tests and restricted environments can lack a preferences
    // plugin; production Android/iOS always use persistent SharedPreferences.
    return LearnLocalDatasource();
  }
});

/// Progres belajar user aktif; guest mendapat progres kosong lokal agar UI
/// tetap render (baca + kuis jalan, sync menunggu login).
final learnProgressProvider = StreamProvider<CourseProgress>((ref) {
  final userId = ref.watch(historyUserIdProvider);
  if (userId == null) {
    final source = ref.read(learnLocalDatasourceProvider);
    return Stream<CourseProgress>.multi((controller) {
      controller.add(source.readCachedProgress());
      unawaited(
        source.readProgress().then((progress) {
          controller
            ..add(progress)
            ..close();
        }),
      );
    });
  }
  return ref
      .watch(learnRepositoryProvider)
      .watchProgress(userId)
      .timeout(
        const Duration(seconds: 10),
        onTimeout: (sink) =>
            sink.addError(TimeoutException('Progres tidak dapat dimuat.')),
      );
});

/// Aksi belajar: selesaikan modul (+20) dan klaim kuis (+5 per benar baru).
/// Poin Score diberikan best-effort setelah write progres sukses; progres
/// tamu persisten lokal, tetapi tidak dipresentasikan sebagai poin cloud.
final learnActionProvider = AsyncNotifierProvider<LearnActionController, void>(
  LearnActionController.new,
);

class LearnActionController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<ModuleCompletion> completeModule(String moduleId) async {
    final userId = ref.read(historyUserIdProvider);
    if (userId == null) {
      final local = ref.read(learnLocalDatasourceProvider);
      try {
        final before = await local.readProgress();
        await local.completeModule(moduleId);
        ref.invalidate(learnProgressProvider);
        return before.isCompleted(moduleId)
            ? ModuleCompletion.alreadyDone
            : ModuleCompletion.firstTime;
      } catch (error, stackTrace) {
        state = AsyncError(error, stackTrace);
        return ModuleCompletion.failed;
      }
    }
    var outcome = ModuleCompletion.firstTime;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final firstClaim = await ref
          .read(learnRepositoryProvider)
          .completeModule(userId, moduleId);
      outcome = firstClaim
          ? ModuleCompletion.firstTime
          : ModuleCompletion.alreadyDone;
      if (firstClaim) {
        unawaited(
          ref.read(awardModuleProvider)(userId, moduleId).catchError((
            Object e,
            StackTrace s,
          ) {
            debugPrint('Gagal award modul: $e');
          }),
        );
      }
    });
    return state.hasError ? ModuleCompletion.failed : outcome;
  }

  /// Menyimpan skor kuis (best-score) dan mengembalikan status eksplisit.
  ///
  /// Dipanggil otomatis begitu kuis selesai, sehingga hasil tidak bergantung
  /// pada satu ketukan tombol klaim. Kegagalan tidak lagi disamarkan sebagai
  /// "tidak ada poin baru".
  Future<QuizSubmission> submitQuiz(String moduleId, int correctCount) async {
    final userId = ref.read(historyUserIdProvider);
    if (userId == null) {
      try {
        final fresh = await ref
            .read(learnLocalDatasourceProvider)
            .submitQuiz(moduleId, correctCount);
        ref.invalidate(learnProgressProvider);
        return fresh > 0
            ? QuizSubmission(status: QuizSaveStatus.saved, points: fresh)
            : const QuizSubmission.unchanged();
      } catch (error, stackTrace) {
        state = AsyncError(error, stackTrace);
        return const QuizSubmission.failed();
      }
    }
    var awarded = 0;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final fresh = await ref
          .read(learnRepositoryProvider)
          .submitQuiz(userId, moduleId, correctCount);
      awarded = fresh;
      for (var i = 0; i < fresh; i++) {
        unawaited(
          ref.read(awardQuizProvider)(userId, correct: true).catchError((
            Object e,
            StackTrace s,
          ) {
            debugPrint('Gagal award kuis: $e');
          }),
        );
      }
    });
    if (state.hasError) return const QuizSubmission.failed();
    return awarded > 0
        ? QuizSubmission(status: QuizSaveStatus.saved, points: awarded)
        : const QuizSubmission.unchanged();
  }
}
