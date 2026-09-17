import '../repositories/score_repository.dart';

/// Use case tipis per sumber poin — validasi userId lalu teruskan ke repo.
class AwardVerification {
  AwardVerification(this._repository);

  final ScoreRepository _repository;

  Future<void> call(String userId) {
    if (userId.isEmpty) return Future.value();
    return _repository.awardVerification(userId);
  }
}

class AwardModule {
  AwardModule(this._repository);

  final ScoreRepository _repository;

  Future<void> call(String userId, String moduleId) {
    if (userId.isEmpty || moduleId.isEmpty) return Future.value();
    return _repository.awardModule(userId, moduleId);
  }
}

class AwardQuiz {
  AwardQuiz(this._repository);

  final ScoreRepository _repository;

  Future<void> call(String userId, {required bool correct}) {
    if (userId.isEmpty) return Future.value();
    return _repository.awardQuiz(userId, correct: correct);
  }
}
