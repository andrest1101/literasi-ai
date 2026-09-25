import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/verification_result.dart';
import 'verdict_presentation.dart';

/// Kartu gambar siap-share hasil verifikasi (PRD §4.1 Feature 4).
///
/// Layout portrait mandiri yang di-render off-screen via `screenshot`
/// `captureFromWidget`: bukan bagian dari scroll sesi. Komposisi: pita
/// header brand, hero verdict (badge + confidence besar), kutipan klaim,
/// lalu footer ajakan. Warna verdict konsisten dengan
/// [VerdictPresentation] agar identitas hasil terjaga di gambar share.
class ShareCard extends StatelessWidget {
  const ShareCard({super.key, required this.result});

  final VerificationResult result;

  /// Lebar render off-screen: cukup untuk teks tajam saat di-share.
  static const double renderWidth = 640;

  @override
  Widget build(BuildContext context) {
    final style = VerdictPresentation.of(result.verdict);
    return Container(
      width: renderWidth,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        color: AppColors.surface,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _BrandStrip(accent: style.accent),
          Padding(
            padding: const EdgeInsets.fromLTRB(36, 28, 36, 12),
            child: Row(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: style.accent.withValues(alpha: 0.12),
                    border: Border.all(
                      color: style.accent.withValues(alpha: 0.45),
                      width: 2,
                    ),
                  ),
                  child: Icon(style.icon, size: 36, color: style.accent),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          color: style.accent,
                        ),
                        child: Text(
                          result.verdict.label,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.1,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${result.confidence}%',
                            style: const TextStyle(
                              fontSize: 44,
                              height: 1,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -1.2,
                              fontFeatures: [FontFeature.tabularFigures()],
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Padding(
                            padding: EdgeInsets.only(bottom: 5),
                            child: Text(
                              AppStrings.quickCheckConfidenceLabel,
                              style: TextStyle(
                                fontSize: 13,
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
            padding: const EdgeInsets.fromLTRB(36, 16, 36, 8),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: AppColors.background,
                border: Border(
                  left: BorderSide(color: style.accent, width: 5),
                ),
              ),
              child: Text(
                '“${_shortClaim(result.claim)}”',
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 18,
                  height: 1.6,
                  fontStyle: FontStyle.italic,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(36, 8, 36, 28),
            child: Text(
              result.explanation,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 15,
                height: 1.6,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          _FooterStrip(accent: style.accent),
        ],
      ),
    );
  }

  static String _shortClaim(String claim) {
    final normalized = claim.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (normalized.length <= 160) return normalized;
    return '${normalized.substring(0, 160)}…';
  }
}

/// Pita brand atas: gradien biru dengan wordmark + label hasil.
class _BrandStrip extends StatelessWidget {
  const _BrandStrip({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 20),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2F80ED), Color(0xFF124A9B)],
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.16),
            ),
            child: const Icon(
              Icons.verified_user_rounded,
              size: 24,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.appName,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Hasil pemeriksaan AI',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFD6E5FE),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accent,
              border: Border.all(color: Colors.white, width: 2.5),
            ),
          ),
        ],
      ),
    );
  }
}

/// Footer ajakan: CTA + disclaimer satu baris.
class _FooterStrip extends StatelessWidget {
  const _FooterStrip({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(36, 18, 36, 22),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
        color: accent.withValues(alpha: 0.08),
        border: Border(
          top: BorderSide(color: accent.withValues(alpha: 0.25)),
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.verified_user_rounded,
                size: 18,
                color: AppColors.primary,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Cek sendiri di LiterasiAI',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            'Cek dulu sebelum sebar. Hasil AI bukan kebenaran mutlak.',
            style: TextStyle(
              fontSize: 12,
              height: 1.5,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
