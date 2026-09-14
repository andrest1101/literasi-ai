import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';

/// Bottom nav 4 destinasi — docked edge-to-edge, bukan floating.
///
/// Chat AI sengaja dikeluarkan dari tab dan dipindah ke FAB mengambang agar
/// nav tidak sesak di layar 360px. Gaya docked dipilih supaya kesan app tetap
/// stabil dan kredibel (PRD §7.1 Trustworthy), bukan playful.
class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(
            color: AppColors.neutral.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: NavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected: onTap,
          backgroundColor: AppColors.surface,
          surfaceTintColor: Colors.transparent,
          shadowColor: Colors.transparent,
          elevation: 0,
          height: 72,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          indicatorColor: AppColors.primary.withValues(alpha: 0.12),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.fact_check_outlined),
              selectedIcon: Icon(Icons.fact_check_rounded),
              label: AppStrings.navCheck,
              tooltip: 'Cek fakta',
            ),
            NavigationDestination(
              icon: Icon(Icons.history_outlined),
              selectedIcon: Icon(Icons.history_rounded),
              label: AppStrings.navHistory,
              tooltip: 'Riwayat verifikasi',
            ),
            NavigationDestination(
              icon: Icon(Icons.school_outlined),
              selectedIcon: Icon(Icons.school_rounded),
              label: AppStrings.navLearn,
              tooltip: 'Belajar literasi',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person_rounded),
              label: AppStrings.navProfile,
              tooltip: 'Profil pengguna',
            ),
          ],
        ),
      ),
    );
  }
}
