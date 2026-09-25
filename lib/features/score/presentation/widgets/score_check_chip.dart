import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/api_key_resolver.dart';
import '../../domain/entities/literacy_score.dart';
import '../providers/score_providers.dart';
import 'literacy_level_ui.dart';

/// Header status compact tab Cek — skor + status AI dalam satu baris.
///
/// Menggantikan dua pil full-width bertumpuk (skor, status kunci) yang
/// memboroskan ~100px vertikal. Kiri: progress ring level + label/poin
/// (ketuk → Profil). Kanan: dot status AI + label ringkas (ketuk →
/// Pengaturan kunci). Data murni dari provider yang sudah ada — tanpa
/// logic bisnis baru, tanpa angka palsu (guest tetap jujur Pemula 0).
class ScoreCheckChip extends ConsumerWidget {
  const ScoreCheckChip({super.key, this.onOpenProfile, this.onOpenKeySettings});

  final VoidCallback? onOpenProfile;
  final VoidCallback? onOpenKeySettings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final score = ref.watch(scoreProvider);
    final keyStatus = ref.watch(apiKeyControllerProvider);
    return Semantics(
      container: true,
      label: 'Ringkasan skor dan status AI',
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.neutral.withValues(alpha: 0.22),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0D101A33),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: _ScoreZone(score: score, onTap: onOpenProfile),
              ),
              Container(
                width: 1,
                height: 38,
                color: AppColors.neutral.withValues(alpha: 0.18),
              ),
              _KeyZone(status: keyStatus, onTap: onOpenKeySettings),
            ],
          ),
        ),
      ),
    );
  }
}

/// Zona kiri: ring progres level + label + poin. Tinggi total zona 60px.
class _ScoreZone extends StatelessWidget {
  const _ScoreZone({required this.score, required this.onTap});

  final AsyncValue<LiteracyScore> score;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = score.when(
      loading: () => const _ScoreContent(
        progress: 0,
        color: AppColors.neutral,
        icon: Icons.spa_outlined,
        label: 'Memuat skor...',
        sub: null,
      ),
      error: (_, _) => const _ScoreContent(
        progress: 0,
        color: AppColors.neutral,
        icon: Icons.spa_outlined,
        label: 'Pemula',
        sub: '0 poin',
      ),
      data: (value) {
        final next = value.level.next;
        return _ScoreContent(
          progress: value.progressInLevel,
          color: value.level.accent,
          icon: value.level.icon,
          label: value.level.label,
          sub: next == null
              ? '${value.total} poin · Level tertinggi'
              : '${value.total} poin · ${value.pointsToNext} ke ${next.label}',
        );
      },
    );
    return Semantics(
      button: true,
      label: 'Lihat skor literasi di Profil',
      child: InkWell(
        onTap: onTap,
        borderRadius: const BorderRadius.horizontal(
          left: Radius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: content,
        ),
      ),
    );
  }
}

class _ScoreContent extends StatelessWidget {
  const _ScoreContent({
    required this.progress,
    required this.color,
    required this.icon,
    required this.label,
    required this.sub,
  });

  final double progress;
  final Color color;
  final IconData icon;
  final String label;
  final String? sub;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ExcludeSemantics(
          child: SizedBox(
            width: 40,
            height: 40,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox.expand(
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 4,
                    color: color,
                    backgroundColor: color.withValues(alpha: 0.14),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Icon(icon, size: 18, color: color),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                  color: AppColors.textPrimary,
                ),
              ),
              if (sub != null)
                Text(
                  sub!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Zona kanan: dot status AI + label ringkas. Tinggi mengikuti zona kiri.
class _KeyZone extends StatelessWidget {
  const _KeyZone({required this.status, required this.onTap});

  final AsyncValue<ApiKeyStatus> status;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = status.when(
      loading: () => const _KeyContent(
        dot: AppColors.neutral,
        label: 'Cek kunci…',
        semantics: 'Status AI: memeriksa kunci',
      ),
      error: (_, _) => const _KeyContent(
        dot: AppColors.warning,
        label: 'Demo',
        semantics: 'Status AI: mode demo',
      ),
      data: (value) => _KeyContent(
        dot: value.configured ? AppColors.success : AppColors.warning,
        label: value.configured ? 'AI live' : 'Demo',
        semantics: value.configured
            ? 'Status AI: live. Buka Pengaturan kunci'
            : 'Status AI: mode demo. Buka Pengaturan kunci',
      ),
    );
    return Semantics(
      button: true,
      label: content.semantics,
      child: InkWell(
        onTap: onTap,
        borderRadius: const BorderRadius.horizontal(
          right: Radius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: content,
        ),
      ),
    );
  }
}

class _KeyContent extends StatelessWidget {
  const _KeyContent({
    required this.dot,
    required this.label,
    required this.semantics,
  });

  final Color dot;
  final String label;
  final String semantics;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ExcludeSemantics(
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(shape: BoxShape.circle, color: dot),
          ),
        ),
        const SizedBox(width: 7),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: 2),
        const Icon(
          Icons.chevron_right_rounded,
          size: 18,
          color: AppColors.textSecondary,
        ),
      ],
    );
  }
}
