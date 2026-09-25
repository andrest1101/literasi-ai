import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../score/presentation/screens/api_key_screen.dart';
import '../../../score/presentation/widgets/score_check_chip.dart';
import '../../../trending/domain/entities/trending_item.dart';
import '../../../trending/presentation/providers/trending_providers.dart';
import '../../../trending/presentation/screens/trending_detail_screen.dart';
import '../../../trending/presentation/widgets/trending_rail.dart';
import 'quick_check_session_screen.dart';

/// Landing tab Quick Check — hero CTA + mode picker + contoh + tips.
///
/// Komposisi sengaja dibuat heterogen agar tidak monoton:
/// hero gradien penuh, mode picker 2 tile berdampingan, contoh berupa
/// carousel horizontal sekali ketuk, dan tips sebagai bullet list ringan.
/// Tidak ada kartu vertikal bertumpuk yang mengulang pola sama.
class QuickCheckHomeTab extends ConsumerWidget {
  const QuickCheckHomeTab({super.key, this.onOpenProfile});

  final VoidCallback? onOpenProfile;

  void _openSession(
    BuildContext context, {
    QuickCheckInitialMode mode = QuickCheckInitialMode.text,
    String? claim,
  }) {
    // Umpan balik taktil ringan pada aksi primer — pola sama dengan
    // onboarding & navbar (HapticFeedback bawaan, tanpa plugin).
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            QuickCheckSessionScreen(initialMode: mode, initialClaim: claim),
        settings: const RouteSettings(name: QuickCheckSessionScreen.route),
      ),
    );
  }

  void _openKeySettings(BuildContext context) {
    Navigator.of(context).pushNamed(ApiKeyScreen.route);
  }

  void _openTrending(BuildContext context, TrendingItem item) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => TrendingDetailScreen(item: item)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      // Padding bawah 120px: pill navbar (68 + margin 12 + badge 28) +
      // FAB Chat 60px yang duduk 32px di atas navbar.
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _CheckHeading(),
              const SizedBox(height: 12),
              ScoreCheckChip(
                onOpenProfile: onOpenProfile,
                onOpenKeySettings: () => _openKeySettings(context),
              ),
              const SizedBox(height: 18),
              const _HeroEntrance(child: _SessionCtaCard()),
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
                      tint: AppColors.primary,
                      onTap: () => _openSession(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ModeTile(
                      icon: Icons.image_outlined,
                      title: AppStrings.quickCheckTileImageTitle,
                      subtitle: AppStrings.quickCheckTileImageSubtitle,
                      tint: AppColors.primaryDeep,
                      onTap: () => _openSession(
                        context,
                        mode: QuickCheckInitialMode.image,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _UrlModeBanner(
                onTap: () =>
                    _openSession(context, mode: QuickCheckInitialMode.url),
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
              const _SectionHeader(
                title: AppStrings.trendingTitle,
                subtitle: AppStrings.trendingSubtitle,
              ),
              const SizedBox(height: 12),
              _TrendingSection(onPick: (item) => _openTrending(context, item)),
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

/// Section trending di tab Cek — rail horizontal + navigasi detail.
///
/// Provider sync lokal sehingga guest offline tetap melihat feed penuh.
class _TrendingSection extends ConsumerWidget {
  const _TrendingSection({required this.onPick});

  final ValueChanged<TrendingItem> onPick;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TrendingRail(
      items: ref.watch(trendingItemsProvider),
      onPick: onPick,
    );
  }
}

/// Heading compact tab Cek — judul two-tone + subtitle 2 baris + hairline.
///
/// Menggantikan header editorial penuh (wordmark + pill eyebrow + judul
/// 26px + subtitle 3 baris) yang memakan ±230px sebelum konten. Pill
/// "VERIFIKASI AI" dihapus karena redundan dengan label "AI live" di
/// kartu status; wordmark dihapus karena brand sudah ada di navbar.
/// Judul 24px tetap two-tone sebagai identitas; hairline dipertahankan
/// sebagai jangkar visual.
class _CheckHeading extends StatelessWidget {
  const _CheckHeading();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.homeCheckTitle1,
          style: const TextStyle(
            fontSize: 24,
            height: 1.15,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            color: AppColors.textPrimary,
          ),
        ),
        const Text(
          AppStrings.homeCheckTitle2,
          style: TextStyle(
            fontSize: 24,
            height: 1.15,
            fontWeight: FontWeight.w800,
            fontStyle: FontStyle.italic,
            letterSpacing: -0.5,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          AppStrings.homeCheckSubtitle,
          style: TextStyle(
            fontSize: 13,
            height: 1.55,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 1,
          color: AppColors.neutral.withValues(alpha: 0.18),
        ),
      ],
    );
  }
}

/// Entrance hero — fade + slide halus sekali saat tab pertama dibuka.
///
/// Terisolasi di widget sendiri agar animasi tidak me-rebuild seluruh tab.
/// Durasi 380ms ease-out: terasa hidup tanpa mengganggu. Tanpa loop agar
/// calm sesuai aturan anti-AI-slop.
class _HeroEntrance extends StatefulWidget {
  const _HeroEntrance({required this.child});

  final Widget child;

  @override
  State<_HeroEntrance> createState() => _HeroEntranceState();
}

class _HeroEntranceState extends State<_HeroEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 380),
  );
  late final Animation<double> _fade = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
  );
  late final Animation<Offset> _slide =
      Tween<Offset>(
        begin: const Offset(0, 0.06),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );

  @override
  void initState() {
    super.initState();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
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
          colors: [AppColors.heroBegin, AppColors.heroEnd],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.32),
            blurRadius: 26,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        children: [
          const Positioned.fill(child: ExcludeSemantics(child: _HeroPattern())),
          LayoutBuilder(
            builder: (context, constraints) {
              final narrow = constraints.maxWidth < 380;
              final copy = const Column(
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
              );
              final cta = SizedBox(
                height: 52,
                width: narrow ? double.infinity : null,
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          AppStrings.quickCheckStartSession,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(width: 6),
                      Icon(Icons.arrow_forward_rounded, size: 19),
                    ],
                  ),
                ),
              );
              // Layar sempit (<380px): tombol full-width di bawah teks agar
              // kata terpanjang tidak terjepit hingga overflow; layar normal
              // tetap Row berdampingan.
              if (narrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [copy, const SizedBox(height: 12), cta],
                );
              }
              return Row(
                children: [
                  Expanded(child: copy),
                  const SizedBox(width: 14),
                  cta,
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Tekstur pola hero — garis diagonal + outline perisai raksasa.
///
/// Digambar via CustomPainter murni (tanpa aset gambar/emoji) dengan putih
/// alpha 6-8% di atas gradient hero, sehingga memberi kedalaman tanpa
/// mengganggu keterbacaan teks. `ExcludeSemantics` di callsite karena
/// murni dekoratif.
class _HeroPattern extends StatelessWidget {
  const _HeroPattern();

  @override
  Widget build(BuildContext context) {
    return const CustomPaint(painter: _HeroPatternPainter());
  }
}

class _HeroPatternPainter extends CustomPainter {
  const _HeroPatternPainter();

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    // Garis diagonal halus dari kiri-bawah ke kanan-atas.
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.07)
      ..strokeWidth = 1.2;
    const step = 26.0;
    for (var x = -size.height; x < size.width + size.height; x += step) {
      canvas.drawLine(
        Offset(x, size.height + 4),
        Offset(x + size.height + 8, -4),
        linePaint,
      );
    }
    // Outline perisai raksasa di kanan — echo ikon verified brand.
    final shieldPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    final center = Offset(size.width - 34, size.height / 2);
    const radius = 64.0;
    final shield = Path()
      ..moveTo(center.dx, center.dy - radius)
      ..lineTo(center.dx + radius * 0.78, center.dy - radius * 0.42)
      ..lineTo(center.dx + radius * 0.78, center.dy + radius * 0.18)
      ..quadraticBezierTo(
        center.dx + radius * 0.78,
        center.dy + radius * 0.72,
        center.dx,
        center.dy + radius,
      )
      ..quadraticBezierTo(
        center.dx - radius * 0.78,
        center.dy + radius * 0.72,
        center.dx - radius * 0.78,
        center.dy + radius * 0.18,
      )
      ..lineTo(center.dx - radius * 0.78, center.dy - radius * 0.42)
      ..close();
    canvas.drawPath(shield, shieldPaint);
    // Kilau pusat perisai: check samar sebagai penegas makna.
    final checkPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(
      Path()
        ..moveTo(center.dx - 22, center.dy + 2)
        ..lineTo(center.dx - 6, center.dy + 18)
        ..lineTo(center.dx + 24, center.dy - 18),
      checkPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
    this.tint = AppColors.primary,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  /// Warna identitas mode — teks biru brand, gambar biru-tua, agar tiap
  /// mode punya karakter tanpa warna asing. Default biru untuk kompatibel
  /// mundur.
  final Color tint;

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
                        color: tint.withValues(alpha: 0.1),
                      ),
                      child: Icon(icon, size: 23, color: tint),
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

/// Banner mode link — full-width horizontal di bawah 2 tile berdampingan.
///
/// Ritme landing tetap heterogen: hero CTA penuh, 2 tile persegi, banner
/// link horizontal, lalu carousel contoh. Ikon link + aksen hijau
/// memberi identitas "artikel/web" yang beda dari tile Teks/Gambar.
class _UrlModeBanner extends StatelessWidget {
  const _UrlModeBanner({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: AppStrings.quickCheckTileUrlTitle,
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: AppColors.success.withValues(alpha: 0.3),
              ),
              color: AppColors.success.withValues(alpha: 0.05),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0D101A33),
                  blurRadius: 16,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: AppColors.success.withValues(alpha: 0.12),
                  ),
                  child: const Icon(
                    Icons.link_rounded,
                    size: 23,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.quickCheckTileUrlTitle,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        AppStrings.quickCheckTileUrlSubtitle,
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 22,
                  color: AppColors.textSecondary,
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
    AppStrings.quickCheckExample4,
    AppStrings.quickCheckExample5,
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
            child: _ExampleCard(claim: claim, onTap: () => onPick(claim)),
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
