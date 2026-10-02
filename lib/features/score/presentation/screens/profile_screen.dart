import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_styles.dart';
import '../../../../core/utils/api_key_resolver.dart';
import '../../../auth/presentation/screens/auth_screen.dart';
import '../../../history/presentation/providers/history_providers.dart';
import '../../domain/entities/literacy_score.dart';
import '../providers/score_providers.dart';
import '../widgets/score_breakdown.dart';
import '../widgets/score_ring.dart';
import 'api_key_screen.dart';

/// Tab Profil: identitas + skor + menu pengaturan.
///
/// Tiga blok satu bahasa: kartu identitas (avatar inisial + email/label +
/// pill level + status sinkron + CTA masuk bagi tamu), kartu grup skor
/// ([ScoreRing] hero + [ScoreBreakdown] tanpa permukaan ganda), dan grup
/// menu "Pengaturan" ala settings profesional (baris ikon + chevron +
/// divider, baris destruktif terpisah). Hanya menu yang fungsinya nyata:
/// Kunci API (navigasi ada), Keluar (aksi baru, sebelumnya bolong), Tentang
/// (dialog versi). Tanpa password/notifikasi/dark-mode palsu.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final score = ref.watch(scoreProvider);
    final userId = ref.watch(historyUserIdProvider);
    return SingleChildScrollView(
      // 120px: ruang pill navbar mengambang + FAB Chat 60px di atasnya.
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _ProfileHeading(),
              const SizedBox(height: AppTabTitles.titleToContentGap),
              _IdentityCard(synced: userId != null),
              const SizedBox(height: 14),
              score.when(
                loading: () => const _ScoreShimmer(),
                error: (_, _) =>
                    _ScoreError(onRetry: () => ref.invalidate(scoreProvider)),
                data: (value) => _ScoreGroup(score: value),
              ),
              const SizedBox(height: 14),
              _SettingsGroup(synced: userId != null),
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

/// Keluar aman-test: tanpa Firebase init mengembalikan false (gagal
/// ramah), agar widget test tidak crash. Sukses mengembalikan true.
Future<bool> _safeSignOut() async {
  try {
    await FirebaseAuth.instance.signOut();
    return true;
  } catch (_) {
    return false;
  }
}

/// Heading compact tab Profil: judul two-tone 20px + 1 baris cara skor
/// bertambah. ScoreRing di bawahnya TIDAK disentuh: ring adalah konten
/// utama tab ini, bukan dekorasi. Menggantikan header editorial penuh;
/// aksen biru-personal dipertahankan pada kata kedua.
class _ProfileHeading extends StatelessWidget {
  const _ProfileHeading();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            children: [
              const TextSpan(
                text: AppStrings.homeProfileTitle1,
                style: AppTabTitles.compactLine1,
              ),
              TextSpan(
                text: ' ${AppStrings.homeProfileTitle2}',
                style: AppTabTitles.compactLine2(AppColors.primaryDark),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          AppStrings.homeProfileSubtitle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12.5,
            height: 1.55,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

/// Kartu identitas: avatar + nama + pill level + status sinkron.
///
/// Menggantikan judul tersebar + kartu akun terpisah: satu kartu berisi
/// siapa user (inisial email atau "T" tamu), level literasi saat ini, dan
/// status sinkron 1 baris. CTA Masuk hanya bagi tamu (route `/auth` yang
/// sudah ada, tanpa flow baru). Tidak ada klaim nama yang tidak dimiliki
/// data.
class _IdentityCard extends ConsumerWidget {
  const _IdentityCard({required this.synced});

  final bool synced;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(historyUserIdProvider) != null ? _safeUser() : null;
    final email = user?.email;
    final initial = email != null && email.isNotEmpty
        ? email.trim()[0].toUpperCase()
        : 'T';
    final accent = synced ? AppColors.success : AppColors.primary;
    final score = ref.watch(scoreProvider).valueOrNull;
    final levelLabel = score?.level.label ?? '';
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: AppColors.surface,
        border: Border.all(color: accent.withValues(alpha: 0.3)),
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
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    if (levelLabel.isNotEmpty)
                      _MiniPill(
                        icon: Icons.emoji_events_outlined,
                        text: '${AppStrings.scoreLevelPrefix} $levelLabel',
                        color: AppColors.primaryDark,
                      ),
                    _MiniPill(
                      icon: synced
                          ? Icons.cloud_done_outlined
                          : Icons.cloud_off_outlined,
                      text: synced ? 'Tersinkron' : 'Tamu',
                      color: accent,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
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
                      onPressed: () =>
                          Navigator.of(context).pushNamed(AuthScreen.route),
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
                        textStyle: const TextStyle(fontWeight: FontWeight.w700),
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

/// Pill kecil identitas: ikon + teks dalam tint aksen.
///
/// Satu bahasa dengan pill meta modul: tint 10%, tanpa border, ellipsis
/// agar tidak overflow di baris sempit.
class _MiniPill extends StatelessWidget {
  const _MiniPill({
    required this.icon,
    required this.text,
    required this.color,
  });

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: color.withValues(alpha: 0.1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Grup skor: ring hero + rincian sumber dalam satu kartu.
///
/// [ScoreRing] dan [ScoreBreakdown] dipertahankan utuh (dikunci test),
/// hanya pembungkusnya disatukan + judul grup agar tidak terbaca dua
/// kartu bertumpuk gaya beda.
class _ScoreGroup extends StatelessWidget {
  const _ScoreGroup({required this.score});

  final LiteracyScore score;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: AppColors.surface,
        border: Border.all(color: AppColors.neutral.withValues(alpha: 0.2)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D101A33),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            AppStrings.scoreGroupTitle,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ScoreRing(score: score),
          const SizedBox(height: 12),
          ScoreBreakdown(score: score),
        ],
      ),
    );
  }
}

/// Skeleton bernyawa saat skor dimuat: bukan kotak putih polos.
class _ScoreShimmer extends StatefulWidget {
  const _ScoreShimmer();

  @override
  State<_ScoreShimmer> createState() => _ScoreShimmerState();
}

class _ScoreShimmerState extends State<_ScoreShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
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

/// Grup menu Pengaturan: hanya baris yang fungsinya nyata.
///
/// Kunci API (navigasi ke layar pengaturan yang sudah ada), Keluar
/// (aksi baru: konfirmasi + signOut + invalidate agar UI ikut logout),
/// Tentang (dialog versi, bukan layar baru). Baris destruktif terpisah
/// ala settings profesional. Tanpa password/notifikasi/dark-mode palsu.
class _SettingsGroup extends ConsumerWidget {
  const _SettingsGroup({required this.synced});

  final bool synced;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final keyStatus = ref.watch(apiKeyControllerProvider);
    final keySubtitle = keyStatus.when(
      loading: () => AppStrings.scoreLoading,
      error: (_, _) => AppStrings.apiKeyInactive,
      data: (value) => switch (value.source) {
        ApiKeySource.compileDefine => AppStrings.apiKeyActiveCompile,
        ApiKeySource.userKey => AppStrings.apiKeyActiveUser,
        ApiKeySource.none => AppStrings.apiKeyInactive,
      },
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            AppStrings.profileMenuTitle,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: AppColors.surface,
            border: Border.all(color: AppColors.neutral.withValues(alpha: 0.2)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0D101A33),
                blurRadius: 16,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              _SettingsRow(
                icon: Icons.key_outlined,
                title: AppStrings.profileApiKeyRow,
                subtitle: keySubtitle,
                onTap: () =>
                    Navigator.of(context).pushNamed(ApiKeyScreen.route),
              ),
              _SettingsRow(
                icon: Icons.info_outline_rounded,
                title: AppStrings.profileAboutRow,
                subtitle: null,
                last: true,
                onTap: () => showDialog<void>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text(AppStrings.profileAboutRow),
                    content: const Text(AppStrings.profileAboutBody),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text(AppStrings.profileAboutClose),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: AppColors.surface,
            border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
          ),
          child: _SettingsRow(
            icon: Icons.logout_rounded,
            title: synced
                ? AppStrings.profileLogoutRow
                : AppStrings.profileGuestLogoutRow,
            subtitle: null,
            last: true,
            destructive: true,
            onTap: () => _confirmLogout(context, ref),
          ),
        ),
      ],
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(AppStrings.profileLogoutTitle),
        content: const Text(AppStrings.profileLogoutBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(AppStrings.profileLogoutCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text(AppStrings.profileLogoutConfirm),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    final done = await _safeSignOut();
    if (!context.mounted) return;
    if (!done) {
      // Profil adalah konten tab tanpa Scaffold sendiri: kegagalan
      // ditampilkan sebagai dialog, bukan snackbar (tidak ada Scaffold
      // untuk present).
      await showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text(AppStrings.profileLogoutTitle),
          content: const Text(AppStrings.profileLogoutFailed),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(AppStrings.profileAboutClose),
            ),
          ],
        ),
      );
      return;
    }
    ref.invalidate(historyUserIdProvider);
    ref.invalidate(scoreProvider);
    ref.invalidate(apiKeyControllerProvider);
  }
}

/// Satu baris menu: ikon tint + judul + sublabel + chevron.
///
/// Bahasa baris konsisten (bukan kartu per baris): divider hairline antar
/// baris, chevron netral, baris destruktif memakai warna danger untuk
/// ikon + judul. Tap milik InkWell penuh baris (48px+ target sentuh).
class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.last = false,
    this.destructive = false,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final bool last;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final color = destructive ? AppColors.danger : AppColors.primary;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.vertical(
              top: last ? Radius.zero : const Radius.circular(20),
              bottom: last ? const Radius.circular(20) : Radius.zero,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(13),
                      color: color.withValues(alpha: 0.1),
                    ),
                    child: Icon(icon, size: 19, color: color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: destructive
                                ? AppColors.danger
                                : AppColors.textPrimary,
                          ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            subtitle!,
                            style: const TextStyle(
                              fontSize: 12,
                              height: 1.5,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 22,
                    color: AppColors.neutral,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (!last) const Divider(height: 1, color: AppColors.hairline),
      ],
    );
  }
}

/// Error card informatif bila stream skor gagal: dengan tombol coba lagi.
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
              side: BorderSide(color: AppColors.primary.withValues(alpha: 0.4)),
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
