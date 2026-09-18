import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../history/presentation/providers/history_providers.dart';
import '../../../score/presentation/providers/score_providers.dart';
import '../../data/datasources/learn_content_datasource.dart';
import '../../data/datasources/learn_remote_datasource.dart';
import '../../data/repositories/learn_repository_impl.dart';
import '../../domain/entities/course_module.dart';
import '../../domain/entities/course_progress.dart';
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

/// Progres belajar user aktif; guest mendapat progres kosong lokal agar UI
/// tetap render (baca + kuis jalan, sync menunggu login).
final learnProgressProvider = StreamProvider<CourseProgress>((ref) {
  final userId = ref.watch(historyUserIdProvider);
  if (userId == null) return Stream.value(const CourseProgress());
  return ref.watch(learnRepositoryProvider).watchProgress(userId).timeout(
    const Duration(seconds: 10),
    onTimeout: (sink) =>
        sink.addError(TimeoutException('Progres tidak dapat dimuat.')),
  );
});

/// Aksi belajar: selesaikan modul (+20) dan klaim kuis (+5 per benar baru).
/// Poin Score diberikan best-effort setelah write progres sukses; guest
/// tanpa UID hanya mendapat status lokal tanpa write.
final learnActionProvider =
    AsyncNotifierProvider<LearnActionController, void>(
      LearnActionController.new,
    );

class LearnActionController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<bool> completeModule(String moduleId) async {
    final userId = ref.read(historyUserIdProvider);
    if (userId == null) return true;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final firstClaim = await ref
          .read(learnRepositoryProvider)
          .completeModule(userId, moduleId);
      if (firstClaim) {
        unawaited(
          ref
              .read(awardModuleProvider)(userId, moduleId)
              .catchError((Object e, StackTrace s) {
                debugPrint('Gagal award modul: $e');
              }),
        );
      }
    });
    return !state.hasError;
  }

  /// Mengembalikan poin kuis baru yang diklaim (0 bila tidak ada yang baru).
  Future<int> submitQuiz(String moduleId, int correctCount) async {
    final userId = ref.read(historyUserIdProvider);
    if (userId == null) return correctCount;
    var awarded = 0;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final fresh = await ref
          .read(learnRepositoryProvider)
          .submitQuiz(userId, moduleId, correctCount);
      awarded = fresh;
      for (var i = 0; i < fresh; i++) {
        unawaited(
          ref
              .read(awardQuizProvider)(userId, correct: true)
              .catchError((Object e, StackTrace s) {
                debugPrint('Gagal award kuis: $e');
              }),
        );
      }
    });
    return state.hasError ? 0 : awarded;
  }
}
