import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/api_key_resolver.dart';
import '../../../../core/utils/gemini_connectivity_probe.dart';
import '../../../chat/presentation/providers/chat_providers.dart';
import '../../../quick_check/data/datasources/gemini_text_datasource.dart';
import '../../../quick_check/presentation/providers/verification_provider.dart';
import '../../../quick_check/presentation/widgets/session_back_button.dart';

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
                  loading: () => const _StatusHero(
                    icon: Icons.hourglass_empty_rounded,
                    title: AppStrings.apiKeyChecking,
                    subtitle: null,
                    accent: AppColors.textSecondary,
                  ),
                  error: (_, _) => const _StatusHero(
                    icon: Icons.error_outline_rounded,
                    title: AppStrings.apiKeySaveFailed,
                    subtitle: null,
                    accent: AppColors.danger,
                  ),
                  data: (value) {
                    final live = value.configured;
                    return _StatusHero(
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
                const SizedBox(height: 16),
                _TestCard(
                  testing: _testing,
                  testOk: _testOk,
                  testSteps: _testSteps,
                  testResult: _testResult,
                  onTest: _testConnection,
                ),
                const SizedBox(height: 16),
                _KeyFormCard(
                  controller: _controller,
                  obscure: _obscure,
                  localError: _localError,
                  saving: _saving,
                  onToggleObscure: () => setState(() => _obscure = !_obscure),
                  onSave: _save,
                  onRemove: _confirmRemove,
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

/// Hero status: ikon besar + label sumber + sublabel mask.
///
/// Fokal layar: user langsung tahu AI Live atau Mode Demo tanpa membaca
/// kartu kecil. Warna mengikuti makna (hijau live, amber demo); warna
/// status tidak dipakai di tempat lain di layar ini agar tidak bersaing.
class _StatusHero extends StatelessWidget {
  const _StatusHero({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: accent.withValues(alpha: 0.08),
        border: Border.all(color: accent.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(17),
              color: accent.withValues(alpha: 0.15),
            ),
            child: Icon(icon, size: 27, color: accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.6,
                      color: AppColors.textSecondary,
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

/// Kartu tes koneksi: CTA + daftar hasil per tahap probe.
///
/// Meningkatkan data yang selama ini dibuang: tiap tahap (DNS/TCP/HTTPS/
/// generate) tampil sebagai baris ikon OK/GAGAL + durasi, bukan satu
/// string panjang. Kesimpulan + durasi tahap terlama tetap di atas
/// sebagai ringkasan.
class _TestCard extends StatelessWidget {
  const _TestCard({
    required this.testing,
    required this.testOk,
    required this.testSteps,
    required this.testResult,
    required this.onTest,
  });

  final bool testing;
  final bool? testOk;
  final List<GeminiProbeStep> testSteps;
  final String? testResult;
  final VoidCallback onTest;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: AppColors.surface,
        border: Border.all(color: AppColors.neutral.withValues(alpha: 0.2)),
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
          const Text(
            AppStrings.connectionTestTitle,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 50,
            child: FilledButton.icon(
              onPressed: testing ? null : onTest,
              icon: testing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.network_check_outlined, size: 19),
              label: Text(
                testing
                    ? AppStrings.connectionTestRunning
                    : AppStrings.connectionTestRun,
              ),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                textStyle: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
          if (testResult != null) ...[
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  testOk == true
                      ? Icons.check_circle_rounded
                      : Icons.error_outline_rounded,
                  size: 18,
                  color: testOk == true ? AppColors.success : AppColors.danger,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    testResult!,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.6,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (testSteps.isNotEmpty) ...[
            const SizedBox(height: 10),
            const Text(
              AppStrings.apiKeyProbeStepsTitle,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.4,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            for (var i = 0; i < testSteps.length; i++) ...[
              if (i > 0) const SizedBox(height: 6),
              _ProbeStepRow(step: testSteps[i]),
            ],
          ],
        ],
      ),
    );
  }
}

/// Satu baris hasil tahap probe: ikon status + nama + durasi tabular.
class _ProbeStepRow extends StatelessWidget {
  const _ProbeStepRow({required this.step});

  final GeminiProbeStep step;

  @override
  Widget build(BuildContext context) {
    final color = step.ok ? AppColors.success : AppColors.danger;
    final secs = (step.elapsed.inMilliseconds / 1000).toStringAsFixed(1);
    return Row(
      children: [
        Icon(
          step.ok ? Icons.check_circle_rounded : Icons.cancel_rounded,
          size: 17,
          color: color,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            step.name,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Text(
          '$secs dtk',
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}

/// Kartu form kelola kunci: field + simpan + hapus.
///
/// Satu-satunya kartu dengan CTA primer ganda: Simpan (primer) di atas,
/// Hapus (teks danger) di bawah. Tooltip tampil/sembunyi terpusat agar
/// tidak hardcode di widget.
class _KeyFormCard extends StatelessWidget {
  const _KeyFormCard({
    required this.controller,
    required this.obscure,
    required this.localError,
    required this.saving,
    required this.onToggleObscure,
    required this.onSave,
    required this.onRemove,
  });

  final TextEditingController controller;
  final bool obscure;
  final String? localError;
  final bool saving;
  final VoidCallback onToggleObscure;
  final VoidCallback onSave;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: AppColors.surface,
        border: Border.all(color: AppColors.neutral.withValues(alpha: 0.2)),
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
          const Text(
            AppStrings.apiKeyFormTitle,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: controller,
            obscureText: obscure,
            autocorrect: false,
            enableSuggestions: false,
            decoration: InputDecoration(
              labelText: AppStrings.apiKeyFieldLabel,
              hintText: AppStrings.apiKeyFieldHint,
              errorText: localError,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              suffixIcon: IconButton(
                tooltip: obscure
                    ? AppStrings.apiKeyShowKey
                    : AppStrings.apiKeyHideKey,
                onPressed: onToggleObscure,
                icon: Icon(
                  obscure
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
              onPressed: saving ? null : onSave,
              icon: saving
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
                textStyle: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: saving ? null : onRemove,
            icon: const Icon(Icons.delete_outline_rounded, size: 18),
            label: const Text(AppStrings.apiKeyRemove),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
          ),
        ],
      ),
    );
  }
}
