import '../../../quick_check/domain/entities/verification_result.dart';
import '../entities/history_entry.dart';

/// Kontrak penyimpanan riwayat verifikasi per pengguna.
abstract class HistoryRepository {
  Stream<List<HistoryEntry>> watch(String userId);

  Future<void> save({
    required String userId,
    required VerificationResult result,
  });

  Future<void> delete({required String userId, required String entryId});
}
