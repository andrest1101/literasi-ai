import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/attachment_share_service.dart';
import '../../domain/entities/image_attachment.dart';

/// Pratinjau gambar penuh untuk sesi Quick Check.
///
/// Pengguna dapat membaca detail gambar dengan pinch/drag, double-tap, pan
/// toolbar, rotasi preview, dan share sheet sistem. File asli tidak diubah;
/// rotasi hanya berlaku pada tampilan.
class ImagePreviewScreen extends StatefulWidget {
  const ImagePreviewScreen({super.key, required this.image, this.shareService});

  final ImageAttachment image;
  final AttachmentShareService? shareService;

  @override
  State<ImagePreviewScreen> createState() => _ImagePreviewScreenState();
}

class _ImagePreviewScreenState extends State<ImagePreviewScreen> {
  static const double _maxScale = 5.0;

  final TransformationController _transformationController =
      TransformationController();
  final ValueNotifier<double> _scaleNotifier = ValueNotifier<double>(1.0);
  var _quarterTurns = 0;
  var _sharing = false;

  double get _currentScale =>
      _transformationController.value.getMaxScaleOnAxis();

  @override
  void initState() {
    super.initState();
    _transformationController.addListener(_onViewChanged);
  }

  @override
  void dispose() {
    _transformationController.removeListener(_onViewChanged);
    _transformationController.dispose();
    _scaleNotifier.dispose();
    super.dispose();
  }

  void _onViewChanged() {
    final next = _currentScale;
    if ((next - _scaleNotifier.value).abs() >= 0.01) {
      _scaleNotifier.value = next;
    }
  }

  void _zoomTo(double nextScale) {
    final clampedNext = nextScale.clamp(1.0, _maxScale);
    final current = _currentScale;
    if (current <= 0) return;

    final size = context.size;
    if (size == null || size.isEmpty) return;

    final factor = clampedNext / current;
    if (factor == 1) return;

    final matrix = _transformationController.value;
    final translation = Offset(matrix.entry(0, 3), matrix.entry(1, 3));
    final pivot = size.center(Offset.zero);
    final nextTranslation = pivot - (pivot - translation) * factor;

    final next = Matrix4.identity()
      ..translate(nextTranslation.dx, nextTranslation.dy)
      ..scale(clampedNext);
    _transformationController.value = next;
  }

  void _zoomIn() => _zoomTo(_currentScale * 1.4);

  void _zoomOut() => _zoomTo(_currentScale / 1.4);

  void _resetView() {
    _transformationController.value = Matrix4.identity();
    setState(() => _quarterTurns = 0);
  }

  void _toggleZoom() {
    if (_currentScale > 1.1) {
      _transformationController.value = Matrix4.identity();
      return;
    }
    _zoomTo(2.25);
  }

  void _rotate() => setState(() => _quarterTurns = (_quarterTurns + 1) % 4);

  Future<void> _share() async {
    if (_sharing) return;
    setState(() => _sharing = true);
    final service = widget.shareService ?? AttachmentShareService();

    try {
      await service.shareAttachment(
        bytes: widget.image.bytes,
        fileName: widget.image.fileName,
        mimeType: widget.image.mimeType,
      );
    } on Object {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.imageShareFailed),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final image = widget.image;
    final bytes = image.bytes;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          SafeArea(
            minimum: const EdgeInsets.only(top: 76, bottom: 88),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onDoubleTap: _toggleZoom,
              child: InteractiveViewer(
                transformationController: _transformationController,
                minScale: 1.0,
                maxScale: _maxScale,
                panEnabled: true,
                scaleEnabled: true,
                clipBehavior: Clip.hardEdge,
                child: SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: RotatedBox(
                    quarterTurns: _quarterTurns,
                    child: Image.memory(
                      bytes,
                      fit: BoxFit.contain,
                      gaplessPlayback: true,
                      errorBuilder: (_, _, _) => const _BrokenPreview(),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                child: Row(
                  children: [
                    _OverlayIconButton(
                      tooltip: AppStrings.imagePreviewClose,
                      icon: Icons.close_rounded,
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            AppStrings.imagePreviewTitle,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.white70,
                            ),
                          ),
                          Text(
                            '${image.fileName} · ${image.formattedSize}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    ValueListenableBuilder<double>(
                      valueListenable: _scaleNotifier,
                      builder: (_, scale, _) => Container(
                        constraints: const BoxConstraints(minWidth: 42),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          color: Colors.white.withValues(alpha: 0.1),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.12),
                          ),
                        ),
                        child: Text(
                          '${scale.toStringAsFixed(1)}×',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            fontFeatures: [FontFeature.tabularFigures()],
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    _OverlayIconButton(
                      tooltip: AppStrings.imagePreviewShare,
                      icon: _sharing ? null : Icons.share_rounded,
                      busy: _sharing,
                      onPressed: _sharing ? null : _share,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                child: Center(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.62),
                      borderRadius: BorderRadius.circular(26),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _OverlayIconButton(
                            tooltip: AppStrings.imagePreviewZoomOut,
                            icon: Icons.zoom_out_rounded,
                            onPressed: _zoomOut,
                          ),
                          _OverlayIconButton(
                            tooltip: AppStrings.imagePreviewZoomIn,
                            icon: Icons.zoom_in_rounded,
                            onPressed: _zoomIn,
                          ),
                          _OverlayIconButton(
                            tooltip: AppStrings.imagePreviewRotate,
                            icon: Icons.rotate_90_degrees_ccw_rounded,
                            onPressed: _rotate,
                          ),
                          _OverlayIconButton(
                            tooltip: AppStrings.imagePreviewZoomReset,
                            icon: Icons.fit_screen_rounded,
                            onPressed: _resetView,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OverlayIconButton extends StatelessWidget {
  const _OverlayIconButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    this.busy = false,
  });

  final String tooltip;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.48),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: IconButton(
        onPressed: onPressed,
        tooltip: tooltip,
        icon: busy
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }
}

class _BrokenPreview extends StatelessWidget {
  const _BrokenPreview();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Colors.black38,
      child: Center(
        child: Icon(
          Icons.broken_image_outlined,
          size: 64,
          color: Colors.white54,
        ),
      ),
    );
  }
}
