import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';

/// Indikator analisis elegan: timeline tiga tahap, bukan kartu besar.
///
/// Jujur soal progres: bar memakai mode indeterminate (AI tidak melaporkan
/// persen nyata) dan label kanan menunjukkan detik berjalan, bukan persen
/// palsu yang mengulang dari 0 setiap 3,6 detik.
class QuickCheckAnalyzingIndicator extends StatefulWidget {
  const QuickCheckAnalyzingIndicator({
    super.key,
    this.imageMode = false,
    this.urlMode = false,
  });

  final bool imageMode;
  final bool urlMode;

  @override
  State<QuickCheckAnalyzingIndicator> createState() =>
      _QuickCheckAnalyzingIndicatorState();
}

class _QuickCheckAnalyzingIndicatorState
    extends State<QuickCheckAnalyzingIndicator> {
  late final Stopwatch _stopwatch;
  Timer? _ticker;
  int _seconds = 0;

  static const _textSteps = [
    'Memahami informasi',
    'Menilai bukti',
    'Menyusun hasil',
  ];
  static const _imageSteps = [
    'Membaca gambar',
    'Menilai bukti',
    'Menyusun hasil',
  ];
  static const _urlSteps = ['Memuat link', 'Menilai bukti', 'Menyusun hasil'];

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch()..start();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _seconds = _stopwatch.elapsed.inSeconds);
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _stopwatch.stop();
    super.dispose();
  }

  /// Tahap monoton naik berdasarkan detik berjalan: tidak pernah mundur
  /// seperti loop persen sebelumnya. Estimasi kasar yang jujur: AI tidak
  /// melaporkan progres nyata, jadi tahap hanya ilustrasi alur.
  int get _activeStep {
    if (_seconds >= 8) return 2;
    if (_seconds >= 3) return 1;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final steps = widget.urlMode
        ? _urlSteps
        : widget.imageMode
        ? _imageSteps
        : _textSteps;
    final activeStep = _activeStep;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const SizedBox(
              width: 26,
              height: 26,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.quickCheckAnalyzingTitle,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    AppStrings.quickCheckAnalyzingSubtitle,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '$_seconds dtk',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                fontFeatures: [FontFeature.tabularFigures()],
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            minHeight: 8,
            backgroundColor: AppColors.primary.withValues(alpha: 0.12),
            valueColor: const AlwaysStoppedAnimation(AppColors.primary),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            for (var i = 0; i < steps.length; i++) ...[
              Expanded(
                child: _StepLabel(
                  label: steps[i],
                  active: i == activeStep,
                  done: i < activeStep,
                ),
              ),
              if (i < steps.length - 1) const SizedBox(width: 8),
            ],
          ],
        ),
      ],
    );
  }
}

class _StepLabel extends StatelessWidget {
  const _StepLabel({
    required this.label,
    required this.active,
    required this.done,
  });

  final String label;
  final bool active;
  final bool done;

  @override
  Widget build(BuildContext context) {
    final color = done || active
        ? AppColors.primary
        : AppColors.textSecondary.withValues(alpha: 0.65);
    return Row(
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: done
                ? AppColors.primary
                : active
                ? AppColors.primary.withValues(alpha: 0.16)
                : AppColors.neutral.withValues(alpha: 0.16),
          ),
          child: Icon(
            done ? Icons.check_rounded : Icons.circle,
            size: done ? 12 : 6,
            color: done ? Colors.white : AppColors.primary,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              height: 1.35,
              fontWeight: active || done ? FontWeight.w800 : FontWeight.w500,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}
