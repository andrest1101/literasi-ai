import 'literacy_level.dart';

/// Snapshot skor literasi: entity murni Dart.
///
/// `modulePoints/quizPoints` bernilai 0 sampai Phase 3b Learn dibangun.
/// Slot award modul/kuis sudah disiapkan agar 3b tinggal memanggil kontrak
/// yang sama tanpa mengubah entity ini.
class LiteracyScore {
  const LiteracyScore({
    this.verifications = 0,
    this.modulesDone = const [],
    this.quizCorrect = 0,
  });

  static const int verificationPoints = 10;
  static const int modulePoints = 20;
  static const int quizPoints = 5;

  final int verifications;
  final List<String> modulesDone;
  final int quizCorrect;

  int get verificationTotal => verifications * verificationPoints;
  int get moduleTotal => modulesDone.length * modulePoints;
  int get quizTotal => quizCorrect * quizPoints;
  int get total => verificationTotal + moduleTotal + quizTotal;

  LiteracyLevel get level => LiteracyLevel.of(total);

  /// Sisa poin ke level berikut; 0 bila sudah Ahli.
  int get pointsToNext {
    final next = level.next;
    if (next == null) return 0;
    return (next.floor - total).clamp(0, next.floor);
  }

  /// Progres 0.0-1.0 dalam level saat ini; Ahli selalu penuh.
  double get progressInLevel {
    final ceiling = level.ceiling;
    if (ceiling == null) return 1.0;
    final span = ceiling - level.floor + 1;
    return ((total - level.floor + 1) / span).clamp(0.0, 1.0);
  }

  LiteracyScore copyWith({
    int? verifications,
    List<String>? modulesDone,
    int? quizCorrect,
  }) {
    return LiteracyScore(
      verifications: verifications ?? this.verifications,
      modulesDone: modulesDone ?? this.modulesDone,
      quizCorrect: quizCorrect ?? this.quizCorrect,
    );
  }
}
