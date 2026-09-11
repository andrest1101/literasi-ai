import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/usecases/verify_claim.dart';

/// Area input sesi Quick Check — bukan kartu bertumpuk.
///
/// Panel input memakai satu permukaan filled kontras dengan radius besar,
/// sehingga whitespace lega tetapi hierarki tetap jelas.
class QuickCheckInputSection extends StatelessWidget {
  const QuickCheckInputSection({
    super.key,
    required this.controller,
    required this.localError,
    required this.loading,
    required this.valid,
    required this.onVerify,
    required this.onClear,
  });

  final TextEditingController controller;
  final String? localError;
  final bool loading;
  final bool valid;
  final VoidCallback onVerify;
  final VoidCallback onClear;

  int get _length => controller.text.trim().length;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                AppStrings.quickCheckFormTitle,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            _CounterPill(length: _length),
          ],
        ),
        const SizedBox(height: 6),
        const Text(
          AppStrings.quickCheckFormSubtitle,
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
                  : AppColors.neutral.withValues(alpha: 0.22),
              width: 1.2,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0F101A33),
                blurRadius: 22,
                offset: Offset(0, 10),
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
                      Icons.fact_check_outlined,
                      size: 20,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      AppStrings.quickCheckInputLabel,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
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
              const SizedBox(height: 8),
              TextField(
                controller: controller,
                enabled: !loading,
                minLines: 5,
                maxLines: 8,
                maxLength: VerifyClaim.maxLength,
                textInputAction: TextInputAction.newline,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.6,
                  color: AppColors.textPrimary,
                ),
                decoration: const InputDecoration(
                  hintText: AppStrings.quickCheckInputHint,
                  hintStyle: TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: AppColors.textSecondary,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  filled: false,
                  counterText: '',
                ),
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
            ],
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 56,
          child: FilledButton.icon(
            onPressed: loading || !valid ? null : onVerify,
            icon: loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.verified_outlined, size: 22),
            label: Text(
              loading
                  ? AppStrings.quickCheckAnalyzingTitle
                  : AppStrings.quickCheckVerify,
            ),
            style:
                FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xFFE8EDF5),
                  disabledForegroundColor: const Color(0xFF5B6B80),
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
                      return const BorderSide(color: Color(0xFFD5DDE9));
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

class _CounterPill extends StatelessWidget {
  const _CounterPill({required this.length});

  final int length;

  @override
  Widget build(BuildContext context) {
    final nearLimit = length >= VerifyClaim.maxLength - 100;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: nearLimit
            ? AppColors.danger.withValues(alpha: 0.1)
            : AppColors.primary.withValues(alpha: 0.1),
        border: Border.all(
          color: nearLimit
              ? AppColors.danger.withValues(alpha: 0.3)
              : AppColors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Text(
        '$length/${VerifyClaim.maxLength}',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          fontFeatures: const [FontFeature.tabularFigures()],
          color: nearLimit ? AppColors.danger : AppColors.primary,
        ),
      ),
    );
  }
}
