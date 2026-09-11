import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/verification_result.dart';

/// Bagian hasil sesi — satu alur vertikal, bukan kartu bertumpuk.
///
/// Struktur: header verdict → confidence → klaim → analisis → saran → aksi.
/// Warna status hanya sebagai aksen pada pita dan badge; teks tetap gelap
/// agar kontras dan profesional sesuai palet resmi LiterasiAI.
class QuickCheckResultSection extends StatelessWidget {
  const QuickCheckResultSection({
    super.key,
    required this.result,
    required this.loading,
    required this.onNewCheck,
  });

  final VerificationResult result;
  final bool loading;
  final VoidCallback onNewCheck;

  @override
  Widget build(BuildContext context) {
    final style = VerdictPresentation.of(result.verdict);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                AppStrings.quickCheckResultTitle,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            TextButton.icon(
              onPressed: loading ? null : onNewCheck,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text(AppStrings.quickCheckNewCheck),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                textStyle: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            color: AppColors.surface,
            border: Border.all(
              color: style.accent.withValues(alpha: 0.26),
              width: 1.2,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14101A33),
                blurRadius: 26,
                offset: Offset(0, 14),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(26),
                  ),
                  color: style.accent.withValues(alpha: 0.1),
                  border: Border(
                    bottom: BorderSide(
                      color: style.accent.withValues(alpha: 0.2),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.surface,
                        border: Border.all(
                          color: style.accent.withValues(alpha: 0.4),
                          width: 1.4,
                        ),
                      ),
                      child: Icon(style.icon, size: 27, color: style.accent),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(999),
                              color: style.accent,
                            ),
                            child: Text(
                              result.verdict.label,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.9,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${result.confidence}%',
                                style: const TextStyle(
                                  fontSize: 32,
                                  height: 1,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -1,
                                  fontFeatures: [FontFeature.tabularFigures()],
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Padding(
                                padding: EdgeInsets.only(bottom: 3),
                                child: Text(
                                  AppStrings.quickCheckConfidenceLabel,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _ConfidenceTrack(
                      value: result.confidence,
                      accent: style.accent,
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          color: AppColors.neutral.withValues(alpha: 0.12),
                          border: Border.all(
                            color: AppColors.neutral.withValues(alpha: 0.24),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              result.source == VerificationSource.image
                                  ? Icons.image_outlined
                                  : Icons.text_snippet_outlined,
                              size: 13,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              result.source == VerificationSource.image
                                  ? AppStrings.quickCheckSourceImage
                                  : AppStrings.quickCheckSourceText,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (result.source == VerificationSource.image &&
                        result.imageFileName != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.attach_file_rounded,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${AppStrings.quickCheckImageAttached}: ${result.imageFileName}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 18),
                    const _SectionLabel(
                      icon: Icons.format_quote_rounded,
                      label: AppStrings.quickCheckClaimLabel,
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: AppColors.background,
                        border: Border(
                          left: BorderSide(color: style.accent, width: 3.5),
                        ),
                      ),
                      child: Text(
                        result.claim,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.6,
                          fontStyle: FontStyle.italic,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const _SectionLabel(
                      icon: Icons.psychology_outlined,
                      label: AppStrings.quickCheckExplanationLabel,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      result.explanation,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.65,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(height: 1),
                    const SizedBox(height: 16),
                    const _SectionLabel(
                      icon: Icons.travel_explore_outlined,
                      label: AppStrings.quickCheckSuggestionLabel,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      result.suggestion,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.6,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.info_outline_rounded,
              size: 16,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                AppStrings.quickCheckDisclaimer,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.55,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Panel error sesi — satu permukaan dengan CTA retry yang jelas.
class QuickCheckErrorSection extends StatelessWidget {
  const QuickCheckErrorSection({
    super.key,
    required this.error,
    required this.canRetry,
    required this.onRetry,
  });

  final Object error;
  final bool canRetry;
  final VoidCallback onRetry;

  String get _message {
    if (error is Failure) return (error as Failure).message;
    return 'Terjadi kesalahan tak terduga. Coba lagi.';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: AppColors.surface,
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            children: [
              Icon(Icons.cloud_off_outlined, size: 22, color: AppColors.danger),
              SizedBox(width: 8),
              Text(
                'Verifikasi gagal',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _message,
            style: const TextStyle(
              fontSize: 13,
              height: 1.6,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: canRetry ? onRetry : null,
            icon: const Icon(Icons.refresh_rounded, size: 20),
            label: const Text(AppStrings.quickCheckRetry),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              textStyle: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

/// Gaya presentasi tiap verdict — hanya memakai palet resmi LiterasiAI.
class VerdictPresentation {
  const VerdictPresentation({required this.accent, required this.icon});

  final Color accent;
  final IconData icon;

  factory VerdictPresentation.of(Verdict verdict) {
    return switch (verdict) {
      Verdict.hoaks => const VerdictPresentation(
        accent: AppColors.danger,
        icon: Icons.gpp_bad_outlined,
      ),
      Verdict.valid => const VerdictPresentation(
        accent: AppColors.success,
        icon: Icons.verified_outlined,
      ),
      Verdict.perluDicek => const VerdictPresentation(
        accent: Color(0xFFB7791F),
        icon: Icons.search_outlined,
      ),
      Verdict.tidakDapatDipastikan => const VerdictPresentation(
        accent: AppColors.neutral,
        icon: Icons.help_outline_rounded,
      ),
    };
  }
}

class _ConfidenceTrack extends StatelessWidget {
  const _ConfidenceTrack({required this.value, required this.accent});

  final int value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: SizedBox(
        height: 8,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.neutral.withValues(alpha: 0.16),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: value.clamp(0, 100) / 100,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [accent.withValues(alpha: 0.7), accent],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.6,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
