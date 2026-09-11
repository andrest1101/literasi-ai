import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../shared/widgets/bottom_nav_bar.dart';

/// Home shell — 5 tab sesuai Screen Map PRD §5.
/// Isi tiap tab dibangun di Phase 2/3; placeholder inline agar tidak ada
/// file stub yang harus dihapus nanti.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  static const route = '/home';

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _index = 0;

  static const _titles = [
    'Quick Check',
    'Chat AI',
    'Riwayat',
    'Belajar',
    'Profil',
  ];

  static const _placeholders = [
    'Quick Check — verifikasi teks, gambar, URL (Phase 2)',
    'Chat AI literasi digital (Phase 3)',
    'Riwayat verifikasi + Firestore (Phase 3)',
    'Mini-course literasi (Phase 4)',
    'Profil & Literacy Score (Phase 3)',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titles[_index])),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(_placeholders[_index], textAlign: TextAlign.center),
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}
