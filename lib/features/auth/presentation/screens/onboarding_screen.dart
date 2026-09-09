import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import 'auth_screen.dart';

/// Onboarding 3 screen — hanya tampil saat pertama install (PRD §5).
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  static const route = '/onboarding';

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  static const _pages = [
    (Icons.fact_check_outlined, AppStrings.onboardingTitle1,
        AppStrings.onboardingDesc1),
    (Icons.chat_bubble_outline, AppStrings.onboardingTitle2,
        AppStrings.onboardingDesc2),
    (Icons.share_outlined, AppStrings.onboardingTitle3,
        AppStrings.onboardingDesc3),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_page < _pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.of(context).pushReplacementNamed(AuthScreen.route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (context, i) {
                  final (icon, title, desc) = _pages[i];
                  return Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(icon,
                            size: 96,
                            color: Theme.of(context).colorScheme.primary),
                        const SizedBox(height: 24),
                        Text(title,
                            style: Theme.of(context).textTheme.headlineSmall,
                            textAlign: TextAlign.center),
                        const SizedBox(height: 12),
                        Text(desc,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (i) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _page == i ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _page == i
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _next,
                  child: Text(
                      _page == _pages.length - 1 ? 'Mulai' : 'Lanjut'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
