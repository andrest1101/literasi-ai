import '../entities/literacy_score.dart';

/// Kontrak skor — stream untuk UI, award untuk tiap sumber poin.
///
/// `awardModule` idempoten per `moduleId`: modul yang sama diklaim dua kali
/// hanya dihitung sekali.
abstract class ScoreRepository {
  Stream<LiteracyScore> watch(String userId);

  Future<void> awardVerification(String userId);

  Future<void> awardModule(String userId, String moduleId);

  Future<void> awardQuiz(String userId, {required bool correct});
}
