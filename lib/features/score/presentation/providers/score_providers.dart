import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../history/presentation/providers/history_providers.dart';
import '../../data/datasources/score_remote_datasource.dart';
import '../../data/repositories/score_repository_impl.dart';
import '../../domain/entities/literacy_score.dart';
import '../../domain/repositories/score_repository.dart';
import '../../domain/usecases/award_score.dart';

final scoreDatasourceProvider = Provider<ScoreRemoteDatasource>((ref) {
  return ScoreRemoteDatasource();
});

final scoreRepositoryProvider = Provider<ScoreRepository>((ref) {
  return ScoreRepositoryImpl(ref.watch(scoreDatasourceProvider));
});

final awardVerificationProvider = Provider<AwardVerification>((ref) {
  return AwardVerification(ref.watch(scoreRepositoryProvider));
});

final awardModuleProvider = Provider<AwardModule>((ref) {
  return AwardModule(ref.watch(scoreRepositoryProvider));
});

final awardQuizProvider = Provider<AwardQuiz>((ref) {
  return AwardQuiz(ref.watch(scoreRepositoryProvider));
});

/// Stream skor pengguna aktif; tanpa login mengembalikan skor nol lokal
/// agar UI Profil tetap render tanpa error Firebase. Timeout 10 detik agar
/// stream yang macet (offline/rules) tampil sebagai error card, bukan
/// skeleton selamanya.
final scoreProvider = StreamProvider<LiteracyScore>((ref) {
  final userId = ref.watch(historyUserIdProvider);
  if (userId == null) return Stream.value(const LiteracyScore());
  return ref
      .watch(scoreRepositoryProvider)
      .watch(userId)
      .timeout(
        const Duration(seconds: 10),
        onTimeout: (sink) => sink.addError(
          TimeoutException('Skor tidak dapat dimuat. Coba lagi.'),
        ),
      );
});

/// Aksi award terpantau UI: error Firestore tidak merusak state skor.
final scoreActionProvider =
    AsyncNotifierProvider<ScoreActionController, void>(
      ScoreActionController.new,
    );

class ScoreActionController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> awardVerification() async {
    final userId = ref.read(historyUserIdProvider);
    if (userId == null) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(awardVerificationProvider)(userId),
    );
  }
}
