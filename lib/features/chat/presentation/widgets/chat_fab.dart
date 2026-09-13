import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';

/// Tombol Chat AI mengambang — opsi A: shield verified + badge sparkle.
///
/// Ikon robot generik (`smart_toy`) diganti `verified_user` agar selaras
/// dengan identitas cek-fakta (medallion auth, hero Quick Check). Badge
/// sparkle kecil di sudut menandai bahwa ini asisten AI, bukan menu biasa.
/// Ring putih 2.5px memisahkan FAB dari konten di belakangnya.
class ChatFab extends StatelessWidget {
  const ChatFab({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: AppStrings.chatFabLabel,
      child: Tooltip(
        message: AppStrings.chatFabLabel,
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
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
                children: const [
                  Center(
                    child: Icon(
                      Icons.verified_user_rounded,
                      size: 28,
                      color: Colors.white,
                    ),
                  ),
                  Positioned(right: 7, bottom: 7, child: _AiSparkleBadge()),
                ],
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
