import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../quick_check/presentation/widgets/session_back_button.dart';
import '../providers/learn_providers.dart';
import 'quiz_screen.dart';

/// Artikel modul — 4 seksi bernomor + CTA kuis + klaim selesai.
///
/// Ilustrasi tiap seksi memakai medallion ikon berbeda (bukan gambar sama)
/// agar ritme baca tidak monoton. Klaim +20 idempoten via repository.
class CourseDetailScreen extends ConsumerStatefulWidget {
  const CourseDetailScreen({super.key, required this.moduleId});

  final String moduleId;

  @override
  ConsumerState<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends ConsumerState<CourseDetailScreen> {
  bool _claiming = false;

  static const _sectionIcons = [
    Icons.visibility_outlined,
    Icons.timer_outlined,
    Icons.psychology_outlined,
    Icons.fitness_center_outlined,
  ];

  Future<void> _claim() async {
    if (_claiming) return;
    setState(() => _claiming = true);
    final ok = await ref
        .read(learnActionProvider.notifier)
        .completeModule(widget.moduleId);
    if (!mounted) return;
    setState(() => _claiming = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? AppStrings.learnMarkedDone
              : 'Modul sudah diklaim sebelumnya.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _openQuiz() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => QuizScreen(moduleId: widget.moduleId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final module = ref
        .watch(learnContentProvider)
        .where((m) => m.id == widget.moduleId)
        .firstOrNull;
    if (module == null) {
      return Scaffold(
        appBar: AppBar(title: const Text(AppStrings.learnQuizBack)),
        body: const Center(child: Text('Modul tidak ditemukan.')),
      );
    }
    final progress = ref.watch(learnProgressProvider).valueOrNull;
    final done = progress?.isCompleted(module.id) ?? false;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 64,
        leadingWidth: 56,
        leading: SessionBackButton(
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(module.title),
        centerTitle: false,
        titleTextStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.2,
          color: AppColors.textPrimary,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: AppColors.neutral.withValues(alpha: 0.2),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        color: AppColors.primary.withValues(alpha: 0.08),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.22),
                        ),
                      ),
                      child: Text(
                        '${module.minutes} mnt baca',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (done)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          color: AppColors.success.withValues(alpha: 0.1),
                          border: Border.all(
                            color: AppColors.success.withValues(alpha: 0.35),
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle_rounded,
                              size: 13,
                              color: AppColors.success,
                            ),
                            SizedBox(width: 5),
                            Text(
                              AppStrings.learnModuleDone,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: AppColors.success,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  module.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  module.subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 18),
                for (var i = 0; i < module.sections.length; i++) ...[
                  if (i > 0) const SizedBox(height: 14),
                  _ArticleSection(
                    number: i + 1,
                    icon: _sectionIcons[i % _sectionIcons.length],
                    heading: module.sections[i].heading,
                    body: module.sections[i].body,
                  ),
                ],
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: OutlinedButton.icon(
                          onPressed: _claiming ? null : _claim,
                          icon: _claiming
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                  ),
                                )
                              : const Icon(
                                  Icons.emoji_events_outlined,
                                  size: 19,
                                ),
                          label: const Text(AppStrings.learnMarkDone),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: BorderSide(
                              color: AppColors.primary.withValues(alpha: 0.4),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: FilledButton.icon(
                          onPressed: _openQuiz,
                          icon: const Icon(Icons.quiz_outlined, size: 19),
                          label: const Text(AppStrings.learnStartQuiz),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
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

class _ArticleSection extends StatelessWidget {
  const _ArticleSection({
    required this.number,
    required this.icon,
    required this.heading,
    required this.body,
  });

  final int number;
  final IconData icon;
  final String heading;
  final String body;

  @override
  Widget build(BuildContext context) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(13),
                  color: AppColors.primary.withValues(alpha: 0.09),
                ),
                child: Icon(icon, size: 19, color: AppColors.primary),
              ),
              const SizedBox(width: 10),
              Text(
                'Bagian $number',
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: AppColors.primary,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            heading,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: const TextStyle(
              fontSize: 14,
              height: 1.7,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
