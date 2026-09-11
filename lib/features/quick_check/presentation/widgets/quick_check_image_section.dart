import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/image_attachment.dart';
import '../../domain/repositories/image_picker_service.dart';
import '../../domain/usecases/verify_claim.dart';

/// Panel lampiran gambar sesi Quick Check.
///
/// Menampilkan picker galeri/kamera, preview thumbnail dengan metadata,
/// caption opsional, dan catatan privasi. Satu gambar per sesi sesuai
/// batas tahap 1.
class QuickCheckImageSection extends StatelessWidget {
  const QuickCheckImageSection({
    super.key,
    required this.image,
    required this.captionController,
    required this.captionError,
    required this.loading,
    required this.onPick,
    required this.onRemove,
    required this.onVerify,
    required this.onClearCaption,
  });

  final ImageAttachment? image;
  final TextEditingController captionController;
  final String? captionError;
  final bool loading;
  final ValueChanged<ImagePickSource> onPick;
  final VoidCallback onRemove;
  final VoidCallback onVerify;
  final VoidCallback onClearCaption;

  bool get _captionValid {
    final text = captionController.text.trim();
    if (text.isEmpty) return true;
    return text.length >= VerifyClaim.minLength &&
        text.length <= VerifyClaim.maxLength;
  }

  bool get _canVerify => image != null && _captionValid && !loading;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          AppStrings.quickCheckImageTitle,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          AppStrings.quickCheckImageSubtitle,
          style: TextStyle(
            fontSize: 13,
            height: 1.55,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 14),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: image == null
              ? _EmptyPicker(key: const ValueKey('empty'), onPick: onPick)
              : _ImagePreview(
                  key: ValueKey(image.hashCode),
                  image: image!,
                  loading: loading,
                  onReplace: onPick,
                  onRemove: onRemove,
                ),
        ),
        const SizedBox(height: 14),
        _CaptionField(
          controller: captionController,
          error: captionError,
          loading: loading,
          onClear: onClearCaption,
        ),
        const SizedBox(height: 10),
        const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.privacy_tip_outlined,
              size: 16,
              color: AppColors.textSecondary,
            ),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                AppStrings.quickCheckPrivacyNote,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.55,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 56,
          child: FilledButton.icon(
            onPressed: _canVerify ? onVerify : null,
            icon: loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.image_search_rounded, size: 22),
            label: Text(
              loading
                  ? AppStrings.quickCheckAnalyzingTitle
                  : AppStrings.quickCheckVerify,
            ),
            style:
                FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xFFE8EDF5),
                  disabledForegroundColor: const Color(0xFF5B6B80),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                  elevation: loading ? 0 : 6,
                  shadowColor: AppColors.primary.withValues(alpha: 0.38),
                ).copyWith(
                  animationDuration: const Duration(milliseconds: 250),
                  side: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.disabled)) {
                      return const BorderSide(color: Color(0xFFD5DDE9));
                    }
                    return BorderSide.none;
                  }),
                  elevation: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.disabled) || loading) {
                      return 0;
                    }
                    return 6;
                  }),
                ),
          ),
        ),
      ],
    );
  }
}

class _EmptyPicker extends StatelessWidget {
  const _EmptyPicker({super.key, required this.onPick});

