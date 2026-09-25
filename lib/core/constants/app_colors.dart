import 'package:flutter/material.dart';

/// Color system sesuai PRD §7.2: trustworthy & clean.
///
/// Warna inti tidak diubah (kontrak visual + test). Tambahan di bawah adalah
/// turunan sistematis: varian gelap untuk teks di atas tint, permukaan
/// lembut untuk hero gradien, dan warna garis/bayangan terpusat agar
/// tidak ada hex tersebar di widget.
abstract final class AppColors {
  static const Color primary = Color(0xFF1A73E8);
  static const Color success = Color(0xFF34A853);
  static const Color warning = Color(0xFFFBBC04);
  static const Color danger = Color(0xFFEA4335);
  static const Color neutral = Color(0xFF9AA0A6);
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF202124);
  static const Color textSecondary = Color(0xFF5F6368);

  // Varian gelap: untuk teks kecil di atas tint terang (kontras aman).
  static const Color primaryDark = Color(0xFF124A9B);
  static const Color primaryDeep = Color(0xFF0B2F66);
  static const Color successDark = Color(0xFF1E7E34);
  static const Color warningDark = Color(0xFF8A5A00);
  static const Color dangerDark = Color(0xFFB3261E);
  static const Color verdictAmber = Color(0xFFB7791F);

  // Permukaan hero: gradien biru khas LiterasiAI, terpusat di sini.
  static const Color heroBegin = Color(0xFF2F80ED);
  static const Color heroEnd = Color(0xFF124A9B);
  static const Color heroInkSoft = Color(0xFFD6E5FE);

  // Garis & bayangan terpusat.
  static const Color hairline = Color(0xFFE3E8F0);
  static const Color disabledSurface = Color(0xFFE8EDF5);
  static const Color disabledInk = Color(0xFF5B6B80);
  static const Color disabledBorder = Color(0xFFD5DDE9);
  static const Color shadowInk = Color(0xFF101A33);
}
