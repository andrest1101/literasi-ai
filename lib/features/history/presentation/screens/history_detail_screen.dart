import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../quick_check/presentation/widgets/quick_check_result_section.dart';
import '../../../quick_check/presentation/widgets/session_back_button.dart';
import '../../domain/entities/history_entry.dart';
import '../widgets/history_card.dart';

class HistoryDetailScreen extends StatelessWidget {
  const HistoryDetailScreen({super.key, required this.entry});

  final HistoryEntry entry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 64,
        leadingWidth: 56,
        leading: SessionBackButton(onPressed: () => Navigator.of(context).maybePop()),
        title: const Text(AppStrings.historyDetailTitle),
        titleTextStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.neutral.withValues(alpha: 0.2)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: QuickCheckResultSection(
              result: entry.result,
              loading: false,
              onNewCheck: () => Navigator.of(context).maybePop(),
              heroTag: HistoryCard.heroTagFor(entry.id),
            ),
          ),
        ),
      ),
    );
  }
}
