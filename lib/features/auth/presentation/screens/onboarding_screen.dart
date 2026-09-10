import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../widgets/onboarding_slide.dart';
import '../widgets/pill_page_indicator.dart';
import 'auth_screen.dart';

/// Onboarding 3 slide — tampil saat pertama install (PRD §5).
///
/// Gaya modern & clean: header brand + Lewati, kartu visual floating,
/// judul tebal + deskripsi, pill indicator, nav [Back | Next/Get Started].
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  static const route = '/onboarding';

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  static const _slides = [
    (AppStrings.onboardingTitle1, AppStrings.onboardingDesc1),
    (AppStrings.onboardingTitle2, AppStrings.onboardingDesc2),
    (AppStrings.onboardingTitle3, AppStrings.onboardingDesc3),
  ];

  bool get _isLast => _page == _slides.length - 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goTo(int page) {
    _controller.animateToPage(
      page,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOutCubic,
    );
  }

  void _next() {
    if (_isLast) {
      Navigator.of(context).pushReplacementNamed(AuthScreen.route);
    } else {
      _goTo(_page + 1);
    }
  }

  void _back() {
    if (_page > 0) _goTo(_page - 1);
  }

  void _skip() {
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
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: AppColors.primary.withValues(alpha: 0.12),
                    ),
                    child: const Icon(
                      Icons.shield_outlined,
                      size: 20,
                      color: AppColors.primary,
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
                  final (title, desc) = _slides[i];
                  return OnboardingSlide(
                    index: i,
                    title: title,
                    description: desc,
                  );
                },
              ),
            ),
            // Pill indicator.
            PillPageIndicator(count: _slides.length, current: _page),
            const SizedBox(height: 24),
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
                        child: OutlinedButton(
                          onPressed: _back,
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            shape: const CircleBorder(),
                            side: BorderSide(
                              color: AppColors.neutral.withValues(alpha: 0.4),
                            ),
                            foregroundColor: AppColors.textPrimary,
                          ),
                          child: const Icon(Icons.arrow_back_rounded),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
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
                        ),
                        elevation: 4,
                        shadowColor:
                            AppColors.primary.withValues(alpha: 0.4),
                      ),
                      child: _isLast
                          ? const Text(AppStrings.onboardingStart)
                          : const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(AppStrings.onboardingNext),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward_rounded, size: 20),
                              ],
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
