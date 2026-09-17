import '../../../quick_check/domain/entities/verification_result.dart';

/// Filter utama riwayat sesuai ruang lingkup PRD.
enum HistoryFilter {
  all,
  hoaks,
  valid,
  perluDicek;

  bool matches(Verdict verdict) => switch (this) {
    HistoryFilter.all => true,
    HistoryFilter.hoaks => verdict == Verdict.hoaks,
    HistoryFilter.valid => verdict == Verdict.valid,
    HistoryFilter.perluDicek => verdict == Verdict.perluDicek,
  };
}
