import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/history_filter.dart';

/// Bar filter riwayat: pill animasi beridentitas verdict.
///
/// Bukan [ChoiceChip] default Material: seleksi bertransisi 200ms via
/// [AnimatedContainer], tiap filter punya aksen warnanya sendiri (Semua
/// biru, Hoaks merah, Valid hijau, Perlu dicek amber), dan suffix angka
/// [counts] memberi tahu isi tiap filter tanpa harus mengetuknya dulu.
/// Label dan angka dirender sebagai [Text] terpisah agar test pencari
/// label tetap valid.
class HistoryFilterBar extends StatelessWidget {
  const HistoryFilterBar({
    super.key,
    required this.selected,
    required this.onSelected,
    this.counts = const {},
  });

  final HistoryFilter selected;
  final ValueChanged<HistoryFilter> onSelected;
  final Map<HistoryFilter, int> counts;

  static const _labels = {
    HistoryFilter.all: AppStrings.historyFilterAll,
    HistoryFilter.hoaks: AppStrings.historyFilterHoaks,
    HistoryFilter.valid: AppStrings.historyFilterValid,
    HistoryFilter.perluDicek: AppStrings.historyFilterNeedCheck,
  };

  static const _accents = {
    HistoryFilter.all: AppColors.primary,
    HistoryFilter.hoaks: AppColors.danger,
    HistoryFilter.valid: AppColors.success,
    HistoryFilter.perluDicek: AppColors.verdictAmber,
  };

  static const _activeInks = {
    HistoryFilter.all: AppColors.primaryDark,
    HistoryFilter.hoaks: AppColors.dangerDark,
    HistoryFilter.valid: AppColors.successDark,
    HistoryFilter.perluDicek: AppColors.warningDark,
  };

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final filter in HistoryFilter.values) ...[
            _FilterPill(
              label: _labels[filter]!,
              count: counts[filter] ?? 0,
              active: selected == filter,
              accent: _accents[filter]!,
              activeInk: _activeInks[filter]!,
              onTap: () => onSelected(filter),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.count,
    required this.active,
    required this.accent,
    required this.activeInk,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool active;
  final Color accent;
  final Color activeInk;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: active,
      label: count > 0 ? '$label, $count' : label,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: active
                ? accent.withValues(alpha: 0.12)
                : AppColors.surface,
            border: Border.all(
              color: active
                  ? accent.withValues(alpha: 0.45)
                  : AppColors.neutral.withValues(alpha: 0.25),
            ),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.18),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: active ? accent : accent.withValues(alpha: 0.55),
                ),
              ),
              const SizedBox(width: 7),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: active ? activeInk : AppColors.textSecondary,
                ),
              ),
              if (count > 0) ...[
                const SizedBox(width: 6),
                Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: active ? activeInk : AppColors.textSecondary,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