  final ValueChanged<ImagePickSource> onPick;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        color: AppColors.surface,
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.24),
          width: 1.4,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F101A33),
            blurRadius: 22,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: 0.1),
            ),
            child: const Icon(
              Icons.add_photo_alternate_outlined,
              size: 32,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            AppStrings.quickCheckImageEmptyTitle,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            AppStrings.quickCheckImageEmptySubtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              height: 1.55,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _PickButton(
                  icon: Icons.photo_library_outlined,
                  label: AppStrings.quickCheckPickGallery,
                  primary: true,
                  onTap: () => onPick(ImagePickSource.gallery),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _PickButton(
                  icon: Icons.photo_camera_outlined,
                  label: AppStrings.quickCheckPickCamera,
                  primary: false,
                  onTap: () => onPick(ImagePickSource.camera),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PickButton extends StatelessWidget {
  const _PickButton({
    required this.icon,
    required this.label,
    required this.primary,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool primary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: primary
          ? FilledButton.icon(
              onPressed: onTap,
              icon: Icon(icon, size: 20),
              label: Text(label),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                textStyle: const TextStyle(fontWeight: FontWeight.w700),
              ),
            )
          : OutlinedButton.icon(
              onPressed: onTap,
              icon: Icon(icon, size: 20),
              label: Text(label),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: BorderSide(
                  color: AppColors.primary.withValues(alpha: 0.4),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                textStyle: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
    );
  }
}

class _ImagePreview extends StatelessWidget {
  const _ImagePreview({
    super.key,
    required this.image,
    required this.loading,
    required this.onReplace,
    required this.onRemove,
  });

  final ImageAttachment image;
  final bool loading;
  final ValueChanged<ImagePickSource> onReplace;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        color: AppColors.surface,
        border: Border.all(
          color: AppColors.success.withValues(alpha: 0.35),
          width: 1.3,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F101A33),
            blurRadius: 22,
            offset: Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: _PreviewImage(bytes: image.bytes),
              ),
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    color: Colors.black.withValues(alpha: 0.55),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        size: 14,
                        color: Color(0xFF7BE3A0),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        image.formattedSize,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          fontFeatures: [FontFeature.tabularFigures()],
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Material(
                  color: Colors.black.withValues(alpha: 0.55),
                  shape: const CircleBorder(),
                  child: IconButton(
                    tooltip: AppStrings.quickCheckRemoveImage,
                    onPressed: loading ? null : onRemove,
                    icon: const Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: Row(
              children: [
                const Icon(
                  Icons.image_outlined,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    image.fileName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: loading
                      ? null
                      : () => onReplace(ImagePickSource.gallery),
                  icon: const Icon(Icons.swap_horiz_rounded, size: 18),
                  label: const Text(AppStrings.quickCheckReplaceImage),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    textStyle: const TextStyle(fontWeight: FontWeight.w700),
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

class _PreviewImage extends StatelessWidget {
  const _PreviewImage({required this.bytes});

  final Uint8List bytes;

  @override
  Widget build(BuildContext context) {
    return Image.memory(
      bytes,
      fit: BoxFit.cover,
      gaplessPlayback: true,
      errorBuilder: (_, _, _) => Container(
        color: AppColors.neutral.withValues(alpha: 0.14),
        child: const Center(
          child: Icon(
            Icons.broken_image_outlined,
            size: 44,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _CaptionField extends StatelessWidget {
  const _CaptionField({
    required this.controller,
    required this.error,
    required this.loading,
    required this.onClear,
  });

  final TextEditingController controller;
  final String? error;
  final bool loading;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: AppColors.surface,
        border: Border.all(
          color: error != null
              ? AppColors.danger.withValues(alpha: 0.45)
              : AppColors.neutral.withValues(alpha: 0.22),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(
                Icons.edit_note_outlined,
                size: 19,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  AppStrings.quickCheckCaptionLabel,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (controller.text.isNotEmpty)
                IconButton(
                  tooltip: AppStrings.quickCheckClear,
                  onPressed: loading ? null : onClear,
                  style: IconButton.styleFrom(
                    minimumSize: const Size(32, 32),
                    foregroundColor: AppColors.textSecondary,
                  ),
                  icon: const Icon(Icons.clear_rounded, size: 17),
                ),
            ],
          ),
          TextField(
            controller: controller,
            enabled: !loading,
            minLines: 2,
            maxLines: 4,
            maxLength: VerifyClaim.maxLength,
            decoration: const InputDecoration(
              hintText: AppStrings.quickCheckCaptionHint,
              hintStyle: TextStyle(
                fontSize: 13,
                height: 1.55,
                color: AppColors.textSecondary,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              counterText: '',
            ),
            style: const TextStyle(
              fontSize: 14,
              height: 1.6,
              color: AppColors.textPrimary,
            ),
          ),
          if (error case final message?) ...[
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 15,
                  color: AppColors.danger,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.danger,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
