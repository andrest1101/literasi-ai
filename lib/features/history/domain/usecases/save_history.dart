import '../../../quick_check/domain/entities/verification_result.dart';
import '../repositories/history_repository.dart';

class SaveHistory {
  SaveHistory(this._repository);

  final HistoryRepository _repository;

  Future<void> call({
    required String userId,
    required VerificationResult result,
  }) => _repository.save(userId: userId, result: result);
}
