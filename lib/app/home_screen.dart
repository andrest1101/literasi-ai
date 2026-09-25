import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_colors.dart';
import '../features/chat/presentation/screens/chat_screen.dart';
import '../features/chat/presentation/widgets/chat_fab.dart';
import '../features/history/presentation/screens/history_list_screen.dart';
import '../features/learn/presentation/screens/course_list_screen.dart';
import '../features/quick_check/presentation/screens/quick_check_home_tab.dart';
import '../features/score/presentation/screens/profile_screen.dart';
import '../shared/widgets/bottom_nav_bar.dart';

/// Home shell: 4 tab tanpa AppBar + FAB Chat AI melayang di atas konten.
///
/// Tiap tab memegang judulnya sendiri di body (kontekstual: Cek, Riwayat,
/// Belajar, Profil) sehingga tidak ada brand ganda di semua halaman.
/// Wordmark kecil hanya ada di tab Cek. Navbar pill mengambang
/// ([AppBottomNavBar]); FAB Chat diangkat di atas pill agar tidak menimpa.
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

  void _openTab(int index) {
    if (index == _index) return;
    setState(() => _index = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: switch (_index) {
          0 => QuickCheckHomeTab(onOpenProfile: () => _openTab(3)),
          1 => const HistoryListScreen(),
          2 => const CourseListScreen(),
          _ => const ProfileScreen(),
        },
      ),
      floatingActionButton: Transform.translate(
        // Turun 8px dari margin bawaan Scaffold (16px): FAB duduk rapat
        // 8px di atas zona badge navbar. Tidak lebih rendah: badge tab
        // Profil butuh zona itu (test no-overlap mengunci gap >= 8px).
        offset: const Offset(0, 8),
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
