/// Label waktu relatif bersama untuk fitur Riwayat ("2 jam").
///
/// Dipakai [HistoryCard] (footer tanggal) dan sub-konteks toolbar agar
/// formatnya tidak pernah drift. Bentuk dasar TANPA kata "lalu":
/// callsite yang butuh ("terakhir 2 jam lalu") menambahkannya sendiri,
/// dengan pengecualian "Baru saja". Fungsi murni Dart: parameter
/// [clockNow] hanya untuk test deterministik.
String historyTimeAgo(DateTime date, {DateTime? clockNow}) {
  final now = clockNow ?? DateTime.now();
  final difference = now.difference(date.toLocal());
  if (difference.inMinutes < 1) return 'Baru saja';
  if (difference.inHours < 1) return '${difference.inMinutes} mnt';
  if (difference.inDays < 1) return '${difference.inHours} jam';
  if (difference.inDays < 7) return '${difference.inDays} hari';
  final local = date.toLocal();
  return '${local.day.toString().padLeft(2, '0')}/'
      '${local.month.toString().padLeft(2, '0')}/${local.year}';
}
