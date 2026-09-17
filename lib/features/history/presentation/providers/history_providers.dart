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

/// UID aman-test: bungkus FirebaseAuth agar widget test tanpa Firebase
/// init tetap jalan (kembali null), dan test bisa override via provider.
final historyUserIdProvider = Provider<String?>((ref) {
  try {
    return FirebaseAuth.instance.currentUser?.uid;
  } catch (_) {
    return null;
  }
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
