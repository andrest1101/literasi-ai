import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/history_remote_datasource.dart';
import '../../data/repositories/history_repository_impl.dart';
import '../../domain/entities/history_entry.dart';
import '../../domain/entities/history_filter.dart';
import '../../domain/repositories/history_repository.dart';
import '../../domain/usecases/delete_history.dart';
import '../../domain/usecases/save_history.dart';

final historyDatasourceProvider = Provider<HistoryRemoteDatasource>((ref) {
  return HistoryRemoteDatasource();
});

final historyRepositoryProvider = Provider<HistoryRepository>((ref) {
  return HistoryRepositoryImpl(ref.watch(historyDatasourceProvider));
});

final historyFilterProvider = StateProvider<HistoryFilter>((ref) {
  return HistoryFilter.all;
});

/// Kata kunci pencarian riwayat: murni state presentasi.
///
/// Pencarian jalan lokal di atas stream Firestore (tanpa query baru),
/// sehingga guest/offline dan filter verdict tetap konsisten.
final historySearchProvider = StateProvider<String>((ref) => '');

final authStateProvider = StreamProvider<User?>((ref) {
  try {
    return FirebaseAuth.instance.authStateChanges();
  } catch (_) {
    return Stream<User?>.value(null);
  }
});

/// UID aman-test: authStateChanges membuat login/logout langsung menyegarkan
/// history/score/learn, sementara widget test tetap bisa override provider ini.
final historyUserIdProvider = Provider<String?>((ref) {
  return ref.watch(authStateProvider).valueOrNull?.uid;
});

final historyEntriesProvider = StreamProvider<List<HistoryEntry>>((ref) {
  final userId = ref.watch(historyUserIdProvider);
  if (userId == null) return Stream.value(const []);
  return ref.watch(historyRepositoryProvider).watch(userId);
});

final saveHistoryProvider = Provider<SaveHistory>((ref) {
  return SaveHistory(ref.watch(historyRepositoryProvider));
});

final deleteHistoryProvider = Provider<DeleteHistory>((ref) {
  return DeleteHistory(ref.watch(historyRepositoryProvider));
});

/// Aksi hapus dipisah dari widget agar error Firestore dapat dipantau UI.
final historyActionProvider =
    AsyncNotifierProvider<HistoryActionController, void>(
      HistoryActionController.new,
    );

class HistoryActionController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> delete(String entryId) async {
    final userId = ref.read(historyUserIdProvider);
    if (userId == null) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(deleteHistoryProvider)(userId: userId, entryId: entryId),
    );
  }
}
