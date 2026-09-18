/// Progres belajar per pengguna — murni Dart.
///
/// `quizBest` menyimpan skor TERBAIK per modul (bukan tiap attempt) agar
/// poin Score (+5 per benar) tidak bisa di-farming dengan mengulang kuis.
/// Klaim modul idempoten: modul yang sama dihitung sekali.
class CourseProgress {
  const CourseProgress({
    this.completedModuleIds = const [],
    this.quizBest = const {},
  });

  final List<String> completedModuleIds;
  final Map<String, int> quizBest;

  bool isCompleted(String moduleId) => completedModuleIds.contains(moduleId);

  int bestFor(String moduleId) => quizBest[moduleId] ?? 0;

  int get completedCount => completedModuleIds.length;

  CourseProgress copyWith({
    List<String>? completedModuleIds,
    Map<String, int>? quizBest,
  }) {
    return CourseProgress(
      completedModuleIds: completedModuleIds ?? this.completedModuleIds,
      quizBest: quizBest ?? this.quizBest,
    );
  }
}
