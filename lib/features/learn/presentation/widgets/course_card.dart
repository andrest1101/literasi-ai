import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/course_module.dart';

/// Kartu modul heterogen — 3 varian ritme berbeda, bukan 3 persegi sama.
///
/// Varian dipilih dari `accentSeed`: 0 = hero horizontal gradien penuh,
/// 1 = split dua kolom (teks kiri, medallion kanan), 2 = strip vertikal
/// dengan nomor besar. Badge selesai + menit + jumlah soal konsisten di
/// semua varian agar tetap terbaca sebagai satu keluarga.
class CourseCard extends StatelessWidget {
  const CourseCard({
    super.key,
    required this.module,
    required this.completed,
    required this.bestScore,
    required this.onTap,
  });

  final CourseModule module;
  final bool completed;
  final int bestScore;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return switch (module.accentSeed % 3) {
      0 => _HeroCard(
        module: module,
        completed: completed,
        bestScore: bestScore,
        onTap: onTap,
      ),
      1 => _SplitCard(
        module: module,
        completed: completed,
        bestScore: bestScore,
        onTap: onTap,
      ),
      _ => _NumberedCard(
        module: module,
        completed: completed,
        bestScore: bestScore,
        onTap: onTap,
      ),
    };
  }
}

class _CardShell extends StatelessWidget {
  const _CardShell({required this.child, required this.onTap});

  final Widget child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Buka modul',
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(24), child: child),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({
    required this.module,
    required this.completed,
    required this.bestScore,
    required this.light,
  });

  final CourseModule module;
  final bool completed;
  final int bestScore;
  final bool light;

  @override
  Widget build(BuildContext context) {
    final sub = light ? const Color(0xFFD6E5FE) : AppColors.textSecondary;
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: [
        _Pill(
          icon: Icons.timer_outlined,
          text: '${module.minutes} mnt',
          light: light,
          color: sub,
        ),
        _Pill(
          icon: Icons.quiz_outlined,
          text: '${module.quizCount} soal',
          light: light,
          color: sub,
        ),
        if (bestScore > 0)
          _Pill(
            icon: Icons.star_rounded,
            text: '$bestScore/${module.quizCount}',
            light: light,
            color: light ? Colors.white : AppColors.primary,
          ),
        if (completed)
          const _Pill(
            icon: Icons.check_circle_rounded,
            text: AppStrings.learnModuleDone,
            light: false,
            color: AppColors.success,
            filled: true,
          ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.icon,
    required this.text,
    required this.light,
    required this.color,
    this.filled = false,
  });

  final IconData icon;
  final String text;
  final bool light;
  final Color color;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: filled
            ? AppColors.success.withValues(alpha: 0.12)
            : light
            ? Colors.white.withValues(alpha: 0.16)
            : AppColors.primary.withValues(alpha: 0.07),
        border: Border.all(
          color: filled
              ? AppColors.success.withValues(alpha: 0.4)
              : light
              ? Colors.white.withValues(alpha: 0.3)
              : AppColors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              color: color,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

/// Varian 0 — hero gradien penuh untuk modul pertama.
class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.module,
    required this.completed,
    required this.bestScore,
    required this.onTap,
  });

  final CourseModule module;
  final bool completed;
  final int bestScore;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2F80ED), Color(0xFF124A9B)],
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x331558B0),
              blurRadius: 22,
              offset: Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.white.withValues(alpha: 0.16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Icon(
                    Icons.ads_click_rounded,
                    size: 24,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.arrow_forward_rounded,
                  size: 22,
                  color: Colors.white,
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              module.title,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              module.subtitle,
              style: const TextStyle(
                fontSize: 13,
                height: 1.55,
                color: Color(0xFFD6E5FE),
              ),
            ),
            const SizedBox(height: 12),
            _MetaRow(
              module: module,
              completed: completed,
              bestScore: bestScore,
              light: true,
            ),
          ],
        ),
      ),
    );
  }
}

/// Varian 1 — split dua kolom untuk modul kedua.
class _SplitCard extends StatelessWidget {
  const _SplitCard({
    required this.module,
    required this.completed,
    required this.bestScore,
    required this.onTap,
  });

  final CourseModule module;
  final bool completed;
  final int bestScore;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: AppColors.surface,
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.22),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D101A33),
              blurRadius: 16,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    module.title,
                    style: const TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    module.subtitle,
                    style: const TextStyle(
                      fontSize: 12.5,
                      height: 1.55,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _MetaRow(
                    module: module,
                    completed: completed,
                    bestScore: bestScore,
                    light: false,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Container(
              width: 72,
              height: 88,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(19),
                color: AppColors.warning.withValues(alpha: 0.14),
                border: Border.all(
                  color: AppColors.warning.withValues(alpha: 0.35),
                ),
              ),
              child: const Icon(
                Icons.image_search_rounded,
                size: 34,
                color: Color(0xFF8A5A00),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Varian 2 — strip nomor besar untuk modul ketiga.
class _NumberedCard extends StatelessWidget {
  const _NumberedCard({
    required this.module,
    required this.completed,
    required this.bestScore,
    required this.onTap,
  });

  final CourseModule module;
  final bool completed;
  final int bestScore;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: const Color(0xFF0F2B1D),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A0F2B1D),
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '03',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1,
                    color: Color(0xFF7BE0A8),
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
                const Spacer(),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.25),
                    ),
                  ),
                  child: const Icon(
                    Icons.travel_explore_outlined,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              module.title,
              style: const TextStyle(
                fontSize: 16.5,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.2,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              module.subtitle,
              style: const TextStyle(
                fontSize: 12.5,
                height: 1.55,
                color: Color(0xFFBFE6CF),
              ),
            ),
            const SizedBox(height: 10),
            _MetaRow(
              module: module,
              completed: completed,
              bestScore: bestScore,
              light: true,
            ),
          ],
        ),
      ),
    );
  }
}
