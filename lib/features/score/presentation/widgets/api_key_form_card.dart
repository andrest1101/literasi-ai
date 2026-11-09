import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_styles.dart';

/// Section 1: kelola kunci perangkat.
///
/// Tombol simpan dan hapus berdampingan: simpan (primer, lebar)
/// menjadi aksi utama, hapus hanya outline ringan agar tidak
/// bersaing secara visual.
class ApiKeyFormCard extends StatelessWidget {
  const ApiKeyFormCard({
    super.key,
    required this.controller,
    required this.obscure,
    required this.localError,
    required this.saving,
    required this.onToggleObscure,
    required this.onPaste,
    required this.onSave,
    required this.onRemove,
  });

  final TextEditingController controller;
  final bool obscure;
  final String? localError;
  final bool saving;
  final VoidCallback onToggleObscure;
  final VoidCallback onPaste;
  final VoidCallback onSave;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SectionHeader(badge: '1', title: AppStrings.apiKeyFormTitle),
        const SizedBox(height: 12),
        TextField(
          controller: controller,
          obscureText: obscure,
          autocorrect: false,
          enableSuggestions: false,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            labelText: AppStrings.apiKeyFieldLabel,
            hintText: AppStrings.apiKeyFieldHint,
            errorText: localError,
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.hairline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.hairline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
            ),
            prefixIcon: const Icon(Icons.key_rounded),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: AppStrings.apiKeyPaste,
                  onPressed: saving ? null : onPaste,
                  icon: const Icon(Icons.content_paste_rounded, size: 20),
                ),
                IconButton(
                  tooltip: obscure
                      ? AppStrings.apiKeyShowKey
                      : AppStrings.apiKeyHideKey,
                  onPressed: onToggleObscure,
                  icon: Icon(
                    obscure
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 52,
                child: FilledButton.icon(
                  onPressed: saving ? null : onSave,
                  icon: saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save_outlined, size: 19),
                  label: const Text(AppStrings.apiKeySave),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    textStyle: const TextStyle(
                      fontFamily: AppStyles.fontFamily,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              height: 52,
              child: OutlinedButton.icon(
                onPressed: saving ? null : onRemove,
                icon: const Icon(Icons.delete_outline_rounded, size: 18),
                label: const Text(AppStrings.apiKeyRemove),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.danger,
                  side: BorderSide(
                    color: AppColors.danger.withValues(alpha: 0.5),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Header section bernomor: lingkaran badge + judul.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.badge, required this.title});

  final String badge;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 26,
          height: 26,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary,
          ),
          child: Text(
            badge,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
