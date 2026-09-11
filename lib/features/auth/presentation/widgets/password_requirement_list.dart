import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';

/// Hasil evaluasi syarat kata sandi.
class PasswordRules {
  const PasswordRules({required this.minLength, required this.hasDigit});

  final bool minLength;
  final bool hasDigit;

  bool get allOk => minLength && hasDigit;

  factory PasswordRules.of(String value) {
    return PasswordRules(
      minLength: value.length >= 6,
      hasDigit: RegExp(r'[0-9]').hasMatch(value),
    );
  }
}

/// Checklist syarat kata sandi yang diperbarui live saat mengetik.
///
/// Sengaja tanpa kotak atau latar: hanya baris ikon kecil dan teks rata
/// kiri dengan indent, agar tidak dikira kolom input. Status berubah lewat
/// warna dan ikon dengan animasi pergantian yang halus.
class PasswordRequirementList extends StatelessWidget {
  const PasswordRequirementList({super.key, required this.password});

  final String password;

  @override
  Widget build(BuildContext context) {
    final rules = PasswordRules.of(password);
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _RequirementRow(
            met: rules.minLength,
            text: AppStrings.registerReqLength,
          ),
          const SizedBox(height: 4),
          _RequirementRow(
            met: rules.hasDigit,
            text: AppStrings.registerReqDigit,
          ),
        ],
      ),
    );
  }
}

class _RequirementRow extends StatelessWidget {
  const _RequirementRow({required this.met, required this.text});

  final bool met;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (child, anim) =>
              ScaleTransition(scale: anim, child: child),
          child: Icon(
            met ? Icons.check_circle_rounded : Icons.circle_outlined,
            key: ValueKey(met),
            size: 16,
            color: met ? AppColors.success : AppColors.neutral,
          ),
        ),
        const SizedBox(width: 6),
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: TextStyle(
            fontSize: 13,
            fontWeight: met ? FontWeight.w700 : FontWeight.w500,
            color: met ? AppColors.success : AppColors.textSecondary,
          ),
          child: Text(text),
        ),
      ],
    );
  }
}
