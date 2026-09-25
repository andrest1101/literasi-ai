import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';

/// Bottom nav 4 destinasi — pill putih mengambang + badge naik.
///
/// Card putih polos (radius 26, hairline netral, tanpa lekukan, tanpa
/// aksen biru di tepi) — badge lingkaran 48px (44px di layar <380px)
/// gradien biru brand [AppColors.heroBegin] → [AppColors.heroEnd] + ring
/// putih menempel di atas bar, setengah keluar — bahasa visual yang sama
/// dengan [ChatFab] dan hero modul. Badge dan label digerakkan SATU nilai
/// animasi sehingga selalu sinkron tanpa jank. Label aktif tetap di dalam
/// bar dengan warna aksen identitas tiap tab (selaras [SectionAccent]):
/// Cek biru brand, Riwayat biru tua, Belajar hijau, Profil biru sedang.
///
/// Gerakan 480ms [Curves.easeInOutCubicEmphasized] (kurva Material
/// Expressive) memberi kesan meluncur halus antar slot + pop scale
/// 0.85 → 1.0 + [HapticFeedback.selectionClick]. Tanpa [NavigationBar]
/// default agar tidak terlihat standar; API [currentIndex]/[onTap]
/// tidak berubah.
class AppBottomNavBar extends StatefulWidget {
  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _labels = [
    AppStrings.navCheck,
    AppStrings.navHistory,
    AppStrings.navLearn,
    AppStrings.navProfile,
  ];

  static const _tooltips = [
    'Cek fakta',
    'Riwayat verifikasi',
    'Belajar literasi',
    'Profil pengguna',
  ];

  static const _icons = [
    Icons.fact_check_outlined,
    Icons.history_outlined,
    Icons.school_outlined,
    Icons.person_outline,
  ];

  static const _activeIcons = [
    Icons.fact_check_rounded,
    Icons.history_rounded,
    Icons.school_rounded,
    Icons.person_rounded,
  ];

  /// Aksen label aktif per tab — selaras SectionAccent U2.1.
  static const _labelAccents = [
    AppColors.primary,
    AppColors.primaryDeep,
    AppColors.successDark,
    AppColors.primaryDark,
  ];

  static const double _barHeight = 68;

  /// Ruang vertikal badge di atas bar — badge 48px menumpang 28px di atas
  /// tepi bar sehingga duduk pas menempel, bukan melayang. Tinggi total
  /// widget = 68 + 28 = 96.
  static const double _badgeOverhang = 28;
  static const double _sideMargin = 16;
  static const double _bottomMargin = 12;

  /// Posisi pusat slot [index] dalam koordinat bar selebar [barWidth].
  static double slotCenter(double barWidth, int index, int count) {
    final slot = barWidth / count;
    return slot * index + slot / 2;
  }

  /// Kiri badge agar badge terpusat di [centerX].
  static double badgeLeftFor(double centerX, double badgeSize) {
    return centerX - badgeSize / 2;
  }

  @override
  State<AppBottomNavBar> createState() => _AppBottomNavBarState();
}

