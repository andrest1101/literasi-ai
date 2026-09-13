import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_strings.dart';
import '../features/chat/presentation/screens/chat_screen.dart';
import '../features/chat/presentation/widgets/chat_fab.dart';
import '../features/quick_check/presentation/screens/quick_check_home_tab.dart';
import '../shared/widgets/bottom_nav_bar.dart';

/// Home shell — 4 tab + FAB Chat AI melayang di atas konten.
///
/// Chat dikeluarkan dari bottom nav agar nav tidak sesak. FAB 60px diposisikan
/// via [Scaffold.floatingActionButton] dengan gap 16px di atas navbar sehingga
/// area sentuh nav steril. Ikon opsi A: shield verified + badge sparkle AI,
/// selaras identitas cek-fakta (bukan robot generik).
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  static const route = '/home';

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _index = 0;

  static const _titles = [
    AppStrings.quickCheckTitle,
    AppStrings.navHistory,
    AppStrings.navLearn,
    AppStrings.navProfile,
  ];

  static const _placeholders = [
    'Riwayat verifikasi + Firestore (Phase 3)',
    'Mini-course literasi (Phase 4)',
    'Profil & Literacy Score (Phase 3)',
  ];

  void _openChat() {
    Navigator.of(context).pushNamed(ChatScreen.route);
  }

  @override
  Widget build(BuildContext context) {
    final isQuickCheck = _index == 0;
    return Scaffold(
      appBar: AppBar(title: Text(_titles[_index])),
      body: isQuickCheck
          ? const QuickCheckHomeTab()
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  _placeholders[_index - 1],
                  textAlign: TextAlign.center,
                ),
              ),
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
