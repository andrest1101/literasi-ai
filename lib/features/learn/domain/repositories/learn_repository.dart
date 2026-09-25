import '../entities/course_module.dart';
import '../entities/course_progress.dart';

/// Kontrak Learn: konten statis lokal, progres per user di Firestore.
abstract class LearnRepository {
  /// Tiga modul PRD: selalu tersedia offline, tanpa login.
  List<CourseModule> modules();

  CourseModule? moduleById(String id);

  Stream<CourseProgress> watchProgress(String userId);

  /// Idempoten: modul yang sama diklaim berkali-kali tetap sekali.
  /// Mengembalikan true bila klaim ini pertama kali (berhak +20 poin).
  Future<bool> completeModule(String userId, String moduleId);

  /// Menyimpan skor terbaik; mengembalikan jumlah jawaban benar BARU yang
  /// berhak poin (0 bila tidak melampaui best). Mencegah farming poin.
  Future<int> submitQuiz(String userId, String moduleId, int correctCount);
}
