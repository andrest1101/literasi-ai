/// Hasil satu percobaan menyimpan skor kuis.
///
/// Tiga status ini sengaja dibedakan agar UI tidak pernah melaporkan
/// "tidak ada poin baru" ketika penyimpanan sebenarnya gagal — sumber
/// kebingungan "skor sudah tersimpan padahal kartu masih 0/4".
enum QuizSaveStatus {
  /// Skor baru (lebih tinggi dari best sebelumnya) tersimpan.
  saved,

  /// Skor tersimpan, tetapi best sebelumnya sudah setara/lebih tinggi
  /// sehingga tidak ada poin baru. Bukan kegagalan.
  unchanged,

  /// Penyimpanan gagal (jaringan, izin, penyimpanan perangkat). UI wajib
  /// menawarkan kesempatan mencoba lagi.
  failed,
}

/// Ringkasan hasil penyimpanan kuis.
class QuizSubmission {
  const QuizSubmission({required this.status, this.points = 0});

  const QuizSubmission.failed() : status = QuizSaveStatus.failed, points = 0;

  const QuizSubmission.unchanged()
    : status = QuizSaveStatus.unchanged,
      points = 0;

  final QuizSaveStatus status;

  /// Poin kuis baru yang diklaim (0 untuk [QuizSaveStatus.unchanged] dan
  /// [QuizSaveStatus.failed]).
  final int points;

  bool get isSaved => status == QuizSaveStatus.saved;

  bool get isFailed => status == QuizSaveStatus.failed;
}

/// Hasil klaim penyelesaian modul.
///
/// Membedakan "sudah selesai" dari "gagal menyimpan" agar snackbar tidak
/// menyesatkan saat penyimpanan bermasalah.
enum ModuleCompletion { firstTime, alreadyDone, failed }
