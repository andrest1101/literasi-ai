/// Level literasi: ambang Standar sesuai keputusan Phase 3a.
///
/// Entity murni Dart: tanpa import Flutter agar domain tetap testable dan
/// patuh Clean Architecture. Warna/ikon tiap level disediakan extension di
/// presentation layer (`literacy_level_ui.dart`).
///
/// Naik level butuh konsistensi jangka panjang (Ahli = 300+ poin), bukan
/// hasil 2-3 verifikasi. Pilihan ini menjaga kredibilitas level di mata
/// reviewer portfolio.
enum LiteracyLevel {
  pemula,
  waspada,
  kritis,
  ahli;

  static LiteracyLevel of(int total) {
    if (total >= 300) return LiteracyLevel.ahli;
    if (total >= 150) return LiteracyLevel.kritis;
    if (total >= 50) return LiteracyLevel.waspada;
    return LiteracyLevel.pemula;
  }

  String get label => switch (this) {
    LiteracyLevel.pemula => 'Pemula',
    LiteracyLevel.waspada => 'Waspada',
    LiteracyLevel.kritis => 'Kritis',
    LiteracyLevel.ahli => 'Ahli',
  };

  /// Poin awal level ini: dipakai menghitung sisa ke level berikut.
  int get floor => switch (this) {
    LiteracyLevel.pemula => 0,
    LiteracyLevel.waspada => 50,
    LiteracyLevel.kritis => 150,
    LiteracyLevel.ahli => 300,
  };

  /// Batas atas level ini; null berarti level tertinggi tanpa atap.
  int? get ceiling => switch (this) {
    LiteracyLevel.pemula => 49,
    LiteracyLevel.waspada => 149,
    LiteracyLevel.kritis => 299,
    LiteracyLevel.ahli => null,
  };

  LiteracyLevel? get next => switch (this) {
    LiteracyLevel.pemula => LiteracyLevel.waspada,
    LiteracyLevel.waspada => LiteracyLevel.kritis,
    LiteracyLevel.kritis => LiteracyLevel.ahli,
    LiteracyLevel.ahli => null,
  };
}
