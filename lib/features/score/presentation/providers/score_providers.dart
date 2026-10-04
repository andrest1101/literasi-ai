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
/// agar UI Profil tetap render tanpa error Firebase.
///
/// Ketahanan Alt+Tab/jaringan goyah: tiap langganan baru mencoba ulang
/// hingga 2x dengan backoff (1s, 2s) sebelum menyerah ke error final.
/// Selama retry, data terakhir dipertahankan (tidak langsung merah).
/// Timeout 10 detik per percobaan agar stream yang macet (offline/rules)
/// tampil sebagai error card, bukan skeleton selamanya.
final scoreProvider = StreamProvider<LiteracyScore>((ref) {
  final userId = ref.watch(historyUserIdProvider);
  if (userId == null) return Stream.value(const LiteracyScore());
  final repository = ref.watch(scoreRepositoryProvider);
  return _watchWithRetry(repository, userId).timeout(
    const Duration(seconds: 10),
    onTimeout: (sink) =>
        sink.addError(TimeoutException('Skor tidak dapat dimuat. Coba lagi.')),
  );
});

/// Langganan skor dengan retry: percobaan pertama + hingga 2 ulangan.
///
/// Backoff 1s lalu 2s memberi jeda reconnect Firestore saat window
/// aktif kembali (kasus Alt+Tab di desktop: stream putus sesaat).
/// Error generator stream dalam (`async*`) tidak bisa ditangkap pemanggil
/// lewat try/catch biasa, sehingga retry dipasang pada listener manual:
/// tiap percobaan di-listen ulang dari awal bila error sebelum data valid
/// tiba. Setelah 2 ulangan masih gagal, error diteruskan ke UI.
Stream<LiteracyScore> _watchWithRetry(
  ScoreRepository repository,
  String userId,
) {
  late final StreamController<LiteracyScore> controller;
  StreamSubscription<LiteracyScore>? sub;
  var attempt = 0;
  var closed = false;

  void listen() {
    sub = repository
        .watch(userId)
        .listen(
          controller.add,
          onError: (Object e) async {
            await sub?.cancel();
            if (closed) return;
            if (attempt >= 2) {
              controller.addError(e);
              return;
            }
            await Future.delayed(Duration(seconds: attempt + 1));
            if (closed) return;
            attempt++;
            listen();
          },
          onDone: controller.close,
        );
  }

  controller = StreamController<LiteracyScore>(
    onListen: listen,
    onCancel: () {
      closed = true;
      return sub?.cancel();
    },
  );
  return controller.stream;
}

/// Aksi award terpantau UI: error Firestore tidak merusak state skor.
final scoreActionProvider = AsyncNotifierProvider<ScoreActionController, void>(
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
