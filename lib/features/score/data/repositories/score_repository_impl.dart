import '../../domain/entities/literacy_score.dart';
import '../../domain/repositories/score_repository.dart';
import '../datasources/score_remote_datasource.dart';
import '../models/score_doc_model.dart';

class ScoreRepositoryImpl implements ScoreRepository {
  ScoreRepositoryImpl(this._datasource);

  final ScoreRemoteDatasource _datasource;

  @override
  Stream<LiteracyScore> watch(String userId) =>
      _datasource.watch(userId).map(ScoreDocModel.fromDocument);

  @override
  Future<void> awardVerification(String userId) =>
      _datasource.awardVerification(userId);

  @override
  Future<void> awardModule(String userId, String moduleId) =>
      _datasource.awardModule(userId, moduleId);

  @override
  Future<void> awardQuiz(String userId, {required bool correct}) =>
      _datasource.awardQuiz(userId, correct: correct);
}
