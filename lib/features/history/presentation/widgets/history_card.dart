import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../quick_check/domain/entities/verification_result.dart';
import '../../../quick_check/presentation/widgets/verdict_presentation.dart';
import '../../domain/entities/history_entry.dart';

class HistoryCard extends StatelessWidget {
  const HistoryCard({
    super.key,
    required this.entry,
    required this.onTap,
  });

  final HistoryEntry entry;
  final VoidCallback onTap;

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
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: style.accent.withValues(alpha: 0.25)),
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
                          child: Text(
                            result.verdict.label,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.7,
                              color: style.accent,
                            ),
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
                        Icon(source.$1, size: 14, color: AppColors.textSecondary),
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
                          _relativeDate(result.checkedAt),
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
    );
  }

  static String _host(String? rawUrl) {
    final uri = rawUrl == null ? null : Uri.tryParse(rawUrl);
    return uri?.host.isNotEmpty == true ? uri!.host : 'Link artikel';
  }

  static String _relativeDate(DateTime date) {
    final difference = DateTime.now().difference(date.toLocal());
    if (difference.inMinutes < 1) return 'Baru saja';
    if (difference.inHours < 1) return '${difference.inMinutes} mnt';
    if (difference.inDays < 1) return '${difference.inHours} jam';
    if (difference.inDays < 7) return '${difference.inDays} hari';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
