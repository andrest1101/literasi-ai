import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

/// Banner status layar kunci: satu-satunya area besar yang ekspresif.
///
/// Live → gradien brand dengan teks putih (menyatakan AI aktif).
/// Demo → tint amber lembut dengan teks gelap (menyatakan belum live).
/// Warna status tidak dipakai di tempat lain agar hirarki tetap jelas.
class ApiKeyStatusHero extends StatelessWidget {
  const ApiKeyStatusHero({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Color accent;

  bool get _live => accent == AppColors.success;

  bool get _neutral => accent == AppColors.textSecondary;

  @override
  Widget build(BuildContext context) {
    final live = _live;
    final neutral = _neutral;
    final decoration = BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      gradient: live
          ? const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.heroBegin, AppColors.heroEnd],
            )
          : null,
      color: live ? null : (neutral ? AppColors.surface : null),
      border: live
          ? null
          : Border.all(
              color: neutral
                  ? AppColors.hairline
                  : AppColors.warning.withValues(alpha: 0.4),
            ),
    );
    final titleColor = live ? Colors.white : AppColors.textPrimary;
    final subtitleColor = live ? AppColors.heroInkSoft : AppColors.textSecondary;
    final badgeColor = live
        ? Colors.white.withValues(alpha: 0.16)
        : neutral
            ? AppColors.background
            : AppColors.warning.withValues(alpha: 0.18);
    final badgeIconColor = live ? Colors.white : accent;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: decoration,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: badgeColor,
            ),
            child: Icon(icon, size: 30, color: badgeIconColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (subtitle != null) ...[
                  // Label kecil di atas judul agar bentuk banner terasa seperti
                  // "kartu status", bukan kotak polos.
                  Text(
                    live ? 'STATUS AI' : 'STATUS',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.4,
                      color: live
                          ? AppColors.heroInkSoft
                          : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                ],
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                    height: 1.15,
                    color: titleColor,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.55,
                      color: subtitleColor,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
