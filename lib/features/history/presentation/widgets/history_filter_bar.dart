import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/history_filter.dart';

class HistoryFilterBar extends StatelessWidget {
  const HistoryFilterBar({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final HistoryFilter selected;
  final ValueChanged<HistoryFilter> onSelected;

  static const _labels = {
    HistoryFilter.all: AppStrings.historyFilterAll,
    HistoryFilter.hoaks: AppStrings.historyFilterHoaks,
    HistoryFilter.valid: AppStrings.historyFilterValid,
    HistoryFilter.perluDicek: AppStrings.historyFilterNeedCheck,
  };

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final filter in HistoryFilter.values) ...[
            ChoiceChip(
              label: Text(_labels[filter]!),
              selected: selected == filter,
              onSelected: (_) => onSelected(filter),
              selectedColor: AppColors.primary.withValues(alpha: 0.14),
              side: BorderSide(
                color: selected == filter
                    ? AppColors.primary.withValues(alpha: 0.45)
                    : AppColors.neutral.withValues(alpha: 0.25),
              ),
              labelStyle: TextStyle(
                fontWeight: FontWeight.w700,
                color: selected == filter
                    ? AppColors.primary
                    : AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}
