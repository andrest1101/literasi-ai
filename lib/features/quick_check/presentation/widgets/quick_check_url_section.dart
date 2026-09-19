import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/usecases/verify_url_claim.dart';

/// Panel input link artikel sesi Quick Check.
///
/// Komposisi mengikuti ritme [QuickCheckInputSection] dan
/// [QuickCheckImageSection]: judul + subtitle, permukaan kerja, catatan
/// privasi, lalu CTA 56px. Identitas mode ini: ikon link, field satu baris
/// dengan tombol tempel, dan kartu ringkas pratinjau domain setelah URL
/// valid — tanpa kartu bertumpuk yang mengulang pola sama.
class QuickCheckUrlSection extends StatelessWidget {
  const QuickCheckUrlSection({
    super.key,
    required this.controller,
    required this.localError,
    required this.loading,
    required this.onVerify,
    required this.onClear,
  });

  final TextEditingController controller;
  final String? localError;
  final bool loading;
  final VoidCallback onVerify;
  final VoidCallback onClear;

  /// Tombol aktif selama ada teks — validasi skema/host jalan saat ditekan
  /// agar user dapat pesan error yang menjelaskan, bukan tombol mati misterius.
  bool get _canAttempt => controller.text.trim().isNotEmpty && !loading;

  /// Pratinjau host tampil hanya bila URL lolos validasi penuh — konsisten
  /// dengan aturan yang dipakai use case, bukan tebakan regex di UI.
  String get _host {
    if (!VerifyUrlClaim.isParsable(controller.text)) return '';
    final uri = Uri.tryParse(
      VerifyUrlClaim.normalize(controller.text),
    );
    return uri?.host ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final host = _host;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          AppStrings.quickCheckUrlTitle,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          AppStrings.quickCheckUrlSubtitle,
          style: TextStyle(
            fontSize: 13,
            height: 1.55,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            color: AppColors.surface,
            border: Border.all(
              color: localError != null
                  ? AppColors.danger.withValues(alpha: 0.45)
                  : host.isEmpty
                  ? AppColors.neutral.withValues(alpha: 0.22)
                  : AppColors.success.withValues(alpha: 0.4),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowInk.withValues(alpha: 0.06),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: AppColors.primary.withValues(alpha: 0.12),
                    ),
                    child: const Icon(
                      Icons.link_rounded,
                      size: 20,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      AppStrings.quickCheckUrlFieldLabel,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  if (controller.text.isNotEmpty)
                    IconButton(
                      tooltip: AppStrings.quickCheckClear,
                      onPressed: loading ? null : onClear,
                      style: IconButton.styleFrom(
                        minimumSize: const Size(38, 38),
                        backgroundColor: AppColors.neutral.withValues(
                          alpha: 0.12,
                        ),
                        foregroundColor: AppColors.textSecondary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.delete_outline_rounded, size: 19),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      enabled: !loading,
                      keyboardType: TextInputType.url,
                      textInputAction: TextInputAction.go,
                      onSubmitted: (_) {
                        if (_canAttempt) onVerify();
                      },
                      maxLines: 1,
                      maxLength: VerifyUrlClaim.maxLength,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.5,
                        color: AppColors.textPrimary,
                      ),
                      decoration: const InputDecoration(
                        hintText: AppStrings.quickCheckUrlHint,
                        hintStyle: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: AppColors.textSecondary,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        filled: false,
                        counterText: '',
                        contentPadding: EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _PasteButton(loading: loading, controller: controller),
                ],
              ),
              if (localError != null) ...[
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 16,
                      color: AppColors.danger,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        localError!,
                        style: const TextStyle(
                          fontSize: 12,
                          height: 1.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.danger,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              if (host.isNotEmpty && localError == null) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: AppColors.success.withValues(alpha: 0.08),
                    border: Border.all(
                      color: AppColors.success.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.public_rounded,
                        size: 16,
                        color: AppColors.success,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          host,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.check_circle_rounded,
                        size: 16,
                        color: AppColors.success,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.privacy_tip_outlined,
              size: 16,
              color: AppColors.textSecondary,
            ),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                AppStrings.quickCheckUrlPrivacyNote,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.55,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 56,
          child: FilledButton.icon(
            onPressed: _canAttempt ? onVerify : null,
            icon: loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.travel_explore_outlined, size: 22),
            label: Text(
              loading
                  ? AppStrings.quickCheckAnalyzingTitle
                  : AppStrings.quickCheckVerify,
            ),
            style:
                FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.disabledSurface,
                  disabledForegroundColor: AppColors.disabledInk,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                  elevation: loading ? 0 : 6,
                  shadowColor: AppColors.primary.withValues(alpha: 0.38),
                ).copyWith(
                  animationDuration: const Duration(milliseconds: 250),
                  side: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.disabled)) {
                      return const BorderSide(
                        color: AppColors.disabledBorder,
                      );
                    }
                    return BorderSide.none;
                  }),
                  elevation: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.disabled) || loading) {
                      return 0;
                    }
                    return 6;
                  }),
                ),
          ),
        ),
      ],
    );
  }
}

/// Tombol tempel dari clipboard — menghemat ketik link panjang di HP.
class _PasteButton extends StatelessWidget {
  const _PasteButton({required this.loading, required this.controller});

  final bool loading;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: OutlinedButton.icon(
        onPressed: loading
            ? null
            : () async {
                final data = await Clipboard.getData(Clipboard.kTextPlain);
                final text = data?.text?.trim() ?? '';
                if (text.isEmpty) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(AppStrings.quickCheckUrlPasteEmpty),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                  return;
                }
                controller.text = text;
              },
        icon: const Icon(Icons.content_paste_rounded, size: 19),
        label: const Text(AppStrings.quickCheckUrlPaste),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: BorderSide(color: AppColors.primary.withValues(alpha: 0.4)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
          padding: const EdgeInsets.symmetric(horizontal: 14),
        ),
      ),
    );
  }
}
