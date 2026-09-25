import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../quick_check/presentation/widgets/session_back_button.dart';
import '../../domain/entities/quiz_question.dart';
import '../providers/learn_providers.dart';

/// Kuis 3 soal: 1 soal per halaman, terkunci berurutan.
///
/// Pola heterogen vs kartu modul: progress dots atas, kartu soal putih,
/// opsi sebagai radio card berwarna saat dikunci (hijau benar / merah salah
/// + penjelasan), hasil akhir berupa panel skor + klaim poin best-score.
class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({super.key, required this.moduleId});

  final String moduleId;

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  final _pager = PageController();
  int _index = 0;
  int? _selected;
  bool _locked = false;
  final _answers = <int>[];
  bool _finished = false;
  int _claimed = 0;
  bool _claiming = false;

  @override
  void dispose() {
    _pager.dispose();
    super.dispose();
  }

  void _choose(int option) {
    if (_locked || _finished) return;
    setState(() {
      _selected = option;
      _locked = true;
    });
  }

  void _next(int total) {
    if (!_locked) return;
    _answers.add(_selected ?? -1);
    if (_index >= total - 1) {
      setState(() => _finished = true);
      return;
    }
    setState(() {
      _index++;
      _selected = null;
      _locked = false;
    });
    _pager.nextPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _claim(int correct) async {
    if (_claiming) return;
    setState(() => _claiming = true);
    final fresh = await ref
        .read(learnActionProvider.notifier)
        .submitQuiz(widget.moduleId, correct);
    if (!mounted) return;
    setState(() {
      _claiming = false;
      _claimed = fresh;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          fresh > 0
              ? '$fresh ${AppStrings.learnQuizClaimed}'
              : AppStrings.learnQuizNoNew,
        ),
        behavior: SnackBarBehavior.floating,
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
        body: const Center(child: Text('Kuis tidak ditemukan.')),
      );
    }
    final correct = [
      for (var i = 0; i < _answers.length; i++)
        if (module.quiz[i].isCorrect(_answers[i])) 1,
    ].length;
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
        title: Text(
          '${AppStrings.learnQuizTitle} - ${module.title}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: false,
        titleTextStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w800,
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
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: _finished
              ? _ResultPanel(
                  correct: correct,
                  total: module.quiz.length,
                  claimed: _claimed,
                  claiming: _claiming,
                  answers: List.of(_answers),
                  questions: module.quiz,
                  onClaim: () => _claim(correct),
                  onRetry: () => setState(() {
                    _index = 0;
                    _selected = null;
                    _locked = false;
                    _answers.clear();
                    _finished = false;
                    _claimed = 0;
                    _pager.jumpToPage(0);
                  }),
                  onBack: () => Navigator.of(context).maybePop(),
                )
              : Column(
                  children: [
                    _ProgressDots(
                      index: _index,
                      total: module.quiz.length,
                    ),
                    Expanded(
                      child: PageView.builder(
                        controller: _pager,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: module.quiz.length,
                        itemBuilder: (context, i) {
                          final q = module.quiz[i];
                          return SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  '${AppStrings.learnQuizOf} ${i + 1}/${module.quiz.length}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.8,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  q.question,
                                  style: const TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.3,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                for (var o = 0; o < q.options.length; o++) ...[
                                  if (o > 0) const SizedBox(height: 10),
                                  _OptionCard(
                                    text: q.options[o],
                                    state: !_locked
                                        ? _OptionState.idle
                                        : o == q.correctIndex
                                        ? _OptionState.correct
                                        : o == _selected
                                        ? _OptionState.wrong
                                        : _OptionState.dimmed,
                                    onTap: () => _choose(o),
                                  ),
                                ],
                                if (_locked) ...[
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.all(13),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      color:
                                          (_selected == q.correctIndex
                                                  ? AppColors.success
                                                  : AppColors.danger)
                                              .withValues(alpha: 0.08),
                                      border: Border.all(
                                        color:
                                            (_selected == q.correctIndex
                                                    ? AppColors.success
                                                    : AppColors.danger)
                                                .withValues(alpha: 0.3),
                                      ),
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Icon(
                                          _selected == q.correctIndex
                                              ? Icons.check_circle_rounded
                                              : Icons.cancel_rounded,
                                          size: 19,
                                          color: _selected == q.correctIndex
                                              ? AppColors.success
                                              : AppColors.danger,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                _selected == q.correctIndex
                                                    ? AppStrings
                                                          .learnQuizCorrect
                                                    : AppStrings.learnQuizWrong,
                                                style: const TextStyle(
                                                  fontSize: 13.5,
                                                  fontWeight: FontWeight.w800,
                                                  color:
                                                      AppColors.textPrimary,
                                                ),
                                              ),
                                              const SizedBox(height: 3),
                                              Text(
                                                q.explanation,
                                                style: const TextStyle(
                                                  fontSize: 12.5,
                                                  height: 1.6,
                                                  color:
                                                      AppColors.textSecondary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      child: SizedBox(
                        height: 52,
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _locked
                              ? () => _next(module.quiz.length)
                              : null,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: const Color(0xFFE8EDF5),
                            disabledForegroundColor: const Color(0xFF5B6B80),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          child: Text(
                            _index >= module.quiz.length - 1
                                ? AppStrings.learnQuizFinish
                                : AppStrings.learnQuizNext,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

enum _OptionState { idle, correct, wrong, dimmed }

class _OptionCard extends StatelessWidget {
  const _OptionCard({required this.text, required this.state, required this.onTap});

  final String text;
  final _OptionState state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (border, bg, fg) = switch (state) {
      _OptionState.correct => (
        AppColors.success.withValues(alpha: 0.55),
        AppColors.success.withValues(alpha: 0.1),
        AppColors.textPrimary,
      ),
      _OptionState.wrong => (
        AppColors.danger.withValues(alpha: 0.5),
        AppColors.danger.withValues(alpha: 0.07),
        AppColors.textPrimary,
      ),
      _OptionState.dimmed => (
        AppColors.neutral.withValues(alpha: 0.18),
        AppColors.surface,
        AppColors.textSecondary,
      ),
      _OptionState.idle => (
        AppColors.neutral.withValues(alpha: 0.25),
        AppColors.surface,
        AppColors.textPrimary,
      ),
    };
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: state == _OptionState.idle ? onTap : null,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: border, width: 1.3),
          ),
          child: Row(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: state == _OptionState.correct
                      ? AppColors.success
                      : state == _OptionState.wrong
                      ? AppColors.danger
                      : AppColors.neutral.withValues(alpha: 0.2),
                ),
                child: Icon(
                  state == _OptionState.correct
                      ? Icons.check_rounded
                      : state == _OptionState.wrong
                      ? Icons.close_rounded
                      : Icons.circle_outlined,
                  size: 15,
                  color: state == _OptionState.idle
                      ? AppColors.textSecondary
                      : Colors.white,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    fontWeight: FontWeight.w600,
                    color: fg,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressDots extends StatelessWidget {
  const _ProgressDots({required this.index, required this.total});

  final int index;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
      child: Row(
        children: [
          for (var i = 0; i < total; i++) ...[
            if (i > 0) const SizedBox(width: 6),
            Expanded(
              child: Container(
                height: 6,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: i <= index
                      ? AppColors.primary
                      : AppColors.neutral.withValues(alpha: 0.2),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Daftar review jawaban: soal mana benar/salah + kunci jawabannya.
///
/// Menjawab keluhan "result hanya lingkaran skor": user kini tahu persis
/// soal mana yang salah dan apa jawaban benarnya, tanpa mengulang kuis.
class _ReviewList extends StatelessWidget {
  const _ReviewList({required this.answers, required this.questions});

  final List<int> answers;
  final List<QuizQuestion> questions;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: AppColors.surface,
        border: Border.all(
          color: AppColors.neutral.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            AppStrings.learnQuizReviewTitle,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          for (var i = 0; i < questions.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            _ReviewRow(
              number: i + 1,
              right: i < answers.length &&
                  questions[i].isCorrect(answers[i]),
              correctAnswer: questions[i].options[questions[i].correctIndex],
            ),
          ],
        ],
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow({
    required this.number,
    required this.right,
    required this.correctAnswer,
  });

  final int number;
  final bool right;
  final String correctAnswer;

  @override
  Widget build(BuildContext context) {
    final color = right ? AppColors.success : AppColors.danger;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.12),
          ),
          child: Icon(
            right ? Icons.check_rounded : Icons.close_rounded,
            size: 15,
            color: color,
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${AppStrings.learnQuizOf} $number',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
              Text(
                correctAnswer,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12.5,
                  height: 1.5,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ResultPanel extends StatelessWidget {
  const _ResultPanel({
    required this.correct,
    required this.total,
    required this.claimed,
    required this.claiming,
    required this.answers,
    required this.questions,
    required this.onClaim,
    required this.onRetry,
    required this.onBack,
  });

  final int correct;
  final int total;
  final int claimed;
  final bool claiming;

  /// Jawaban user per soal (indeks opsi terpilih): dipakai daftar review.
  final List<int> answers;

  /// Soal modul: dipakai kunci jawaban + teks opsi benar di review.
  final List<QuizQuestion> questions;
  final VoidCallback onClaim;
  final VoidCallback onRetry;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      child: Column(
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF2F80ED), Color(0xFF124A9B)],
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x331558B0),
                  blurRadius: 24,
                  offset: Offset(0, 12),
                ),
              ],
            ),
            child: Center(
              child: Text(
                '$correct/$total',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            AppStrings.learnQuizScoreTitle,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          _ReviewList(answers: answers, questions: questions),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton.icon(
              onPressed: claiming ? null : onClaim,
              icon: claiming
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.emoji_events_outlined, size: 19),
              label: Text(
                claimed > 0
                    ? '$claimed ${AppStrings.learnQuizClaimed}'
                    : AppStrings.learnQuizClaim,
              ),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                textStyle: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text(AppStrings.learnQuizRetry),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: BorderSide(
                        color: AppColors.primary.withValues(alpha: 0.4),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: TextButton(
                    onPressed: onBack,
                    child: const Text(AppStrings.learnQuizBack),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
