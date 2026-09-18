/// Satu soal kuis — murni Dart, tanpa dependensi Flutter.
///
/// [explanation] adalah nilai edukasi utama: ditampilkan setelah user
/// menjawab agar salah pun tetap belajar, bukan sekadar skor.
class QuizQuestion {
  const QuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });

  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  bool isCorrect(int selected) => selected == correctIndex;
}
