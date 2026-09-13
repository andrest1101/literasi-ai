import 'package:flutter/material.dart';

import 'quick_check_session_screen.dart';

/// Kompatibilitas route lama `/quick-check`.
///
/// Implementasi sesi penuh kini ada di [QuickCheckSessionScreen]. Kelas ini
/// dipertahankan agar route lama dan test yang sudah ada tetap valid tanpa
/// menduplikasi logika UI.
class QuickCheckScreen extends StatelessWidget {
  const QuickCheckScreen({super.key});

  static const route = '/quick-check';

  @override
  Widget build(BuildContext context) {
    return const QuickCheckSessionScreen();
  }
}