class _AppBottomNavBarState extends State<AppBottomNavBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _glide;
  late Animation<double> _centerX;

  double? _lastBarWidth;
  double? _lastBadgeSize;

  @override
  void initState() {
    super.initState();
    // Eager di initState (bukan lazy field): akses pertama lazy saat
    // dispose akan membuat Ticker di tree yang sudah nonaktif → crash.
    _glide = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    );
    _centerX = AlwaysStoppedAnimation(_targetCenterX(null));
  }

  double _targetCenterX(double? barWidth) {
    final width = barWidth ?? _lastBarWidth ?? 0;
    if (width <= 0) return 0;
    return AppBottomNavBar.slotCenter(
      width,
      widget.currentIndex,
      AppBottomNavBar._labels.length,
    );
  }

  double _badgeSizeFor(BuildContext context) {
    return MediaQuery.sizeOf(context).width < 380 ? 44.0 : 48.0;
  }

  @override
  void didUpdateWidget(AppBottomNavBar old) {
    super.didUpdateWidget(old);
    if (old.currentIndex == widget.currentIndex) return;
    final from = _centerX.value;
    final to = _targetCenterX(null);
    // Animasi dari posisi saat ini (bukan dari slot lama) agar tap cepat
    // beruntun di tengah jalan tetap mulus, bukan melompat.
    _centerX = Tween<double>(begin: from, end: to).animate(
      CurvedAnimation(parent: _glide, curve: Curves.easeInOutCubicEmphasized),
    );
    _glide
      ..reset()
      ..forward();
  }

  @override
  void dispose() {
    _glide.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final badgeSize = _badgeSizeFor(context);
    return Container(
      color: Colors.transparent,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppBottomNavBar._sideMargin,
            0,
            AppBottomNavBar._sideMargin,
            AppBottomNavBar._bottomMargin,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final barWidth = constraints.maxWidth;
              final firstFrame =
                  _lastBarWidth == null || _lastBadgeSize != badgeSize;
              _lastBarWidth = barWidth;
              _lastBadgeSize = badgeSize;
              if (firstFrame) {
                // Ukur dulu sebelum animasi agar frame pertama presisi.
                _centerX = AlwaysStoppedAnimation(_targetCenterX(barWidth));
              }
              return Semantics(
                label: 'Navigasi utama',
                child: SizedBox(
                  height:
                      AppBottomNavBar._barHeight +
                      AppBottomNavBar._badgeOverhang,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Container(
                          height: AppBottomNavBar._barHeight,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(26),
                            color: AppColors.surface,
                            border: Border.all(
                              color: AppColors.neutral.withValues(alpha: 0.18),
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x14101A33),
                                blurRadius: 18,
                                offset: Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              for (var i = 0;
                                  i < AppBottomNavBar._labels.length;
                                  i++)
                                Expanded(
                                  child: _NavSlot(
                                    index: i,
                                    active: i == widget.currentIndex,
                                    onTap: () {
                                      if (i == widget.currentIndex) return;
                                      HapticFeedback.selectionClick();
                                      widget.onTap(i);
                                    },
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      AnimatedBuilder(
                        animation: _centerX,
                        builder: (context, _) {
                          final left = AppBottomNavBar.badgeLeftFor(
                            _centerX.value,
                            badgeSize,
                          );
                          return Positioned(
                            left: left,
                            top: 0,
                            child: TweenAnimationBuilder<double>(
                              key: ValueKey<int>(widget.currentIndex),
                              tween: Tween(begin: 0.85, end: 1.0),
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeOutCubic,
                              builder: (context, scale, child) {
                                return Transform.scale(
                                  scale: scale,
                                  child: child,
                                );
                              },
                              child: Semantics(
                                selected: true,
                                label:
                                    '${AppBottomNavBar._labels[widget.currentIndex]} aktif',
                                child: Container(
                                  key: const ValueKey('nav-active-badge'),
                                  width: badgeSize,
                                  height: badgeSize,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        AppColors.heroBegin,
                                        AppColors.heroEnd,
                                      ],
                                    ),
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primary.withValues(
                                          alpha: 0.35,
                                        ),
                                        blurRadius: 16,
                                        offset: const Offset(0, 6),
                                      ),
                                      const BoxShadow(
                                        color: Color(0x1A101A33),
                                        blurRadius: 6,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    AppBottomNavBar._activeIcons[widget
                                        .currentIndex],
                                    size: 23,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Satu slot tab — ikon + label di dalam bar.
///
/// Slot aktif menyisakan ruang ikon kosong (ikonnya naik ke badge) agar
/// label tetap sejajar vertikal dengan slot lain, bukan melompat.
class _NavSlot extends StatelessWidget {
  const _NavSlot({
    required this.index,
    required this.active,
    required this.onTap,
  });

  final int index;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = AppBottomNavBar._labelAccents[index];
    return Semantics(
      button: true,
      selected: active,
      label: AppBottomNavBar._labels[index],
      child: Tooltip(
        message: AppBottomNavBar._tooltips[index],
        child: GestureDetector(
          key: ValueKey('nav-tab-$index'),
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (active)
                const SizedBox(height: 24)
              else
                Icon(
                  AppBottomNavBar._icons[index],
                  size: 24,
                  color: AppColors.textSecondary,
                ),
              const SizedBox(height: 3),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: active ? FontWeight.w800 : FontWeight.w700,
                  color: active ? accent : AppColors.textSecondary,
                ),
                child: Text(AppBottomNavBar._labels[index]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
