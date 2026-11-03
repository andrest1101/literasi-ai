import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_styles.dart';
import '../../../../core/utils/api_key_resolver.dart';
import '../../../../shared/widgets/app_medallion_dialog.dart';
import '../../../auth/presentation/screens/auth_screen.dart';
import '../../../auth/presentation/providers/auth_controller.dart';
import '../../../history/presentation/providers/history_providers.dart';
import '../providers/score_providers.dart';
import '../widgets/score_breakdown.dart';
import '../widgets/score_ring.dart';
import 'api_key_screen.dart';

/// Status sinkronisasi yang ditampilkan ke pengguna.
enum _ProfileSyncState {
  /// Tanpa akun: tidak ada yang disinkronkan.
  guest,

  /// Akun ada, snapshot skor belum tiba.
  syncing,

  /// Akun ada, pembaruan skor gagal.
  offline,

  /// Akun ada dan snapshot skor tersedia.
  synced,
}

/// Tab Profil: identitas + skor + menu pengaturan.
///
/// Tiga permukaan saja, tanpa kartu di dalam kartu:
/// 1. kartu identitas (avatar + nama/email + satu pill status; CTA masuk
///    hanya untuk tamu),
/// 2. satu hero gradien skor ([ScoreRing] + strip [ScoreBreakdown] di dalam
///    permukaan yang sama),
/// 3. satu grup pengaturan (kunci API, Tentang, dan Keluar sebagai baris
///    terakhir bagi pengguna login).
///
/// Status sinkron jujur terhadap stream skor: `Menyinkronkan…` saat menunggu,
/// `Offline` saat gagal, `Tersinkron` hanya ketika data benar-benar ada.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final score = ref.watch(scoreProvider);
    final scoreValue = score.valueOrNull;
    final userId = ref.watch(historyUserIdProvider);
    void retry() => ref.invalidate(scoreProvider);
    final syncState = userId == null
        ? _ProfileSyncState.guest
        : score.hasError
        ? _ProfileSyncState.offline
        : scoreValue != null
        ? _ProfileSyncState.synced
        : _ProfileSyncState.syncing;
    return SingleChildScrollView(
      // FAB Chat tidak tampil di tab ini, jadi tidak perlu zona kosong 120px.
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _ProfileHeading(),
              const SizedBox(height: AppTabTitles.titleToContentGap),
              _IdentityCard(syncState: syncState),
              const SizedBox(height: 14),
              // Skor terakhir tetap tampil saat refresh gagal: poin yang sudah
              // dikumpulkan tidak boleh "hilang" hanya karena stream diam atau
              // koneksi putus sesaat.
              if (scoreValue == null)
                score.isLoading
                    ? const _ScoreShimmer()
                    : _ScoreError(onRetry: retry)
              else ...[
                ScoreRing(
                  score: scoreValue,
                  footer: ScoreBreakdown(score: scoreValue, onHero: true),
                ),
                if (score.hasError) ...[
                  const SizedBox(height: 10),
                  _ScoreStaleStrip(onRetry: retry),
                ],
              ],
              const SizedBox(height: 18),
              _SettingsGroup(synced: userId != null),
            ],
          ),
        ),
      ),
    );
  }
}

