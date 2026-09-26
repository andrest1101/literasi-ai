import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../quick_check/domain/entities/verification_result.dart';
import '../../../quick_check/presentation/widgets/verdict_presentation.dart';
import '../../domain/entities/history_entry.dart';
import '../utils/history_time_ago.dart';

class HistoryCard extends StatelessWidget {
  const HistoryCard({
    super.key,
    required this.entry,
    required this.onTap,
    this.isLatest = false,
  });

  final HistoryEntry entry;
  final VoidCallback onTap;

  /// Penanda entri terbaru: badge kecil non-intrusif agar daftar panjang
  /// punya titik orientasi. Callsite (daftar) yang memutuskan: hanya bila
  /// daftar lebih dari satu dan tanpa filter atau search aktif, agar tidak
  /// menyesatkan.
  final bool isLatest;

  /// Tag Hero badge verdict: satu-satunya sumber kebenaran agar kartu
  /// daftar dan layar detail selalu memakai tag yang sama per entri.
  static String heroTagFor(String entryId) => 'history-verdict-$entryId';

  @override
  Widget build(BuildContext context) {
    final result = entry.result;
    final style = VerdictPresentation.of(result.verdict);
    final source = switch (result.source) {
      VerificationSource.text => (Icons.text_snippet_outlined, 'Teks'),
      VerificationSource.image => (Icons.image_outlined, 'Gambar'),
      VerificationSource.url => (Icons.link_rounded, _host(result.sourceUrl)),
    };
    // Spine aksen verdict 6px di tepi kiri (signature yang sama dengan
    // kartu hasil): lapisan warna di belakang isi agar sudut membulat
    // tetap rapi; border kartu dinetralkan supaya spine yang bicara.
    // Diimplementasi via widget terpisah agar struktur build tetap datar.
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: _HistorySpine(
          accent: style.accent,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              color: AppColors.surface,
              border: Border.all(
                color: AppColors.neutral.withValues(alpha: 0.2),
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0D101A33),
                  blurRadius: 16,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Hero(
                  tag: HistoryCard.heroTagFor(entry.id),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: style.accent.withValues(alpha: 0.11),
                    ),
                    child: Icon(style.icon, color: style.accent, size: 23),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    result.verdict.label,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.7,
                                      color: style.accent,
                                    ),
                                  ),
                                ),
                                if (isLatest) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 7,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(999),
                                      color: AppColors.primary,
                                    ),
                                    child: const Text(
                                      'TERBARU',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.8,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Text(
                            '${result.confidence}%',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              fontFeatures: [FontFeature.tabularFigures()],
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        result.claim,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.45,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(
                            source.$1,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              source.$2,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            historyTimeAgo(result.checkedAt),
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _host(String? rawUrl) {
    final uri = rawUrl == null ? null : Uri.tryParse(rawUrl);
    return uri?.host.isNotEmpty == true ? uri!.host : 'Link artikel';
  }
}

/// Spine aksen verdict kartu riwayat: garis 6px warna verdict di tepi
/// kiri, konsisten dengan spine kartu hasil. Lapisan warna di belakang
/// isi (bukan `Border.left`) agar sudut membulat 22px tetap rapi.
class _HistorySpine extends StatelessWidget {
  const _HistorySpine({required this.accent, required this.child});

  final Color accent;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: ExcludeSemantics(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                color: accent,
              ),
            ),
          ),
        ),
        Padding(padding: const EdgeInsets.only(left: 6), child: child),
      ],
    );
  }
}
