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
    final args = ModalRoute.of(context)?.settings.arguments;
    var mode = QuickCheckInitialMode.text;
    String? claim;
    if (args is QuickCheckInitialMode) {
      mode = args;
    } else if (args is String) {
      claim = args;
    } else if (args is Map) {
      final rawMode = args['mode'];
      if (rawMode == QuickCheckInitialMode.image) {
        mode = QuickCheckInitialMode.image;
      }
      final rawClaim = args['claim'];
      if (rawClaim is String) claim = rawClaim;
    }
    return QuickCheckSessionScreen(initialMode: mode, initialClaim: claim);
  }
}
