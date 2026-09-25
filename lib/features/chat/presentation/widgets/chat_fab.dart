import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';

/// Tombol Chat AI mengambang: opsi A: shield verified + badge sparkle.
///
/// Ikon robot generik (`smart_toy`) diganti `verified_user` agar selaras
/// dengan identitas cek-fakta (medallion auth, hero Quick Check). Badge
/// sparkle kecil di sudut menandai bahwa ini asisten AI, bukan menu biasa.
/// Ring putih 2.5px memisahkan FAB dari konten di belakangnya.
///
/// Micro-interaction profesional (tanpa robot, tanpa loop animasi):
/// entrance pop 0.85→1.0 sekali saat muncul, tekan menyusut ke 0.92
/// via [GestureDetector.onTapDown/Up/Cancel], dan kilau diagonal statis
/// di lapisan gradien. Tidak ada `repeat()`: test widget tetap
/// deterministik (`pumpAndSettle` tidak menggantung).
class ChatFab extends StatefulWidget {
  const ChatFab({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  State<ChatFab> createState() => _ChatFabState();
}

class _ChatFabState extends State<ChatFab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _press = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 120),
  );
  late final Animation<double> _scale = Tween<double>(
    begin: 1.0,
    end: 0.92,
  ).animate(CurvedAnimation(parent: _press, curve: Curves.easeOutCubic));

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: AppStrings.chatFabLabel,
      child: Tooltip(
        message: AppStrings.chatFabLabel,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.85, end: 1.0),
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutBack,
          builder: (context, entrance, child) {
            return Transform.scale(scale: entrance, child: child);
          },
          child: GestureDetector(
            onTap: widget.onTap,
            onTapDown: (_) => _press.forward(),
            onTapUp: (_) => _press.reverse(),
            onTapCancel: () => _press.reverse(),
            child: AnimatedBuilder(
              animation: _scale,
              builder: (context, child) {
                return Transform.scale(scale: _scale.value, child: child);
              },
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF2F80ED), Color(0xFF124A9B)],
                  ),
                  border: Border.all(color: Colors.white, width: 2.5),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x441A73E8),
                      blurRadius: 18,
                      offset: Offset(0, 8),
                    ),
                    BoxShadow(
                      color: Color(0x1A101A33),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Kilau diagonal statis: kesan kaca premium tanpa
                    // animasi loop yang menguras baterai.
                    Positioned.fill(
                      child: ClipOval(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: const Alignment(0.1, 0.6),
                              colors: [
                                Colors.white.withValues(alpha: 0.22),
                                Colors.white.withValues(alpha: 0.0),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Center(
                      child: Icon(
                        Icons.verified_user_rounded,
                        size: 28,
                        color: Colors.white,
                      ),
                    ),
                    const Positioned(
                      right: 7,
                      bottom: 7,
                      child: _AiSparkleBadge(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AiSparkleBadge extends StatelessWidget {
  const _AiSparkleBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.25),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33101A33),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: const Icon(
        Icons.auto_awesome_rounded,
        size: 13,
        color: AppColors.primary,
      ),
    );
  }
}
