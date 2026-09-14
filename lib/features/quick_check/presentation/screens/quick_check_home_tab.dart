import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../shared/widgets/app_section_header.dart';
import 'quick_check_session_screen.dart';

/// Landing tab Quick Check — hero CTA + mode picker + contoh + tips.
///
/// Komposisi sengaja dibuat heterogen agar tidak monoton:
/// hero gradien penuh, mode picker 2 tile berdampingan, contoh berupa
/// carousel horizontal sekali ketuk, dan tips sebagai bullet list ringan.
/// Tidak ada kartu vertikal bertumpuk yang mengulang pola sama.
class QuickCheckHomeTab extends StatelessWidget {
  const QuickCheckHomeTab({super.key});

  void _openSession(
    BuildContext context, {
    QuickCheckInitialMode mode = QuickCheckInitialMode.text,
    String? claim,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            QuickCheckSessionScreen(initialMode: mode, initialClaim: claim),
        settings: const RouteSettings(name: QuickCheckSessionScreen.route),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      // Padding bawah 96px memberi ruang bagi FAB Chat 60px + gap 16px agar
      // tips terakhir tidak tertutup tombol mengambang di Home.
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 96),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _Wordmark(),
              const SizedBox(height: 14),
              const AppSectionHeader(
                eyebrow: AppStrings.homeCheckEyebrow,
                titleLine1: AppStrings.homeCheckTitle1,
                titleLine2: AppStrings.homeCheckTitle2,
                subtitle: AppStrings.homeCheckSubtitle,
              ),
              const SizedBox(height: 18),
              const _SessionCtaCard(),
              const SizedBox(height: 22),
              const _SectionHeader(
                title: AppStrings.quickCheckModePickerTitle,
                subtitle: AppStrings.quickCheckModePickerSubtitle,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _ModeTile(
                      icon: Icons.text_snippet_outlined,
                      title: AppStrings.quickCheckTileTextTitle,
                      subtitle: AppStrings.quickCheckTileTextSubtitle,
                      onTap: () => _openSession(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ModeTile(
                      icon: Icons.image_outlined,
                      title: AppStrings.quickCheckTileImageTitle,
                      subtitle: AppStrings.quickCheckTileImageSubtitle,
                      onTap: () => _openSession(
                        context,
                        mode: QuickCheckInitialMode.image,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              const _SectionHeader(
                title: AppStrings.quickCheckExampleTitle,
                subtitle: AppStrings.quickCheckExampleSubtitle,
              ),
              const SizedBox(height: 12),
              _ExampleRail(
                onPick: (claim) => _openSession(context, claim: claim),
              ),
              const SizedBox(height: 22),
              const Text(
                AppStrings.quickCheckTipsTitle,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              const _TipLine(text: AppStrings.quickCheckTip1),
              const SizedBox(height: 8),
              const _TipLine(text: AppStrings.quickCheckTip2),
              const SizedBox(height: 8),
              const _TipLine(text: AppStrings.quickCheckTip3),
            ],
          ),
        ),
      ),
    );
  }
}

/// CTA sesi ringkas — hero besar dihapus karena judul editorial sudah dipegang
/// [AppSectionHeader]. Kartu ini fokus satu tugas: masuk sesi pemeriksaan.
/// Wordmark kecil khusus tab Cek — satu-satunya tempat nama app muncul di
/// Home. Tab lain memakai judul kontekstualnya sendiri.
class _Wordmark extends StatelessWidget {
  const _Wordmark();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.verified_user_rounded,
          size: 18,
          color: AppColors.textSecondary,
        ),
        SizedBox(width: 7),
        Text(
          AppStrings.appName,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _SessionCtaCard extends StatelessWidget {
  const _SessionCtaCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2F80ED), Color(0xFF124A9B)],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x331558B0),
            blurRadius: 26,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.quickCheckCtaTitle,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  AppStrings.quickCheckCtaSubtitle,
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.6,
                    color: Color(0xFFD6E5FE),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          SizedBox(
            height: 52,
            child: FilledButton(
              onPressed: () => Navigator.of(
                context,
              ).pushNamed(QuickCheckSessionScreen.route),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(17),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 18),
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
                elevation: 0,
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(AppStrings.quickCheckStartSession),
                  SizedBox(width: 6),
                  Icon(Icons.arrow_forward_rounded, size: 19),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 12.5,
            height: 1.55,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

/// Tile mode persegi — medallion ikon di atas, judul, sub, chevron.
///
/// Proporsi tile (setengah lebar layar) sengaja berbeda dari hero penuh dan
/// carousel horizontal agar ritme landing tidak monoton.
class _ModeTile extends StatelessWidget {
  const _ModeTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: title,
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 14, 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: AppColors.primary.withValues(alpha: 0.1),
                      ),
                      child: Icon(
                        icon,
                        size: 23,
                        color: AppColors.primary,
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 22,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Carousel contoh klaim — kartu compact horizontal sekali ketuk.
///
/// Format rail (bukan list vertikal) memberi jeda visual dari hero dan tile,
/// sekaligus mempercepat demo 60 detik: ketuk contoh langsung mengisi sesi.
class _ExampleRail extends StatelessWidget {
  const _ExampleRail({required this.onPick});

  final ValueChanged<String> onPick;

  static const _examples = [
    AppStrings.quickCheckExample1,
    AppStrings.quickCheckExample2,
    AppStrings.quickCheckExample3,
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 148,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _examples.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final claim = _examples[index];
          return SizedBox(
            width: 248,
            child: _ExampleCard(
              claim: claim,
              onTap: () => onPick(claim),
            ),
          );
        },
      ),
    );
  }
}

class _ExampleCard extends StatelessWidget {
  const _ExampleCard({required this.claim, required this.onTap});

  final String claim;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Coba contoh pemeriksaan',
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.22),
              ),
              color: AppColors.primary.withValues(alpha: 0.04),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '"',
                  style: TextStyle(
                    fontSize: 22,
                    height: 1,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
                Expanded(
                  child: Text(
                    claim,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12.5,
                      height: 1.55,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: const [
                    Text(
                      AppStrings.quickCheckExampleCta,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 16,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TipLine extends StatelessWidget {
  const _TipLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 7),
          child: Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              height: 1.6,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
