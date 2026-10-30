import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../history/presentation/providers/history_providers.dart';
import '../../../quick_check/presentation/widgets/session_back_button.dart';
import '../../domain/entities/course_module.dart';
import '../../domain/entities/quiz_question.dart';
import '../../domain/entities/quiz_submission.dart';
import '../providers/learn_providers.dart';

/// Kuis berurutan: 1 soal per halaman, jawaban terkunci, bisa kembali ke
/// soal yang sudah dijawab untuk ditinjau.
///
/// Pola heterogen vs kartu modul: progres dots atas (bernomor, status
/// terjawab/aktif), kartu soal putih, opsi sebagai radio card berwarna saat
/// dikunci (hijau benar / merah salah + penjelasan), hasil akhir berupa panel
/// skor + status penyimpanan.
class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({super.key, required this.moduleId});

  final String moduleId;

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  final _pager = PageController();
  final List<int?> _picks = <int?>[];
  CourseModule? _module;
  int _index = 0;
  bool _finished = false;
  bool _submitting = false;
  QuizSubmission? _outcome;

  @override
  void initState() {
    super.initState();
    final module = ref
        .read(learnContentProvider)
        .where((m) => m.id == widget.moduleId)
        .firstOrNull;
    _module = module;
  }

  @override
  void dispose() {
    _pager.dispose();
    super.dispose();
  }

  /// Jumlah soal modul yang sedang dikaji.
  int get _quizTotal => _module?.quiz.length ?? 0;

  bool _answered(int questionIndex) =>
      questionIndex < _picks.length && _picks[questionIndex] != null;

  /// Indeks soal terakhir yang bisa dikunjungi: semua soal yang dijawab,
  /// atau soal berikutnya yang belum dijawab untuk diposisikan.
  int get _furthestQuestion {
    for (var i = 0; i < _quizTotal; i++) {
      if (!_answered(i)) return i;
    }
    return _quizTotal;
  }

  bool _canVisit(int questionIndex) =>
      questionIndex < _quizTotal && questionIndex <= _furthestQuestion;

  int get _correctCount {
    final questions = _module?.quiz ?? const <QuizQuestion>[];
    var correct = 0;
    for (var i = 0; i < questions.length; i++) {
      final answer = i < _picks.length ? _picks[i] : null;
      if (answer != null && questions[i].isCorrect(answer)) {
        correct++;
      }
    }
    return correct;
  }

  void _choose(int option) {
    if (_finished || _answered(_index)) return;
    setState(() {
      while (_picks.length <= _index) {
        _picks.add(null);
      }
      _picks[_index] = option;
    });
  }

  void _jumpTo(int questionIndex) {
    if (_finished || !_canVisit(questionIndex) || questionIndex == _index) {
      return;
    }
    setState(() => _index = questionIndex);
    _pager.animateToPage(
      questionIndex,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  void _advance() {
    if (!_answered(_index)) return;
    if (_index >= _quizTotal - 1) {
      unawaited(_finish());
      return;
    }
    final next = _index + 1;
    setState(() => _index = next);
    _pager.animateToPage(
      next,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _finish() async {
    if (_finished) return;
    setState(() => _finished = true);
    final correct = _correctCount;
    await _submitQuiz(correct);
  }

  Future<void> _submitQuiz(int correct) async {
    if (_submitting) return;
    setState(() => _submitting = true);
    final submission = await ref
        .read(learnActionProvider.notifier)
        .submitQuiz(widget.moduleId, correct);
    if (!mounted) return;
    setState(() {
      _submitting = false;
      _outcome = submission;
    });
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    switch (submission.status) {
      case QuizSaveStatus.failed:
        messenger.showSnackBar(
          SnackBar(
            content: const Text(AppStrings.learnQuizSaveFailed),
            backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating,
          ),
        );
      case QuizSaveStatus.saved:
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              submission.points > 0
                  ? AppStrings.learnQuizClaimedHint
                  : AppStrings.learnQuizNoNew,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
            backgroundColor: AppColors.successDark,
            behavior: SnackBarBehavior.floating,
          ),
        );
      case QuizSaveStatus.unchanged:
        messenger.showSnackBar(
          const SnackBar(
            content: Text(AppStrings.learnQuizNoNew),
            backgroundColor: AppColors.successDark,
            behavior: SnackBarBehavior.floating,
          ),
        );
    }
  }

  void _retryQuiz() {
    setState(() {
      _index = 0;
      _picks.clear();
      _finished = false;
      _outcome = null;
      _submitting = false;
    });
    _pager.jumpToPage(0);
  }

  List<int> get _answers {
    final questions = _module?.quiz ?? const <QuizQuestion>[];
    return [
      for (var i = 0; i < questions.length; i++)
        (i < _picks.length ? _picks[i] : null) ?? -1,
    ];
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 72,
        leadingWidth: 56,
        leading: SessionBackButton(
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        // Dua baris: eyebrow tetap + judul modul penuh. Judul tidak lagi
        // dipaksa satu baris sehingga nama modul panjang tetap terbaca.
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.learnQuizTitle.toUpperCase(),
              style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 2),
            Semantics(
              label: '${AppStrings.learnQuizTitle}: ${module.title}',
              child: Text(
                module.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.15,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
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
                  correct: _correctCount,
                  total: module.quiz.length,
                  perfect: _correctCount >= module.quiz.length,
                  outcome: _outcome,
                  submitting: _submitting,
                  isGuest: ref.read(historyUserIdProvider) == null,
                  answers: _answers,
                  questions: module.quiz,
                  onRetryQuiz: _retryQuiz,
                  onRetrySave: () => unawaited(_submitQuiz(_correctCount)),
                  onBack: () => Navigator.of(context).maybePop(),
                )
              : Column(
                  children: [
                    _QuestionOverview(
                      picks: _picks,
                      index: _index,
                      enabledUntil: _furthestQuestion,
                      total: module.quiz.length,
                      onSelect: _jumpTo,
                    ),
                    Expanded(
                      child: PageView.builder(
                        controller: _pager,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: module.quiz.length,
                        itemBuilder: (context, i) {
                          final q = module.quiz[i];
                          final answered = _answered(i);
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
                                    key: ValueKey('quiz-option-$i-$o'),
                                    letter: String.fromCharCode(65 + o),
                                    text: q.options[o],
                                    state: !answered
                                        ? _OptionState.idle
                                        : o == q.correctIndex
                                        ? _OptionState.correct
                                        : o == _picks[i]
                                        ? _OptionState.wrong
                                        : _OptionState.dimmed,
                                    onTap: answered ? null : () => _choose(o),
                                  ),
                                ],
                                if (answered) ...[
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.all(13),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      color:
                                          (_picks[i] == q.correctIndex
                                                  ? AppColors.success
                                                  : AppColors.danger)
                                              .withValues(alpha: 0.08),
                                      border: Border.all(
                                        color:
                                            (_picks[i] == q.correctIndex
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
                                          _picks[i] == q.correctIndex
                                              ? Icons.check_circle_rounded
                                              : Icons.cancel_rounded,
                                          size: 19,
                                          color: _picks[i] == q.correctIndex
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
                                                _picks[i] == q.correctIndex
                                                    ? AppStrings
                                                          .learnQuizCorrect
                                                    : AppStrings.learnQuizWrong,
                                                style: const TextStyle(
                                                  fontSize: 13.5,
                                                  fontWeight: FontWeight.w800,
                                                  color: AppColors.textPrimary,
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
                          onPressed: _answered(_index) ? _advance : null,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: AppColors.disabledSurface,
                            disabledForegroundColor: AppColors.disabledInk,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          child: Text(
                            _index >= _quizTotal - 1
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
  const _OptionCard({
    super.key,
    required this.letter,
    required this.text,
    required this.state,
    this.onTap,
  });

  final String letter;
  final String text;
  final _OptionState state;
  final VoidCallback? onTap;

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
    final badgeColor = switch (state) {
      _OptionState.correct => AppColors.success,
      _OptionState.wrong => AppColors.danger,
      _ => AppColors.neutral.withValues(alpha: 0.2),
    };
    return Semantics(
      button: state == _OptionState.idle,
      label: 'Opsi $letter. $text',
      child: Material(
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
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: badgeColor,
                  ),
                  child: Text(
                    letter,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: state == _OptionState.idle
                          ? AppColors.textSecondary
                          : Colors.white,
                    ),
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
                if (state == _OptionState.correct) ...[
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.check_circle_rounded,
                    size: 20,
                    color: AppColors.success,
                  ),
                ] else if (state == _OptionState.wrong) ...[
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.cancel_rounded,
                    size: 20,
                    color: AppColors.danger,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Header progres kuis: satu baris status + deretan segmen bernomor.
///
/// Desain ini menggantikan deretan dot selebar tetap yang dulu mendorong
/// penghitung "0 dari 4 sudah dijawab" sampai terpotong. Segmen memakai
/// [Expanded] sehingga jumlah soal berapa pun tetap muat tanpa ellipsis.
class _QuestionOverview extends StatelessWidget {
  const _QuestionOverview({
    required this.picks,
    required this.index,
    required this.enabledUntil,
    required this.total,
    required this.onSelect,
  });

  final List<int?> picks;
  final int index;
  final int enabledUntil;
  final int total;
  final void Function(int) onSelect;

  bool _isAnswered(int questionIndex) =>
      questionIndex < picks.length && picks[questionIndex] != null;

  @override
  Widget build(BuildContext context) {
    final answeredCount = picks.where((p) => p != null).length.clamp(0, total);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              // Label kiri diskalakan turun bila layar sangat sempit agar
              // tidak pernah terpotong atau menabrak penghitung di kanan.
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${AppStrings.learnQuizOf} ${index + 1} '
                    '${AppStrings.learnQuizFrom} $total',
                    maxLines: 1,
                    softWrap: false,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '$answeredCount/$total '
                '${AppStrings.learnQuizAnsweredShort}',
                maxLines: 1,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              for (var i = 0; i < total; i++) ...[
                if (i > 0) const SizedBox(width: 6),
                Expanded(
                  child: _QuestionStep(
                    key: ValueKey('quiz-step-$i'),
                    index: i,
                    answered: _isAnswered(i),
                    active: i == index,
                    enabledUntil: enabledUntil,
                    onTap: onSelect,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// Satu segmen bernomor pada header progres.
///
/// Status memakai tiga tingkat yang jelas: aktif (biru solid), terjawab
/// (biru tint), dan terkunci (abu). Nomor tetap terlihat di semua status
/// agar orientasi soal tidak hilang.
class _QuestionStep extends StatelessWidget {
  const _QuestionStep({
    super.key,
    required this.index,
    required this.answered,
    required this.active,
    required this.enabledUntil,
    required this.onTap,
  });

  final int index;
  final bool answered;
  final bool active;
  final int enabledUntil;
  final void Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    final isEnabled = index < enabledUntil;
    final fillColor = switch ((isEnabled, active, answered)) {
      (true, true, _) => AppColors.primary,
      (true, false, true) => AppColors.primary.withValues(alpha: 0.12),
      (true, false, false) => AppColors.neutral.withValues(alpha: 0.08),
      _ => AppColors.neutral.withValues(alpha: 0.05),
    };
    final borderColor = switch ((isEnabled, active, answered)) {
      (true, true, _) => AppColors.primary,
      (true, _, true) => AppColors.primary.withValues(alpha: 0.5),
      _ => AppColors.neutral.withValues(alpha: 0.2),
    };
    final labelColor = switch ((isEnabled, active, answered)) {
      (true, true, _) => Colors.white,
      (true, false, true) => AppColors.primary,
      _ => AppColors.textSecondary,
    };
    final stateLabel = answered
        ? AppStrings.learnQuizAnsweredLabel
        : AppStrings.learnQuizNotAnsweredLabel;
    return Semantics(
      button: isEnabled,
      selected: active,
      label:
          '${AppStrings.learnQuizOf} ${index + 1}, $stateLabel'
          '${active ? ', sedang dibuka' : ''}',
      child: SizedBox(
        height: 40,
        child: Material(
          color: fillColor,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: isEnabled ? () => onTap(index) : null,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor, width: 1.2),
              ),
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: labelColor,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ),
        ),
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
        border: Border.all(color: AppColors.neutral.withValues(alpha: 0.2)),
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
              right: i < answers.length && questions[i].isCorrect(answers[i]),
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

class _QuizStatusCard extends StatelessWidget {
  const _QuizStatusCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
    this.onActionLabel,
    this.onAction,
  });

  final Widget icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;
  final String? onActionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: backgroundColor,
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: iconColor.withValues(alpha: 0.15),
            ),
            child: IconTheme(
              data: IconThemeData(size: 22, color: iconColor),
              child: icon,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: textColor,
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
                if (onActionLabel != null && onAction != null) ...[
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: FilledButton.icon(
                      onPressed: onAction,
                      icon: const Icon(Icons.refresh_rounded, size: 17),
                      label: Text(onActionLabel!),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
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

class _SaveFailedStatus extends StatelessWidget {
  const _SaveFailedStatus({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppColors.danger.withValues(alpha: 0.06),
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.cloud_off_rounded, size: 20, color: AppColors.danger),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  AppStrings.learnQuizSaveFailed,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text(AppStrings.learnQuizRetrySave),
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
        ],
      ),
    );
  }
}

class _ResultPanel extends StatelessWidget {
  const _ResultPanel({
    required this.correct,
    required this.total,
    required this.perfect,
    required this.outcome,
    required this.submitting,
    required this.isGuest,
    required this.answers,
    required this.questions,
    required this.onRetryQuiz,
    required this.onRetrySave,
    required this.onBack,
  });

  final int correct;
  final int total;

  /// Hasil sempurna (semua benar): hero hijau + catatan sempurna.
  /// Parsial memakai biru + hint belajar lagi. Tanpa string merendahkan.
  final bool perfect;
  final QuizSubmission? outcome;
  final bool submitting;
  final bool isGuest;

  /// Jawaban user per soal (indeks opsi terpilih): dipakai daftar review.
  final List<int> answers;

  /// Soal modul: dipakai kunci jawaban + teks opsi benar di review.
  final List<QuizQuestion> questions;
  final VoidCallback onRetryQuiz;
  final VoidCallback onRetrySave;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      child: Column(
        children: [
          _ResultHero(correct: correct, total: total, perfect: perfect),
          const SizedBox(height: 16),
          if (perfect)
            const Text(
              AppStrings.learnQuizPerfectNote,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.successDark,
              ),
            )
          else
            const Text(
              AppStrings.learnQuizPartialHint,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.6,
                color: AppColors.textSecondary,
              ),
            ),
          const SizedBox(height: 14),
          _ReviewList(answers: answers, questions: questions),
          const SizedBox(height: 20),
          if (submitting)
            _QuizStatusCard(
              icon: const CircularProgressIndicator(strokeWidth: 2.2),
              iconColor: AppColors.primary,
              title: AppStrings.learnQuizSaving,
              subtitle: null,
              backgroundColor: AppColors.neutral.withValues(alpha: 0.08),
              borderColor: AppColors.neutral.withValues(alpha: 0.2),
              textColor: AppColors.textPrimary,
              onActionLabel: null,
              onAction: null,
            )
          else if (outcome?.isFailed ?? false)
            _SaveFailedStatus(onRetry: onRetrySave)
          else if (outcome?.isSaved ?? false)
            _ClaimedStatus(
              claimed: outcome?.points ?? 0,
              isGuest: isGuest,
              onCountDone: () => HapticFeedback.mediumImpact(),
            )
          else
            _QuizStatusCard(
              icon: const Icon(Icons.emoji_events_outlined, size: 22),
              iconColor: AppColors.successDark,
              title: AppStrings.learnQuizNoNew,
              subtitle: AppStrings.learnQuizBestSaved,
              backgroundColor: AppColors.success.withValues(alpha: 0.08),
              borderColor: AppColors.success.withValues(alpha: 0.35),
              textColor: AppColors.successDark,
              onActionLabel: null,
              onAction: null,
            ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: onRetryQuiz,
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text(AppStrings.learnQuizRetry),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      disabledForegroundColor: AppColors.neutral,
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

/// Hero hasil kuis: lingkaran skor + judul, varian sempurna/parsiil.
///
/// Sempurna = medallion hijau + trofi di bawah angka (momen perayaan
/// tanpa confetti). Parsial = biru seperti semula. Tanpa aset, tanpa
/// animasi loop: calm dan deterministik untuk test.
class _ResultHero extends StatelessWidget {
  const _ResultHero({
    required this.correct,
    required this.total,
    required this.perfect,
  });

  final int correct;
  final int total;
  final bool perfect;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 84,
          height: 84,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: perfect
                  ? const [AppColors.success, AppColors.successDark]
                  : const [AppColors.heroBegin, AppColors.heroEnd],
            ),
            boxShadow: [
              BoxShadow(
                color: (perfect ? AppColors.successDark : AppColors.heroEnd)
                    .withValues(alpha: 0.2),
                blurRadius: 24,
                offset: const Offset(0, 12),
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
        if (perfect) ...[
          const SizedBox(height: 8),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.success.withValues(alpha: 0.12),
              border: Border.all(
                color: AppColors.success.withValues(alpha: 0.35),
              ),
            ),
            child: const Icon(
              Icons.emoji_events_outlined,
              size: 19,
              color: AppColors.successDark,
            ),
          ),
        ],
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
      ],
    );
  }
}

/// Status klaim persisten: bukti klaim yang tidak menguap.
///
/// Menggantikan label tombol yang berubah jadi kalimat: trofi hijau +
/// angka count-up + sublabel "masuk ke skormu". Nonaktif permanen
/// (anti double-claim visual; backend idempoten via best-score).
/// Haptic medium sekali saat angka selesai (via [onCountDone]).
class _ClaimedStatus extends StatefulWidget {
  const _ClaimedStatus({
    required this.claimed,
    required this.isGuest,
    required this.onCountDone,
  });

  final int claimed;
  final bool isGuest;
  final VoidCallback onCountDone;

  @override
  State<_ClaimedStatus> createState() => _ClaimedStatusState();
}

class _ClaimedStatusState extends State<_ClaimedStatus> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppColors.success.withValues(alpha: 0.08),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.success.withValues(alpha: 0.15),
            ),
            child: const Icon(
              Icons.emoji_events_outlined,
              size: 22,
              color: AppColors.successDark,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TweenAnimationBuilder<int>(
                  tween: IntTween(begin: 0, end: widget.claimed),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOutCubic,
                  onEnd: widget.onCountDone,
                  builder: (context, value, _) {
                    return Text(
                      widget.isGuest
                          ? AppStrings.learnQuizSavedLocalHint
                          : '+$value ${AppStrings.learnQuizClaimed}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.successDark,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 2),
                Text(
                  widget.isGuest
                      ? AppStrings.learnQuizLocalSaved
                      : AppStrings.learnQuizClaimedHint,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.check_circle_rounded,
            size: 22,
            color: AppColors.success,
          ),
        ],
      ),
    );
  }
}
