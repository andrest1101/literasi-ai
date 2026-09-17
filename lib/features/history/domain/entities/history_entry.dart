import '../../../quick_check/domain/entities/verification_result.dart';

/// Satu hasil verifikasi yang tersimpan pada riwayat pengguna.
class HistoryEntry {
  const HistoryEntry({required this.id, required this.result});

  final String id;
  final VerificationResult result;
}
