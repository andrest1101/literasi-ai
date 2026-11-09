import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/api_key_resolver.dart';
import '../../../../core/utils/gemini_connectivity_probe.dart';
import '../../../../shared/widgets/app_medallion_dialog.dart';
import '../../../chat/presentation/providers/chat_providers.dart';
import '../../../quick_check/data/datasources/gemini_text_datasource.dart';
import '../../../quick_check/presentation/providers/verification_provider.dart';
import '../../../quick_check/presentation/widgets/session_back_button.dart';
import '../widgets/api_key_form_card.dart';
import '../widgets/api_key_status_hero.dart';
import '../widgets/api_key_test_card.dart';

/// Pengaturan kunci API Gemini (BYOK): untuk tester tanpa akses terminal.
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
  bool _testing = false;
  String? _testResult;
  bool? _testOk;
  List<GeminiProbeStep> _testSteps = const [];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Tes koneksi end-to-end via probe bertahap: DNS → TCP 443 → HTTPS →
  /// generate 1 kata. Hasil menunjuk tahap yang gagal (jaringan lokal,
  /// firewall proses, TLS/proxy, kunci, atau model): bukan sekadar
  /// "gagal" tanpa arah.
  Future<void> _testConnection() async {
    if (_testing) return;
    setState(() {
      _testing = true;
      _testResult = null;
      _testOk = null;
      _testSteps = const [];
    });
    final key = ref.read(apiKeyStatusProvider).valueOrNull?.key.trim() ?? '';
    if (key.isEmpty) {
      if (!mounted) return;
      setState(() {
        _testing = false;
        _testOk = false;
        _testResult = AppStrings.apiKeyInactive;
      });
      return;
    }
    final report = await GeminiConnectivityProbe.run(
      apiKey: key,
      modelName: GeminiTextDatasource.defaultModelName,
    );
    if (!mounted) return;
    final slowest = report.steps.fold<GeminiProbeStep?>(null, (a, b) {
      if (a == null) return b;
      return b.elapsed > a.elapsed ? b : a;
    });
    final total = slowest == null
        ? ''
        : ' (${(slowest.elapsed.inMilliseconds / 1000).toStringAsFixed(1)} dtk tahap terlama).';
    setState(() {
      _testing = false;
      _testOk = report.verdict == GeminiProbeVerdict.healthy;
      _testSteps = report.steps;
      _testResult =
          '${GeminiConnectivityProbe.adviceFor(report.verdict)}$total';
    });
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
    // Bangun ulang rantai key → datasource → repository agar banner Chat,
    // Quick Check, dan request berikutnya langsung memakai kunci baru.
    ref.invalidate(geminiTextDatasourceProvider);
    ref.invalidate(geminiVisionDatasourceProvider);
    ref.invalidate(verificationRepositoryProvider);
    ref.invalidate(geminiChatDatasourceProvider);
    ref.invalidate(chatRepositoryProvider);
    _controller.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(AppStrings.apiKeySaved),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _pasteKey() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final pasted = data?.text?.trim();
    if (!mounted || pasted == null || pasted.isEmpty) return;
    setState(() {
      _controller.text = pasted;
      _controller.selection = TextSelection.collapsed(offset: pasted.length);
      _localError = null;
      _testResult = null;
    });
  }

  Future<void> _confirmRemove() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AppMedallionDialog(
        icon: Icons.delete_outline_rounded,
        accent: AppColors.danger,
        title: AppStrings.apiKeyRemove,
        body: AppStrings.apiKeyRemoveConfirm,
        primaryLabel: AppStrings.apiKeyRemove,
        primaryDanger: true,
        onPrimary: () => Navigator.of(context).pop(true),
        secondaryLabel: AppStrings.chatCancel,
        onSecondary: () => Navigator.of(context).pop(false),
      ),
    );
    if (confirmed == true) {
      await ref.read(apiKeyControllerProvider.notifier).clearUserKey();
      ref.invalidate(geminiTextDatasourceProvider);
      ref.invalidate(geminiVisionDatasourceProvider);
      ref.invalidate(verificationRepositoryProvider);
      ref.invalidate(geminiChatDatasourceProvider);
      ref.invalidate(chatRepositoryProvider);
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
                  loading: () => const ApiKeyStatusHero(
                    icon: Icons.hourglass_empty_rounded,
                    title: AppStrings.apiKeyChecking,
                    subtitle: null,
                    accent: AppColors.textSecondary,
                  ),
                  error: (_, _) => const ApiKeyStatusHero(
                    icon: Icons.error_outline_rounded,
                    title: AppStrings.apiKeySaveFailed,
                    subtitle: null,
                    accent: AppColors.danger,
                  ),
                  data: (value) {
                    final live = value.configured;
                    return ApiKeyStatusHero(
                      icon: live
                          ? Icons.check_circle_outline_rounded
                          : Icons.key_off_outlined,
                      title: live
                          ? AppStrings.apiKeyStatusActive
                          : AppStrings.apiKeyStatusDemo,
                      subtitle: switch (value.source) {
                        ApiKeySource.compileDefine =>
                          AppStrings.apiKeyActiveCompile,
                        ApiKeySource.userKey => AppStrings.apiKeyActiveUser,
                        ApiKeySource.none => AppStrings.apiKeyInactive,
                      },
                      accent: live ? AppColors.success : AppColors.warning,
                    );
                  },
                ),
                const SizedBox(height: 22),
                ApiKeyFormCard(
                  controller: _controller,
                  obscure: _obscure,
                  localError: _localError,
                  saving: _saving,
                  onToggleObscure: () => setState(() => _obscure = !_obscure),
                  onPaste: _pasteKey,
                  onSave: _save,
                  onRemove: _confirmRemove,
                ),
                const SizedBox(height: 18),
                const Divider(height: 1, color: AppColors.hairline),
                const SizedBox(height: 18),
                ApiKeyTestCard(
                  testing: _testing,
                  testOk: _testOk,
                  testSteps: _testSteps,
                  testResult: _testResult,
                  canTest: status.valueOrNull?.configured ?? false,
                  onTest: _testConnection,
                ),
                const SizedBox(height: 18),
                const Divider(height: 1, color: AppColors.hairline),
                const SizedBox(height: 14),
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.lock_outline_rounded,
                      size: 17,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        AppStrings.apiKeySecureNote,
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(horizontal: 4),
                  childrenPadding: const EdgeInsets.fromLTRB(4, 0, 4, 14),
                  leading: const _HowToBadge(),
                  title: const Text(AppStrings.apiKeyHowToTitle),
                  children: const [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        AppStrings.apiKeyHowToBody,
                        style: TextStyle(
                          fontSize: 12.5,
                          height: 1.6,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    _HowToStep(
                      number: '1',
                      text: AppStrings.apiKeyHowToStepGoogle,
                    ),
                    _HowToStep(
                      number: '2',
                      text: AppStrings.apiKeyHowToStepCreate,
                    ),
                    _HowToStep(
                      number: '3',
                      text: AppStrings.apiKeyHowToStepTest,
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

/// Badge langkah 3 (how-to): selaras bahasa visual section badge 1 dan 2.
class _HowToBadge extends StatelessWidget {
  const _HowToBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 26,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary,
      ),
      child: const Text(
        '3',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }
}

/// Satu langkah cara mendapatkan kunci: angka kecil + teks.
class _HowToStep extends StatelessWidget {
  const _HowToStep({required this.number, required this.text});

  final String number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: 0.12),
            ),
            child: Text(
              number,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryDark,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12.5,
                height: 1.5,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
