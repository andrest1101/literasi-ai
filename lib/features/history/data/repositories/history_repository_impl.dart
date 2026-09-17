import '../../domain/entities/history_entry.dart';
import '../../domain/repositories/history_repository.dart';
import '../../../quick_check/domain/entities/verification_result.dart';
import '../datasources/history_remote_datasource.dart';
import '../models/history_doc_model.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  HistoryRepositoryImpl(this._datasource);

  final HistoryRemoteDatasource _datasource;

  @override
  Stream<List<HistoryEntry>> watch(String userId) =>
      _datasource.watch(userId).map(
        (documents) => documents.map(HistoryDocModel.fromDocument).toList(),
      );

  @override
  Future<void> save({required String userId, required VerificationResult result}) =>
      _datasource.save(userId: userId, result: result);

  @override
  Future<void> delete({required String userId, required String entryId}) =>
      _datasource.delete(userId: userId, entryId: entryId);
}
