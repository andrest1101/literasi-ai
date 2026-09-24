import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/api_key_resolver.dart';
import '../../../../shared/widgets/app_section_header.dart';
import '../../../auth/presentation/screens/auth_screen.dart';
import '../../../history/presentation/providers/history_providers.dart';
import '../providers/score_providers.dart';
import '../widgets/score_breakdown.dart';
import '../widgets/score_ring.dart';
import 'api_key_screen.dart';

/// Tab Profil fungsional pertama — skor + akun + info.
///
/// Header kontekstual, cincin skor animasi, rincian sumber poin, dan kartu
/// akun yang jujur membedakan mode anonim vs tersinkron.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final score = ref.watch(scoreProvider);
    final userId = ref.watch(historyUserIdProvider);
    return SingleChildScrollView(
      // 148px: ruang pill navbar mengambang + FAB Chat di atasnya.
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 148),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AppSectionHeader(
                eyebrow: AppStrings.homeProfileEyebrow,
                titleLine1: AppStrings.homeProfileTitle1,
                titleLine2: AppStrings.homeProfileTitle2,
                subtitle: AppStrings.homeProfileSubtitle,
                accent: SectionAccent.profile,
              ),
              const SizedBox(height: 18),
              score.when(
                loading: () => const _ScoreShimmer(),
                error: (_, _) => _ScoreError(
                  onRetry: () => ref.invalidate(scoreProvider),
                ),
                data: (value) => ScoreRing(score: value),
              ),
              const SizedBox(height: 14),
              score.when(
                loading: () => const SizedBox.shrink(),
                error: (_, _) => const SizedBox.shrink(),
                data: (value) => ScoreBreakdown(score: value),
              ),
              const SizedBox(height: 14),
              _AccountCard(synced: userId != null),
              const SizedBox(height: 14),
              const _ApiKeyCard(),
            ],
          ),
        ),
      ),
    );
  }
}

/// User aman-test: tanpa Firebase init tetap null seperti
/// [historyUserIdProvider], agar widget test tidak crash.
User? _safeUser() {
  try {
    return FirebaseAuth.instance.currentUser;
  } catch (_) {
    return null;
  }
}

/// Kartu akun — avatar + status jujur + CTA masuk bagi tamu.
///
/// Anonim/tanpa login mendapat avatar "T" + tombol Masuk (route `/auth`
/// yang sudah ada, tanpa flow baru). Tersinkron mendapat avatar inisial
/// email bila tersedia. Tidak ada klaim nama yang tidak dimiliki data.
class _AccountCard extends ConsumerWidget {
  const _AccountCard({required this.synced});

  final bool synced;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(historyUserIdProvider) != null
        ? _safeUser()
        : null;
    final email = user?.email;
    final initial = email != null && email.isNotEmpty
        ? email.trim()[0].toUpperCase()
        : 'T';
    final accent = synced ? AppColors.success : AppColors.primary;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: AppColors.surface,
        border: Border.all(
          color: accent.withValues(alpha: 0.3),
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
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [accent, accent.withValues(alpha: 0.65)],
              ),
            ),
            child: Center(
              child: Text(
                initial,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  email ?? AppStrings.scoreGuestLabel,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  synced
                      ? AppStrings.scoreSyncedNote
                      : AppStrings.scoreAnonymousNote,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.6,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (!synced) ...[
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 42,
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.of(
                        context,
                      ).pushNamed(AuthScreen.route),
                      icon: const Icon(Icons.login_rounded, size: 18),
                      label: const Text(AppStrings.scoreLoginCta),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: BorderSide(
                          color: AppColors.primary.withValues(alpha: 0.4),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton bernyawa saat skor dimuat — bukan kotak putih polos.
class _ScoreShimmer extends StatefulWidget {
  const _ScoreShimmer();

  @override
  State<_ScoreShimmer> createState() => _ScoreShimmerState();
}

class _ScoreShimmerState extends State<_ScoreShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1200),
      )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: AppStrings.scoreLoading,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Container(
            height: 148,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
              color: AppColors.surface,
              border: Border.all(
                color: AppColors.neutral.withValues(alpha: 0.18),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 108,
                  height: 108,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.neutral.withValues(
                      alpha: 0.12 + 0.08 * _controller.value,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 22,
                        width: 110,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          color: AppColors.neutral.withValues(
                            alpha: 0.12 + 0.08 * _controller.value,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        height: 13,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(7),
                          color: AppColors.neutral.withValues(
                            alpha: 0.1 + 0.07 * _controller.value,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        height: 13,
                        width: 160,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(7),
                          color: AppColors.neutral.withValues(
                            alpha: 0.1 + 0.07 * _controller.value,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Kartu kunci API di Profil — entry point BYOK yang mudah ditemukan.
///
/// Menampilkan status (dart-define / kunci perangkat / demo) + tombol ke
/// layar pengaturan. Guest tanpa login tetap bisa memakai fitur ini karena
/// kunci disimpan per-perangkat, bukan per-akun.
class _ApiKeyCard extends ConsumerWidget {
  const _ApiKeyCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(apiKeyControllerProvider);
    return Container(
      padding: const EdgeInsets.all(18),
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
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: AppColors.primary.withValues(alpha: 0.1),
            ),
            child: const Icon(
              Icons.key_outlined,
              size: 23,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  AppStrings.apiKeySettingsTitle,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                status.when(
                  loading: () => const Text(
                    AppStrings.scoreLoading,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  error: (_, _) => const Text(
                    AppStrings.apiKeyInactive,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  data: (value) => Text(
                    switch (value.source) {
                      ApiKeySource.compileDefine =>
                        AppStrings.apiKeyActiveCompile,
                      ApiKeySource.userKey => AppStrings.apiKeyActiveUser,
                      ApiKeySource.none => AppStrings.apiKeyInactive,
                    },
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.6,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 44,
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.of(
                      context,
                    ).pushNamed(ApiKeyScreen.route),
                    icon: const Icon(Icons.settings_outlined, size: 18),
                    label: const Text(AppStrings.apiKeyOpenSettings),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: BorderSide(
                        color: AppColors.primary.withValues(alpha: 0.4),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Error card informatif bila stream skor gagal — dengan tombol coba lagi.
/// Pesan menegaskan ini soal penyimpanan skor (Firestore), bukan kunci API,
/// agar tidak tertukar dengan error Gemini.
class _ScoreError extends StatelessWidget {
  const _ScoreError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        color: AppColors.surface,
        border: Border.all(
          color: AppColors.danger.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            children: [
              Icon(
                Icons.cloud_off_outlined,
                size: 22,
                color: AppColors.danger,
              ),
              SizedBox(width: 8),
              Text(
                AppStrings.scoreLoadFailed,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            AppStrings.scoreLoadFailedSubtitle,
            style: TextStyle(
              fontSize: 13,
              height: 1.6,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 19),
            label: const Text(AppStrings.quickCheckRetry),
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
        ],
      ),
    );
  }
}