/// Strip peringatan ringan saat skor terakhir masih ditampilkan tetapi
/// pembaruannya gagal.
class _ScoreStaleStrip extends StatelessWidget {
  const _ScoreStaleStrip({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppColors.warning.withValues(alpha: 0.1),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            size: 16,
            color: AppColors.warningDark,
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              AppStrings.scoreStale,
              style: TextStyle(
                fontSize: 12,
                height: 1.4,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: onRetry,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: const Size(0, 32),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              AppStrings.retry,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
        ],
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

/// Nama tampilan jujur dari data yang ada: displayName Firebase bila
/// diisi (Google Sign-In), prefix email bila tidak, label tamu bila
/// tanpa akun. Fungsi murni agar teruji unit (jalur login tak terjangkau
/// widget test tanpa Firebase init). Tanpa klaim nama yang tidak dimiliki
/// data.
String resolveProfileName(String? displayName, String? email) {
  if (displayName != null && displayName.trim().isNotEmpty) {
    return displayName.trim();
  }
  if (email != null && email.isNotEmpty) {
    return email.trim().split('@').first;
  }
  return AppStrings.scoreGuestLabel;
}

/// Keluar aman-test: tanpa Firebase init mengembalikan false (gagal
/// ramah), agar widget test tidak crash. Sukses mengembalikan true.
Future<bool> _safeSignOut(WidgetRef ref) async {
  try {
    await ref.read(authControllerProvider.notifier).signOut();
    return true;
  } catch (_) {
    return false;
  }
}

/// Heading compact tab Profil: judul two-tone 20px + 1 baris cara skor
/// bertambah. Ring di bawahnya adalah konten utama tab ini, bukan dekorasi.
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

/// Kartu identitas: avatar + nama/email + satu pill status.
///
/// Tamu memakai ikon person netral sebagai placeholder akun yang jelas.
/// Pengguna login memakai inisial email/nama. CTA Masuk hanya bagi tamu.
/// Level tidak diulang di sini: level sudah menjadi bagian hero skor.
class _IdentityCard extends ConsumerWidget {
  const _IdentityCard({required this.syncState});

  final _ProfileSyncState syncState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(historyUserIdProvider) != null ? _safeUser() : null;
    final email = user?.email;
    final displayName = user?.displayName;
    final hasEmail = email != null && email.isNotEmpty;
    final resolvedName = resolveProfileName(displayName, email);
    // UID ada tetapi data profil belum terbaca (mis. sesi dipulihkan):
    // jangan tampilkan "Tamu" di sebelah pill "Tersinkron".
    final shownName =
        syncState != _ProfileSyncState.guest &&
            resolvedName == AppStrings.scoreGuestLabel
        ? AppStrings.profileAccountFallback
        : resolvedName;
    final initial = hasEmail
        ? email.trim()[0].toUpperCase()
        : (displayName != null && displayName.trim().isNotEmpty)
        ? displayName.trim()[0].toUpperCase()
        : null;
    final isGuest = syncState == _ProfileSyncState.guest;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.card),
        color: AppColors.surface,
        border: Border.all(color: AppColors.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.heroBegin, AppColors.heroEnd],
                  ),
                ),
                child: Center(
                  child: initial != null
                      ? Text(
                          initial,
                          style: const TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons.person_outline_rounded,
                          size: 28,
                          color: Colors.white,
                        ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      shownName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 17.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (hasEmail) ...[
                      const SizedBox(height: 2),
                      Text(
                        email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                    const SizedBox(height: 9),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: _StatusPill(state: syncState),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (isGuest) ...[
            const SizedBox(height: 14),
            const Divider(height: 1, color: AppColors.hairline),
            const SizedBox(height: 12),
            const Text(
              AppStrings.scoreAnonymousNote,
              style: TextStyle(
                fontSize: 12.5,
                height: 1.55,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 46,
              child: FilledButton.icon(
                onPressed: () =>
                    Navigator.of(context).pushNamed(AuthScreen.route),
                icon: const Icon(Icons.login_rounded, size: 18),
                label: const Text(AppStrings.scoreLoginCta),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Satu pill status sinkron: ikon + teks, warna mengikuti keadaan.
class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.state});

  final _ProfileSyncState state;

  @override
  Widget build(BuildContext context) {
    final (icon, text, color) = switch (state) {
      _ProfileSyncState.guest => (
        Icons.badge_outlined,
        AppStrings.profileGuestPill,
        AppColors.textSecondary,
      ),
      _ProfileSyncState.syncing => (
        Icons.cloud_sync_outlined,
        AppStrings.profileSyncingLabel,
        AppColors.primary,
      ),
      _ProfileSyncState.offline => (
        Icons.cloud_off_outlined,
        AppStrings.profileOfflineLabel,
        AppColors.warningDark,
      ),
      _ProfileSyncState.synced => (
        Icons.cloud_done_outlined,
        AppStrings.profileSyncedLabel,
        AppColors.successDark,
      ),
    };
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
          Text(
            text,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
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
              borderRadius: BorderRadius.circular(AppRadii.hero),
              color: AppColors.surface,
              border: Border.all(color: AppColors.hairline),
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

/// Grup pengaturan: satu permukaan putih tanpa bayangan.
///
/// Kunci API (navigasi ke layar pengaturan yang sudah ada), Tentang (dialog
/// versi, bukan layar baru), dan Keluar sebagai baris terakhir hanya bila
/// pengguna login. Tamu tidak melihat baris keluar: tidak ada sesi Firebase
/// yang bisa dibersihkan. Tanpa password/notifikasi/dark-mode palsu.
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
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            AppStrings.profileMenuTitle,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.3,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.card),
            color: AppColors.surface,
            border: Border.all(color: AppColors.hairline),
          ),
          child: Material(
            color: Colors.transparent,
            child: Column(
              children: [
                _SettingsRow(
                  icon: Icons.key_outlined,
                  title: AppStrings.profileApiKeyRow,
                  subtitle: keySubtitle,
                  onTap: () =>
                      Navigator.of(context).pushNamed(ApiKeyScreen.route),
                ),
                const _SettingsDivider(),
                _SettingsRow(
                  icon: Icons.info_outline_rounded,
                  title: AppStrings.profileAboutRow,
                  subtitle: null,
                  onTap: () => showDialog<void>(
                    context: context,
                    builder: (_) => AppMedallionDialog(
                      icon: Icons.info_outline_rounded,
                      accent: AppColors.primary,
                      title: AppStrings.profileAboutRow,
                      body: AppStrings.profileAboutBody,
                      primaryLabel: AppStrings.profileAboutClose,
                      onPrimary: () => Navigator.of(context).pop(),
                    ),
                  ),
                ),
                if (synced) ...[
                  const _SettingsDivider(),
                  _SettingsRow(
                    icon: Icons.logout_rounded,
                    title: AppStrings.profileLogoutRow,
                    subtitle: null,
                    destructive: true,
                    onTap: () => _confirmLogout(context, ref),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    HapticFeedback.mediumImpact();
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AppMedallionDialog(
        icon: Icons.logout_rounded,
        accent: AppColors.danger,
        title: AppStrings.profileLogoutTitle,
        body: AppStrings.profileLogoutBody,
        primaryLabel: AppStrings.profileLogoutConfirm,
        primaryDanger: true,
        onPrimary: () => Navigator.of(context).pop(true),
        secondaryLabel: AppStrings.profileLogoutCancel,
        onSecondary: () => Navigator.of(context).pop(false),
      ),
    );
    if (ok != true || !context.mounted) return;
    final done = await _safeSignOut(ref);
    if (!context.mounted) return;
    if (!done) {
      // Profil adalah konten tab tanpa Scaffold sendiri: kegagalan
      // ditampilkan sebagai dialog, bukan snackbar (tidak ada Scaffold
      // untuk present).
      await showDialog<void>(
        context: context,
        builder: (_) => AppMedallionDialog(
          icon: Icons.cloud_off_outlined,
          accent: AppColors.danger,
          title: AppStrings.profileLogoutTitle,
          body: AppStrings.profileLogoutFailed,
          primaryLabel: AppStrings.profileAboutClose,
          onPrimary: () => Navigator.of(context).pop(),
        ),
      );
      return;
    }
    ref.invalidate(historyUserIdProvider);
    ref.invalidate(authControllerProvider);
    ref.invalidate(scoreProvider);
    ref.invalidate(apiKeyControllerProvider);
  }
}

/// Divider antar baris pengaturan, menjorok sejajar judul (setelah ikon).
class _SettingsDivider extends StatelessWidget {
  const _SettingsDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      thickness: 1,
      indent: 66,
      color: AppColors.hairline,
    );
  }
}

/// Satu baris menu: ikon tint + judul + sublabel + chevron.
///
/// Ripple mengikuti bentuk grup ([Material] dengan `clipBehavior`), sehingga
/// sudut baris pertama/terakhir tidak pernah terlihat persegi. Tap memenuhi
/// seluruh baris (target sentuh 48px+).
class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.destructive = false,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final color = destructive ? AppColors.danger : AppColors.primary;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
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
        borderRadius: BorderRadius.circular(AppRadii.hero),
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
              textStyle: const TextStyle(
                fontFamily: AppStyles.fontFamily,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
