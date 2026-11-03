import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';
import '../features/chat/presentation/screens/chat_screen.dart';
import '../features/chat/presentation/widgets/chat_fab.dart';
import '../features/history/presentation/screens/history_list_screen.dart';
import '../features/learn/presentation/screens/course_list_screen.dart';
import '../features/quick_check/data/datasources/share_target_service.dart';
import '../features/quick_check/domain/entities/share_target_payload.dart';
import '../features/quick_check/presentation/screens/quick_check_home_tab.dart';
import '../features/quick_check/presentation/screens/quick_check_session_screen.dart';
import '../features/quick_check/presentation/widgets/share_target_launch.dart';
import '../features/score/presentation/screens/profile_screen.dart';
import '../shared/widgets/bottom_nav_bar.dart';

/// Home shell: 4 tab tanpa AppBar + FAB Chat AI melayang di atas konten.
///
/// Tiap tab memegang judulnya sendiri di body (kontekstual: Cek, Riwayat,
/// Belajar, Profil) sehingga tidak ada brand ganda di semua halaman.
/// Wordmark kecil hanya ada di tab Cek. Navbar pill mengambang
/// ([AppBottomNavBar]); FAB Chat diangkat di atas pill agar tidak menimpa.
///
/// Tab disimpan di [IndexedStack] yang di-mount malas: berpindah tab tidak
/// lagi membuang widget lama, jadi posisi scroll, kata kunci pencarian, dan
/// state lokal lain bertahan. Tab yang belum pernah dibuka sengaja tidak
/// dibangun agar app start tidak menembak empat layar (dan stream Firestore)
/// sekaligus.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  static const route = '/home';

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  static const int _tabCount = 4;

  int _index = 0;

  /// Indeks tab yang sudah pernah dibuka. Tab lain tetap berupa placeholder
  /// sampai pengguna benar-benar mengunjunginya.
  final Set<int> _mounted = {0};

  final ShareTargetService _shareTargetService = ShareTargetService();
  StreamSubscription<ShareTargetPayload>? _shareSubscription;

  @override
  void initState() {
    super.initState();
    unawaited(_openInitialShareTarget());
    _shareSubscription = _shareTargetService.watchShareTargets().listen(
      _handleIncomingShare,
      onError: (_) {
        if (!mounted) return;
        _showShareTargetError(AppStrings.shareTargetInvalid);
      },
    );
  }

  @override
  void dispose() {
    _shareSubscription?.cancel();
    super.dispose();
  }

  /// Share Target saat cold start: payload diambil satu kali saat Home sudah
  /// siap, sehingga auth/onboarding tidak perlu diubah atau dibypass.
  Future<void> _openInitialShareTarget() async {
    final payload = await _shareTargetService.fetchInitialShare();
    if (payload == null || !mounted) return;
    _openShareTarget(payload);
  }

  void _handleIncomingShare(ShareTargetPayload payload) {
    if (!mounted) return;
    _openShareTarget(payload);
  }

  void _openShareTarget(ShareTargetPayload payload) {
    final launch = ShareTargetLaunch.fromPayload(payload);
    if (launch.errorMessage != null) {
      _showShareTargetError(launch.errorMessage!);
      return;
    }

    Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => QuickCheckSessionScreen(
          initialMode: launch.mode,
          initialClaim: launch.initialClaim,
          initialUrl: launch.initialUrl,
          initialImage: launch.image,
        ),
      ),
    );
  }

  void _showShareTargetError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  void _openChat() {
    Navigator.of(context).pushNamed(ChatScreen.route);
  }

  void _openTab(int index) {
    if (index == _index) return;
    setState(() {
      _index = index;
      _mounted.add(index);
    });
  }

  Widget _buildTab(int index) {
    return switch (index) {
      0 => QuickCheckHomeTab(onOpenProfile: () => _openTab(3)),
      1 => const HistoryListScreen(),
      2 => const CourseListScreen(),
      _ => const ProfileScreen(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Back di tab mana pun kembali ke tab Cek lebih dulu; hanya dari Cek
      // sistem boleh menutup route (keluar aplikasi).
      canPop: _index == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _openTab(0);
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          bottom: false,
          child: IndexedStack(
            index: _index,
            sizing: StackFit.expand,
            children: [
              for (var i = 0; i < _tabCount; i++)
                if (_mounted.contains(i))
                  _buildTab(i)
                else
                  const SizedBox.shrink(),
            ],
          ),
        ),
        // Tab Profil tidak memakai FAB: badge nav di kanan bawah akan
        // bertumpuk dengan FAB dan kartu skor tertutup. Tiga tab lain tetap
        // punya akses cepat ke Chat AI.
        floatingActionButton: _index == _tabCount - 1
            ? null
            : Transform.translate(
                // Turun 8px dari margin bawaan Scaffold (16px): FAB duduk
                // rapat 8px di atas zona badge navbar. Tidak lebih rendah:
                // badge tab Profil butuh zona itu (test no-overlap).
                offset: const Offset(0, 8),
                child: ChatFab(onTap: _openChat),
              ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        bottomNavigationBar: AppBottomNavBar(
          currentIndex: _index,
          onTap: _openTab,
        ),
      ),
    );
  }
}
