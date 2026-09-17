import '../repositories/history_repository.dart';

class DeleteHistory {
  DeleteHistory(this._repository);

  final HistoryRepository _repository;

  Future<void> call({required String userId, required String entryId}) =>
      _repository.delete(userId: userId, entryId: entryId);
}
