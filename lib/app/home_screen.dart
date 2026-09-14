import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';
import '../features/chat/presentation/screens/chat_screen.dart';
import '../features/chat/presentation/widgets/chat_fab.dart';
import '../features/quick_check/presentation/screens/quick_check_home_tab.dart';
import '../shared/widgets/app_section_header.dart';
import '../shared/widgets/bottom_nav_bar.dart';

/// Home shell — 4 tab tanpa AppBar + FAB Chat AI melayang di atas konten.
///
/// Tiap tab memegang judulnya sendiri di body (kontekstual: Cek, Riwayat,
/// Belajar, Profil) sehingga tidak ada brand ganda di semua halaman.
/// Wordmark kecil hanya ada di tab Cek.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  static const route = '/home';

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _index = 0;

  void _openChat() {
    Navigator.of(context).pushNamed(ChatScreen.route);
  }

  @override
  Widget build(BuildContext context) {
    final isQuickCheck = _index == 0;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: isQuickCheck
            ? const QuickCheckHomeTab()
            : _PlaceholderTab(index: _index),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: ChatFab(onTap: _openChat),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}

/// Placeholder tab dengan header kontekstual + kartu status jujur.
///
/// Judul mengikuti tab aktif (bukan nama app), dan kartu menjelaskan apa yang
/// akan hadir tanpa mengklaim fungsi yang belum dibangun.
class _PlaceholderTab extends StatelessWidget {
  const _PlaceholderTab({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    final data = switch (index) {
      1 => (
        eyebrow: AppStrings.homeHistoryEyebrow,
        line1: AppStrings.homeHistoryTitle1,
        line2: AppStrings.homeHistoryTitle2,
        subtitle: AppStrings.homeHistorySubtitle,
        icon: Icons.history_outlined,
        title: AppStrings.homeHistoryPlaceholderTitle,
        note: AppStrings.homeHistoryPlaceholderSubtitle,
      ),
      2 => (
        eyebrow: AppStrings.homeLearnEyebrow,
        line1: AppStrings.homeLearnTitle1,
        line2: AppStrings.homeLearnTitle2,
        subtitle: AppStrings.homeLearnSubtitle,
        icon: Icons.school_outlined,
        title: AppStrings.homeLearnPlaceholderTitle,
        note: AppStrings.homeLearnPlaceholderSubtitle,
      ),
      _ => (
        eyebrow: AppStrings.homeProfileEyebrow,
        line1: AppStrings.homeProfileTitle1,
        line2: AppStrings.homeProfileTitle2,
        subtitle: AppStrings.homeProfileSubtitle,
        icon: Icons.emoji_events_outlined,
        title: AppStrings.homeProfilePlaceholderTitle,
        note: AppStrings.homeProfilePlaceholderSubtitle,
      ),
    };
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppSectionHeader(
                eyebrow: data.eyebrow,
                titleLine1: data.line1,
                titleLine2: data.line2,
                subtitle: data.subtitle,
              ),
              const SizedBox(height: 18),
              Container(
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
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: AppColors.primary.withValues(alpha: 0.1),
                      ),
                      child: Icon(
                        data.icon,
                        size: 23,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data.title,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.2,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            data.note,
                            style: const TextStyle(
                              fontSize: 13,
                              height: 1.6,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
