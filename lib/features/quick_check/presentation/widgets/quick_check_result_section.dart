import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:screenshot/screenshot.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/share_service.dart';
import '../../domain/entities/verification_result.dart';
import 'share_card.dart';
import 'verdict_presentation.dart';

/// Bagian hasil sesi — satu alur vertikal, bukan kartu bertumpuk.
///
/// Struktur: header verdict → confidence → klaim → analisis → saran → aksi.
/// Warna status hanya sebagai aksen pada pita dan badge; teks tetap gelap
/// agar kontras dan profesional sesuai palet resmi LiterasiAI.
///
/// Aksi terdiri dari tombol primer [Bagikan] (render [ShareCard] off-screen
/// lalu kirim sebagai gambar PNG, fallback teks bila capture gagal) dan
/// tautan sekunder "Periksa informasi lain".
class QuickCheckResultSection extends StatefulWidget {
  const QuickCheckResultSection({
    super.key,
    required this.result,
    required this.loading,
    required this.onNewCheck,
    this.shareService,
    this.onCaptureImage,
  });

  final VerificationResult result;
  final bool loading;
  final VoidCallback onNewCheck;

  /// Injeksi untuk test — menghindari share sheet asli.
  final ShareService? shareService;

  /// Injeksi capture untuk test — menggantikan `screenshot` asli.
  final Future<Uint8List> Function()? onCaptureImage;

  @override
  State<QuickCheckResultSection> createState() => _QuickCheckResultSectionState();
}

class _QuickCheckResultSectionState extends State<QuickCheckResultSection> {
  bool _sharing = false;

  bool get _busy => widget.loading || _sharing;

  Future<void> _share(BuildContext context) async {
    if (_busy) return;
    setState(() => _sharing = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final service = widget.shareService ?? ShareService();
      final capture = widget.onCaptureImage;
      if (capture != null) {
        final bytes = await capture();
        await service.shareImage(
          imageBytes: bytes,
          text: ShareService.buildShareText(widget.result),
        );
      } else {
        final bytes = await ScreenshotController().captureFromWidget(
          MediaQuery(
            data: MediaQuery.of(context),
            child: Material(child: ShareCard(result: widget.result)),
          ),
          context: context,
        );
        await service.shareImage(
          imageBytes: bytes,
          text: ShareService.buildShareText(widget.result),
        );
      }
    } catch (_) {
      try {
        final service = widget.shareService ?? ShareService();
        await service.shareTextFallback(widget.result);
      } catch (_) {
        if (context.mounted) {
          messenger.showSnackBar(
            const SnackBar(
              content: Text(AppStrings.quickCheckShareFailed),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = VerdictPresentation.of(widget.result.verdict);
    final sourceBadge = switch (widget.result.source) {
      VerificationSource.image => (
        icon: Icons.image_outlined,
        label: AppStrings.quickCheckSourceImage,
      ),
      VerificationSource.url => (
        icon: Icons.link_rounded,
        label: AppStrings.quickCheckSourceUrl,
      ),
      VerificationSource.text => (
        icon: Icons.text_snippet_outlined,
        label: AppStrings.quickCheckSourceText,
      ),
    };
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
              onPressed: _busy ? null : widget.onNewCheck,
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
                              widget.result.verdict.label,
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
                                '${widget.result.confidence}%',
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
                      value: widget.result.confidence,
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
                              sourceBadge.icon,
                              size: 13,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              sourceBadge.label,
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
                    if (widget.result.source == VerificationSource.image &&
                        widget.result.imageFileName != null) ...[
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
                              '${AppStrings.quickCheckImageAttached}: ${widget.result.imageFileName}',
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
                    if (widget.result.source == VerificationSource.url &&
                        widget.result.sourceUrl != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.public_rounded,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${AppStrings.quickCheckUrlAttached}: ${widget.result.sourceUrl}',
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
                        widget.result.claim,
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
                      widget.result.explanation,
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
                      widget.result.suggestion,
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
        SizedBox(
          height: 54,
          child: FilledButton.icon(
            onPressed: _busy ? null : () => _share(context),
            icon: _sharing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.ios_share_rounded, size: 20),
            label: Text(
              _sharing
                  ? AppStrings.quickCheckSharing
                  : AppStrings.quickCheckShare,
            ),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              disabledBackgroundColor: const Color(0xFFE8EDF5),
              disabledForegroundColor: const Color(0xFF5B6B80),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              textStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
              elevation: _sharing ? 0 : 5,
              shadowColor: AppColors.primary.withValues(alpha: 0.35),
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.info_outline_rounded,
              size: 16,
              color: AppColors.textSecondary,
            ),
            SizedBox(width: 8),
            Expanded(
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
///
/// Bila penyebabnya kunci API hilang, panel menambah tombol salin perintah
/// run agar pengguna bisa setup tanpa menebak perintah terminal.
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

  bool get _isMissingKey => _message.contains('GEMINI_API_KEY');

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
          if (_isMissingKey) ...[
            OutlinedButton.icon(
              onPressed: () async {
                await Clipboard.setData(
                  const ClipboardData(text: AppStrings.chatRunCommand),
                );
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(AppStrings.chatKeyCopied),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              icon: const Icon(Icons.content_copy_rounded, size: 18),
              label: const Text(AppStrings.chatKeyCopy),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                minimumSize: const Size.fromHeight(48),
                side: BorderSide(
                  color: AppColors.primary.withValues(alpha: 0.4),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                textStyle: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 10),
          ],
          FilledButton.icon(
            onPressed: canRetry && !_isMissingKey ? onRetry : null,
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
