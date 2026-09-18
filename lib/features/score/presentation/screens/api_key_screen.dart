import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/api_key_resolver.dart';
import '../../../quick_check/presentation/widgets/session_back_button.dart';

/// Pengaturan kunci API Gemini (BYOK) — untuk tester tanpa akses terminal.
///
/// Kunci user tersimpan di secure storage OS, tidak pernah di repo/build.
/// Prioritas: dart-define (developer) menang atas kunci user; layar ini
/// hanya aktif mengelola kunci user.
class ApiKeyScreen extends ConsumerStatefulWidget {
  const ApiKeyScreen({super.key});

  static const route = '/api-key';

  @override
  ConsumerState<ApiKeyScreen> createState() => _ApiKeyScreenState();
}

class _ApiKeyScreenState extends ConsumerState<ApiKeyScreen> {
  final _controller = TextEditingController();
  bool _obscure = true;
  String? _localError;
  bool _saving = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() {
      _saving = true;
      _localError = null;
    });
    final error = await ref
        .read(apiKeyControllerProvider.notifier)
        .save(_controller.text);
    if (!mounted) return;
    setState(() => _saving = false);
    if (error != null) {
      setState(() => _localError = error);
      return;
    }
    _controller.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(AppStrings.apiKeySaved),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _confirmRemove() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.apiKeyRemove),
        content: const Text(AppStrings.apiKeyRemoveConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(AppStrings.chatCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(AppStrings.apiKeyRemove),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(apiKeyControllerProvider.notifier).clearUserKey();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.apiKeyRemoved),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = ref.watch(apiKeyControllerProvider);
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
        title: const Text(AppStrings.apiKeySettingsTitle),
        centerTitle: false,
        titleTextStyle: const TextStyle(
          fontSize: 17,
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
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  AppStrings.apiKeySettingsSubtitle,
                  style: TextStyle(
                    fontSize: 13.5,
                    height: 1.6,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                status.when(
                  loading: () => const _StatusCard(
                    icon: Icons.hourglass_empty_rounded,
                    text: 'Memeriksa kunci...',
                    accent: AppColors.textSecondary,
                  ),
                  error: (_, _) => const _StatusCard(
                    icon: Icons.error_outline_rounded,
                    text: AppStrings.apiKeySaveFailed,
                    accent: AppColors.danger,
                  ),
                  data: (value) => _StatusCard(
                    icon: value.configured
                        ? Icons.check_circle_outline_rounded
                        : Icons.key_off_outlined,
                    text: switch (value.source) {
                      ApiKeySource.compileDefine =>
                        AppStrings.apiKeyActiveCompile,
                      ApiKeySource.userKey => AppStrings.apiKeyActiveUser,
                      ApiKeySource.none => AppStrings.apiKeyInactive,
                    },
                    accent: value.configured
                        ? AppColors.success
                        : AppColors.warning,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
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
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: _controller,
                        obscureText: _obscure,
                        autocorrect: false,
                        enableSuggestions: false,
                        decoration: InputDecoration(
                          labelText: AppStrings.apiKeyFieldLabel,
                          hintText: AppStrings.apiKeyFieldHint,
                          errorText: _localError,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          suffixIcon: IconButton(
                            tooltip: _obscure
                                ? 'Tampilkan kunci'
                                : 'Sembunyikan kunci',
                            onPressed: () =>
                                setState(() => _obscure = !_obscure),
                            icon: Icon(
                              _obscure
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 50,
                        child: FilledButton.icon(
                          onPressed: _saving ? null : _save,
                          icon: _saving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.save_outlined, size: 19),
                          label: const Text(AppStrings.apiKeySave),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: _saving ? null : _confirmRemove,
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          size: 18,
                        ),
                        label: const Text(AppStrings.apiKeyRemove),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.danger,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: AppColors.primary.withValues(alpha: 0.06),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 18,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.apiKeyHowToTitle,
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 3),
                            Text(
                              AppStrings.apiKeyHowToBody,
                              style: TextStyle(
                                fontSize: 12.5,
                                height: 1.6,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.icon,
    required this.text,
    required this.accent,
  });

  final IconData icon;
  final String text;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: accent.withValues(alpha: 0.08),
        border: Border.all(color: accent.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: accent),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
