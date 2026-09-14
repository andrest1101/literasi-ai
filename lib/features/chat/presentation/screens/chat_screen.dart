import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../shared/widgets/app_section_header.dart';
import '../../../quick_check/presentation/widgets/session_back_button.dart';

/// Placeholder Chat AI (Phase 3).
///
/// Route mandiri yang dibuka dari FAB mengambang di Home, bukan tab nav.
/// AppBar hanya tombol kembali; judul tunggal dipegang header body agar
/// tidak ada judul ganda.
class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  static const route = '/chat';

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
        leading: SessionBackButton(
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(AppStrings.quickCheckBackLabel),
        centerTitle: false,
        titleTextStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: AppColors.neutral.withValues(alpha: 0.2),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppSectionHeader(
                  eyebrow: AppStrings.chatEyebrow,
                  titleLine1: AppStrings.chatTitle1,
                  titleLine2: AppStrings.chatTitle2,
                  subtitle: AppStrings.chatHeaderSubtitle,
                ),
                SizedBox(height: 18),
                _ChatStatusCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChatStatusCard extends StatelessWidget {
  const _ChatStatusCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: AppColors.surface,
        border: Border.all(
          color: AppColors.neutral.withValues(alpha: 0.2),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D101A33),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StatusIcon(),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.chatPlaceholderTitle,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  AppStrings.chatPlaceholderSubtitle,
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.6,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusIcon extends StatelessWidget {
  const _StatusIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: AppColors.primary.withValues(alpha: 0.1),
      ),
      child: const Icon(
        Icons.auto_awesome_rounded,
        size: 23,
        color: AppColors.primary,
      ),
    );
  }
}
