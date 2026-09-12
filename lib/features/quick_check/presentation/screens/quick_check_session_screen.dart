import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/image_attachment.dart';
import '../../domain/repositories/image_picker_service.dart';
import '../../domain/usecases/verify_claim.dart';
import '../providers/verification_provider.dart';
import '../widgets/quick_check_analyzing_indicator.dart';
import '../widgets/quick_check_image_section.dart';
import '../widgets/quick_check_input_section.dart';
import '../widgets/quick_check_result_section.dart';
import '../widgets/session_back_button.dart';

/// Dedicated session screen Quick Check teks dan gambar.
///
/// Dibuka via push dari landing tab agar pemeriksaan punya ruang penuh.
/// State verifikasi tetap AsyncNotifier; session menambah segmented mode dan
/// state attachment lokal agar UX terasa seperti aplikasi profesional.
class QuickCheckSessionScreen extends ConsumerStatefulWidget {
  const QuickCheckSessionScreen({super.key});

  static const route = '/quick-check-session';

  @override
  ConsumerState<QuickCheckSessionScreen> createState() =>
      _QuickCheckSessionScreenState();
}

enum _QuickCheckMode { text, image }

class _QuickCheckSessionScreenState
    extends ConsumerState<QuickCheckSessionScreen> {
  final _controller = TextEditingController();
  final _captionController = TextEditingController();
  final _scrollController = ScrollController();
  String? _localError;
  String? _captionError;
  _QuickCheckMode _mode = _QuickCheckMode.text;
  ImageAttachment? _image;
  bool _pickingImage = false;

  int get _length => _controller.text.trim().length;

  bool get _valid =>
      _length >= VerifyClaim.minLength && _length <= VerifyClaim.maxLength;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      if (!mounted) return;
      if (_localError != null) {
        setState(() => _localError = null);
      } else {
        setState(() {});
      }
    });
    _captionController.addListener(() {
      if (!mounted) return;
      if (_captionError != null) {
        setState(() => _captionError = null);
      } else {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _captionController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _verify() {
    FocusScope.of(context).unfocus();
    final text = _controller.text;
    if (text.trim().length < VerifyClaim.minLength) {
      setState(() => _localError = AppStrings.quickCheckTooShort);
      return;
    }
    if (text.trim().length > VerifyClaim.maxLength) {
      setState(() => _localError = AppStrings.quickCheckTooLong);
      return;
    }
    setState(() => _localError = null);
    ref.read(quickCheckControllerProvider.notifier).verify(text);
    _scrollToResult();
  }

  void _verifyImage() {
    FocusScope.of(context).unfocus();
    final image = _image;
    if (image == null || ref.read(quickCheckControllerProvider).isLoading) {
      return;
    }
    final caption = _captionController.text;
    final normalized = caption.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (normalized.isNotEmpty && normalized.length < VerifyClaim.minLength) {
      setState(() => _captionError = AppStrings.quickCheckTooShort);
      return;
    }
    if (normalized.length > VerifyClaim.maxLength) {
      setState(() => _captionError = AppStrings.quickCheckTooLong);
      return;
    }
    setState(() => _captionError = null);
    ref
        .read(quickCheckControllerProvider.notifier)
        .verifyImage(image: image, caption: normalized);
    _scrollToResult();
  }

  void _clear() {
    _controller.clear();
    _captionController.clear();
    setState(() {
      _localError = null;
      _captionError = null;
      _image = null;
    });
    ref.read(quickCheckControllerProvider.notifier).reset();
  }

  void _clearCaption() {
    _captionController.clear();
    if (mounted) setState(() => _captionError = null);
  }

  void _removeImage() {
    setState(() {
      _image = null;
      _captionError = null;
    });
  }

  void _switchMode(_QuickCheckMode mode) {
    if (mode == _mode || ref.read(quickCheckControllerProvider).isLoading) {
      return;
    }
    setState(() {
      _mode = mode;
      _localError = null;
      _captionError = null;
    });
    ref.read(quickCheckControllerProvider.notifier).reset();
  }

  Future<void> _pickImage(ImagePickSource source) async {
    if (_pickingImage || ref.read(quickCheckControllerProvider).isLoading) {
      return;
    }
    setState(() => _pickingImage = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final picked = await ref
          .read(imagePickerServiceProvider)
          .pickImage(source);
      if (!mounted) return;
      if (picked == null) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text(AppStrings.quickCheckImageCancelled),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
      if (!picked.isValid) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text(
              'Gambar tidak valid. Pakai JPG/PNG/WebP maksimal 5 MB.',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
      setState(() => _image = picked);
    } catch (e) {
      if (!mounted) return;
      final message = e is Failure
          ? e.message
          : 'Gambar tidak terbaca, upload ulang dengan pencahayaan lebih baik.';
      messenger.showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
    } finally {
      if (mounted) setState(() => _pickingImage = false);
    }
  }

  void _scrollToResult() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 350), () {
        if (!mounted || !_scrollController.hasClients) return;
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeInOutCubic,
        );
      });
    });
  }

  int _stepIndex(bool loading, bool hasResult, bool hasError) {
    if (hasResult || hasError) return 2;
    if (loading) return 1;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(quickCheckControllerProvider);
    final notifier = ref.read(quickCheckControllerProvider.notifier);
    final loading = state.isLoading;
    final hasResult = state.hasValue && state.value != null;
    final hasError = state.hasError;
    final step = _stepIndex(loading, hasResult, hasError);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        shadowColor: Colors.transparent,
        toolbarHeight: 64,
        leadingWidth: 56,
        titleSpacing: 4,
        leading: SessionBackButton(
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(AppStrings.quickCheckSessionTitle),
        centerTitle: false,
        titleTextStyle: const TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.3,
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
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  AppStrings.quickCheckSessionSubtitle,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.6,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                _SessionStepper(step: step),
                const SizedBox(height: 18),
                const Divider(height: 1),
                const SizedBox(height: 16),
                _ModeSelector(
                  mode: _mode,
                  loading: loading,
                  onChanged: _switchMode,
                ),
                const SizedBox(height: 8),
                const Text(
                  AppStrings.quickCheckModeHint,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.55,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 20),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 280),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  child: _mode == _QuickCheckMode.text
                      ? QuickCheckInputSection(
                          key: const ValueKey('text-mode'),
                          controller: _controller,
                          localError: _localError,
                          loading: loading,
                          valid: _valid,
                          onVerify: _verify,
                          onClear: _clear,
                        )
                      : QuickCheckImageSection(
                          key: const ValueKey('image-mode'),
                          image: _image,
                          captionController: _captionController,
                          captionError: _captionError,
                          loading: loading || _pickingImage,
                          onPick: _pickImage,
                          onRemove: _removeImage,
                          onVerify: _verifyImage,
                          onClearCaption: _clearCaption,
                        ),
                ),
                const SizedBox(height: 24),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  child: KeyedSubtree(
                    key: ValueKey(
                      'quick-check-state-${loading
                          ? 'loading'
                          : hasError
                          ? 'error'
                          : hasResult
                          ? 'result'
                          : 'idle'}',
                    ),
                    child: state.when(
                      data: (result) {
                        if (result == null) {
                          return const _SessionTips();
                        }
                        return QuickCheckResultSection(
                          result: result,
                          loading: loading,
                          onNewCheck: _clear,
                        );
                      },
                      loading: () => QuickCheckAnalyzingIndicator(
                        imageMode: _mode == _QuickCheckMode.image,
                      ),
                      error: (error, _) => Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          QuickCheckErrorSection(
                            error: error,
                            canRetry: notifier.lastClaim != null && !loading,
                            onRetry: () {
                              notifier.retry();
                              _scrollToResult();
                            },
                          ),
                          const SizedBox(height: 20),
                          const _SessionTips(),
                        ],
                      ),
                    ),
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

