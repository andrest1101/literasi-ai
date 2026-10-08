import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';

/// Sisi background hapus pada [Dismissible].
///
/// * [leading]: terungkap saat kartu digeser ke kanan (area kiri terbuka).
/// * [trailing]: terungkap saat kartu digeser ke kiri (area kanan terbuka).
enum SwipeDeleteSide { leading, trailing }

/// Background merah aksi hapus: ikon + label "Hapus" yang terbaca.
///
/// Ikon dan label selalu berada di sisi area yang terbuka, dengan urutan
/// baca cermin: kiri = ikon lalu teks, kanan = teks lalu ikon. Padding
/// 22px menjaga konten tidak menempel tepi kartu pada layar 360px.
class SwipeDeleteBackground extends StatelessWidget {
  const SwipeDeleteBackground({super.key, required this.side});

  final SwipeDeleteSide side;

  @override
  Widget build(BuildContext context) {
    final leading = side == SwipeDeleteSide.leading;
    return Container(
      alignment: leading ? Alignment.centerLeft : Alignment.centerRight,
      padding: EdgeInsets.only(left: leading ? 22 : 0, right: leading ? 0 : 22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: AppColors.danger,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: leading
            ? const [_DeleteIcon(), SizedBox(width: 6), _DeleteLabel()]
            : const [_DeleteLabel(), SizedBox(width: 6), _DeleteIcon()],
      ),
    );
  }
}

class _DeleteIcon extends StatelessWidget {
  const _DeleteIcon();

  @override
  Widget build(BuildContext context) {
    return const Icon(
      Icons.delete_outline_rounded,
      color: Colors.white,
      size: 22,
    );
  }
}

class _DeleteLabel extends StatelessWidget {
  const _DeleteLabel();

  @override
  Widget build(BuildContext context) {
    return const Text(
      AppStrings.historySwipeDeleteLabel,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.2,
        color: Colors.white,
      ),
    );
  }
}
