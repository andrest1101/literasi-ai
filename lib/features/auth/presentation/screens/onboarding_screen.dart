import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/onboarding_slide.dart';
import '../widgets/pill_page_indicator.dart';
import 'auth_screen.dart';

/// Onboarding 3 slide: tampil saat pertama install (PRD §5).
///
/// Gaya modern & clean: header brand + Lewati, kartu visual floating
/// interaktif (press-glow), eyebrow + judul tebal + deskripsi,
/// pill indicator, nav [Back | Next/Get Started].
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  static const route = '/onboarding';

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;
  bool _finishing = false;

  static const _slides = [
    (
      AppStrings.onboardingEyebrow1,
      AppStrings.onboardingTitle1,
      AppStrings.onboardingDesc1,
    ),
    (
      AppStrings.onboardingEyebrow2,
      AppStrings.onboardingTitle2,
      AppStrings.onboardingDesc2,
    ),
    (
      AppStrings.onboardingEyebrow3,
      AppStrings.onboardingTitle3,
      AppStrings.onboardingDesc3,
    ),
  ];

  bool get _isLast => _page == _slides.length - 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goTo(int page) {
    HapticFeedback.selectionClick();
    _controller.animateToPage(
      page,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOutCubic,
    );
  }

  void _next() {
    HapticFeedback.lightImpact();
    if (_isLast) {
      _finish();
    } else {
      _goTo(_page + 1);
    }
  }

  void _back() {
    if (_page > 0) _goTo(_page - 1);
  }

  void _skip() {
    _finish();
  }

  Future<void> _finish() async {
    if (_finishing) return;
    setState(() => _finishing = true);
    try {
      await ref.read(onboardingControllerProvider.notifier).complete();
    } catch (_) {
      // Tetap lanjut ke Auth; splash berikutnya memakai default aman.
    }
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(AuthScreen.route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header: brand + Lewati.
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 16, 0),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(13),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF4B8DF6), AppColors.primary],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.shield_outlined,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    AppStrings.appName,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const Spacer(),
                  AnimatedOpacity(
                    opacity: _isLast ? 0 : 1,
                    duration: const Duration(milliseconds: 250),
                    child: IgnorePointer(
                      ignoring: _isLast,
                      child: TextButton(
                        onPressed: _skip,
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.textSecondary,
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        child: const Text(AppStrings.onboardingSkip),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Slide swipeable.
            Expanded(
              child: PageView.builder(
                controller: _controller,
                physics: const BouncingScrollPhysics(),
                itemCount: _slides.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (context, i) {
                  final (eyebrow, title, desc) = _slides[i];
                  return OnboardingSlide(
                    index: i,
                    eyebrow: eyebrow,
                    title: title,
                    description: desc,
                  );
                },
              ),
            ),
            // Pill indicator.
            PillPageIndicator(count: _slides.length, current: _page),
            const SizedBox(height: 22),
            // Nav bawah: [Back ikon | Next/Get Started].
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Row(
                children: [
                  SizedBox(
                    width: 56,
                    height: 56,
                    child: AnimatedOpacity(
                      opacity: _page > 0 ? 1 : 0,
                      duration: const Duration(milliseconds: 250),
                      child: IgnorePointer(
                        ignoring: _page == 0,
                        child: Semantics(
                          button: true,
                          label: AppStrings.onboardingBack,
                          child: OutlinedButton(
                            onPressed: _back,
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              shape: const CircleBorder(),
                              backgroundColor: AppColors.surface,
                              side: BorderSide(
                                color: AppColors.neutral.withValues(
                                  alpha: 0.35,
                                ),
                              ),
                              foregroundColor: AppColors.textPrimary,
                            ),
                            child: const Icon(Icons.arrow_back_rounded),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Semantics(
                      button: true,
                      label: _isLast
                          ? AppStrings.onboardingStart
                          : AppStrings.onboardingNext,
                      child: FilledButton(
                        onPressed: _next,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.1,
                          ),
                          elevation: 6,
                          shadowColor: AppColors.primary.withValues(
                            alpha: 0.45,
                          ),
                        ),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          transitionBuilder: (child, anim) => FadeTransition(
                            opacity: anim,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, 0.3),
                                end: Offset.zero,
                              ).animate(anim),
                              child: child,
                            ),
                          ),
                          child: _isLast
                              ? const Row(
                                  key: ValueKey('start'),
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(AppStrings.onboardingStart),
                                    SizedBox(width: 8),
                                    Icon(
                                      Icons.rocket_launch_outlined,
                                      size: 20,
                                    ),
                                  ],
                                )
                              : const Row(
                                  key: ValueKey('next'),
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(AppStrings.onboardingNext),
                                    SizedBox(width: 8),
                                    Icon(Icons.arrow_forward_rounded, size: 20),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