/// Panel status sesi dengan latar tenang.
///
/// Panel ini menyatukan subtitle dan stepper di atas satu permukaan putih
/// agar AppBar yang datar tidak membuat bagian atas halaman terasa polos,
/// tanpa memakai gradien atau blok warna yang mencolok.
class _ModeSelector extends StatelessWidget {
  const _ModeSelector({
    required this.mode,
    required this.loading,
    required this.onChanged,
  });

  final _QuickCheckMode mode;
  final bool loading;
  final ValueChanged<_QuickCheckMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Pilih mode pemeriksaan',
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: AppColors.neutral.withValues(alpha: 0.12),
          border: Border.all(color: AppColors.neutral.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Expanded(
              child: _ModeButton(
                icon: Icons.text_snippet_outlined,
                label: AppStrings.quickCheckModeText,
                selected: mode == _QuickCheckMode.text,
                onTap: loading ? null : () => onChanged(_QuickCheckMode.text),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: _ModeButton(
                icon: Icons.image_outlined,
                label: AppStrings.quickCheckModeImage,
                selected: mode == _QuickCheckMode.image,
                onTap: loading ? null : () => onChanged(_QuickCheckMode.image),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  const _ModeButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: selected ? AppColors.surface : Colors.transparent,
        boxShadow: selected
            ? const [
                BoxShadow(
                  color: Color(0x14101A33),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 19,
                  color: selected ? AppColors.primary : AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                    color: selected
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
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

/// Stepper sesi dengan center-dot alignment.
///
/// Garis penghubung membentang dari titik tengah dot pertama hingga titik
/// tengah dot terakhir, sehingga tepi kiri/kanan stepper sejajar sempurna
/// dengan batas kontainer input di bawahnya tanpa angka piksel hardcoded.
class _SessionStepper extends StatelessWidget {
  const _SessionStepper({required this.step});

  final int step;

  static const _labels = ['Input', 'Analisis', 'Hasil'];
  static const _dotSize = 22.0;
  static const _trackHeight = 2.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          // Garis penuh sebagai track, di-inset setengah dot agar ujungnya
          // tepat di pusat dot pertama dan terakhir.
          Positioned(
            left: _dotSize / 2,
            right: _dotSize / 2,
            // Pusatkan track 2px ke titik tengah dot 22px.
            top: (_dotSize - _trackHeight) / 2,
            child: Row(
              children: [
                for (var i = 0; i < _labels.length - 1; i++) ...[
                  Expanded(
                    child: Container(
                      height: _trackHeight,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: i < step
                            ? AppColors.primary
                            : AppColors.neutral.withValues(alpha: 0.25),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Dot diposisikan proporsional di atas track.
          Row(
            children: [
              for (var i = 0; i < _labels.length; i++) ...[
                if (i > 0) const Spacer(),
                _StepDot(active: i <= step, done: i < step, size: _dotSize),
              ],
            ],
          ),
          // Label memakai kolom Expanded sendiri, tidak dikunci selebar dot.
          // Jarak dibuat lega agar teks tidak menempel pada bullet, dan label
          // aktif memakai teks gelap supaya tidak menyatu dengan warna biru.
          Positioned(
            top: _dotSize + 12,
            left: 0,
            right: 0,
            child: Row(
              children: [
                for (var i = 0; i < _labels.length; i++)
                  Expanded(
                    child: Text(
                      _labels[i],
                      textAlign: i == 0
                          ? TextAlign.left
                          : i == _labels.length - 1
                          ? TextAlign.right
                          : TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.3,
                        fontWeight: i == step
                            ? FontWeight.w800
                            : i < step
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: i == step
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StepDot extends StatelessWidget {
  const _StepDot({required this.active, required this.done, this.size = 22});

  final bool active;
  final bool done;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: done
          ? 'Langkah selesai'
          : active
          ? 'Langkah aktif'
          : 'Langkah berikutnya',
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: done
              ? AppColors.primary
              : active
              ? AppColors.primary.withValues(alpha: 0.14)
              : AppColors.surface,
          border: Border.all(
            color: done || active
                ? AppColors.primary
                : AppColors.neutral.withValues(alpha: 0.34),
            width: done || active ? 1.4 : 1.2,
          ),
        ),
        child: Icon(
          done ? Icons.check_rounded : Icons.circle,
          size: done ? size * 0.58 : size * 0.3,
          color: done
              ? Colors.white
              : active
              ? AppColors.primary
              : AppColors.neutral,
        ),
      ),
    );
  }
}

class _SessionTips extends StatelessWidget {
  const _SessionTips();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.quickCheckTipsTitle,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 10),
        _TipLine(text: AppStrings.quickCheckTip1),
        SizedBox(height: 8),
        _TipLine(text: AppStrings.quickCheckTip2),
        SizedBox(height: 8),
        _TipLine(text: AppStrings.quickCheckTip3),
      ],
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
