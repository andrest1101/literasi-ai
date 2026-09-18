import 'quiz_question.dart';

/// Satu seksi artikel dalam modul — heading + 2-3 paragraf ringkas.
class CourseSection {
  const CourseSection({required this.heading, required this.body});

  final String heading;
  final String body;
}

/// Modul edukasi — konten statis lokal, tanpa network/AI.
///
/// [accentSeed] membedakan identitas visual tiap kartu modul agar tidak
/// monoton: dipakai UI untuk memilih varian gradien/ikon, bukan warna acak.
class CourseModule {
  const CourseModule({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.minutes,
    required this.accentSeed,
    required this.sections,
    required this.quiz,
  });

  final String id;
  final String title;
  final String subtitle;
  final int minutes;
  final int accentSeed;
  final List<CourseSection> sections;
  final List<QuizQuestion> quiz;

  int get quizCount => quiz.length;
}
