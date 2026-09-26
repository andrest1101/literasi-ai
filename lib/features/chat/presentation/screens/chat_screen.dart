import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../quick_check/presentation/widgets/session_back_button.dart';
import '../../../score/presentation/screens/api_key_screen.dart';
import '../providers/chat_providers.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_input_bar.dart';

/// Layar Chat AI: percakapan literasi digital dengan Gemini.
///
/// Identitas asisten digabung ke AppBar (back + avatar + nama + status +
/// aksi mulai baru) sehingga tidak ada presence bar kedua yang makan tempat.
/// Banner pratinjau muncul sekali-lihat bila kunci API belum tersambung,
/// dengan tombol salin perintah agar setup tetap fungsional.
class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  static const route = '/chat';

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _send(String text) {
    ref.read(chatControllerProvider.notifier).send(text);
    _inputController.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    });
  }

  Future<void> _confirmClear() async {
    final notifier = ref.read(chatControllerProvider.notifier);
    if (ref.read(chatControllerProvider).messages.isEmpty) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.chatClear),
        content: const Text(AppStrings.chatClearConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(AppStrings.chatCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(AppStrings.chatClear),
          ),
        ],
      ),
    );
    if (confirmed == true) notifier.clear();
  }

  @override
  Widget build(BuildContext context) {
    final chat = ref.watch(chatControllerProvider);
    final keyConfigured = ref.watch(chatKeyConfiguredProvider);
    ref.listen(chatControllerProvider, (_, next) {
      if (next.messages.isNotEmpty) _scrollToBottom();
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 68,
        leadingWidth: 56,
        // Lingkaran tonal SessionBackButton (dipakai bersama layar sesi
        // Quick Check): tanpa avatar header, komposisi kini seimbang
        // (lingkaran kiri + squircle aksi kanan membingkai teks), dan
        // lingkaran 40px memberi jarak napas alami ke teks di sampingnya.
        leading: SessionBackButton(
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        titleSpacing: 0,
        centerTitle: false,
        title: _IdentityTitle(keyConfigured: keyConfigured),
        actions: [
          _NewChatAction(onClear: _confirmClear),
          const SizedBox(width: 12),
        ],
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
          child: Column(
            children: [
              if (!keyConfigured) const _KeySetupBanner(),
              Expanded(
                child: chat.messages.isEmpty
                    ? _EmptyGreeting(onPick: _send)
                    : ListView.separated(
                        controller: _scrollController,
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                        itemCount: chat.messages.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 14),
                        itemBuilder: (context, index) {
                          final message = chat.messages[index];
                          return ChatBubble(
                            message: message,
                            onRetry: () => ref
                                .read(chatControllerProvider.notifier)
                                .retry(message.id),
                          );
                        },
                      ),
              ),
              _InputDock(
                controller: _inputController,
                sending: chat.sending,
                onSend: _send,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Identitas asisten di AppBar: nama + status kesiapan, tanpa avatar.
///
/// Avatar shield sengaja tidak dipasang di header: setiap bubble AI sudah
/// membawa avatar yang sama, sehingga shield ketiga di header hanya
/// menjadi pengulangan (pola chat profesional: nama + status saja).
/// Identitas visual tetap hidup di hero empty-state, FAB, dan bubble AI.
/// Subtitle kontekstual dari status kunci yang sudah ada (tanpa dot hijau
/// palsu, tanpa angka kuota yang tidak bisa diketahui client): live bila
/// tersambung, pratinjau bila belum.
class _IdentityTitle extends StatelessWidget {
  const _IdentityTitle({required this.keyConfigured});

  final bool keyConfigured;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          AppStrings.chatPresenceName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 1),
        Text(
          keyConfigured
              ? AppStrings.chatPresenceLive
              : AppStrings.chatPresencePreview,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _NewChatAction extends StatelessWidget {
  const _NewChatAction({required this.onClear});

  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: AppStrings.chatClear,
      child: Tooltip(
        message: AppStrings.chatClear,
        child: Material(
          color: AppColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: onClear,
            borderRadius: BorderRadius.circular(12),
            child: const Padding(
              padding: EdgeInsets.all(10),
              child: Icon(
                Icons.add_comment_outlined,
                size: 20,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Banner pratinjau sekali-lihat saat kunci API belum tersambung.
///
/// Muncul di atas daftar (bukan error merah setelah kirim): menjelaskan mode
/// pratinjau + tombol salin perintah run agar setup tetap bisa dilakukan
/// dari dalam app.
class _KeySetupBanner extends StatelessWidget {
  const _KeySetupBanner();

  Future<void> _copyCommand(BuildContext context) async {
    await Clipboard.setData(
      const ClipboardData(text: AppStrings.chatRunCommand),
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(AppStrings.chatKeyCopied),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: AppColors.primary.withValues(alpha: 0.06),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final copy = const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.chatKeyBannerTitle,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  AppStrings.chatKeyBannerSubtitle,
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.55,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
          final actions = _KeyBannerActions(
            onCopy: () => _copyCommand(context),
          );
          final icon = Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: AppColors.primary.withValues(alpha: 0.12),
            ),
            child: const Icon(
              Icons.key_outlined,
              size: 19,
              color: AppColors.primary,
            ),
          );
          // Banner sempit (<340px, mis. layar 360px): aksi full-width
          // di bawah teks agar kolom tombol tidak menjepit teks hingga
          // overflow; normal tetap satu baris (pola responsif yang sama
          // dengan hero Cek).
          if (constraints.maxWidth < 340) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [icon, const SizedBox(width: 11), copy],
                ),
                const SizedBox(height: 10),
                actions,
              ],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              icon,
              const SizedBox(width: 11),
              copy,
              const SizedBox(width: 8),
              actions,
            ],
          );
        },
      ),
    );
  }
}

/// Kolom aksi banner kunci (Buka Pengaturan + Salin perintah), dipakai
/// susunan baris maupun kolom oleh [_KeySetupBanner].
class _KeyBannerActions extends StatelessWidget {
  const _KeyBannerActions({required this.onCopy});

  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Semantics(
          button: true,
          label: AppStrings.apiKeyOpenSettings,
          child: Material(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: () => Navigator.of(context).pushNamed(ApiKeyScreen.route),
              borderRadius: BorderRadius.circular(12),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.key_outlined, size: 15, color: Colors.white),
                    SizedBox(width: 5),
                    Text(
                      AppStrings.apiKeyOpenSettings,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Semantics(
          button: true,
          label: AppStrings.chatKeyCopy,
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: onCopy,
              borderRadius: BorderRadius.circular(12),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.content_copy_rounded,
                      size: 14,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 5),
                    Text(
                      AppStrings.chatKeyCopy,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Sapaan kosong: avatar besar + judul + 3 saran sekali ketuk.
class _EmptyGreeting extends StatelessWidget {
  const _EmptyGreeting({required this.onPick});

  final ValueChanged<String> onPick;

  static const _suggestions = [
    AppStrings.chatSuggestion1,
    AppStrings.chatSuggestion2,
    AppStrings.chatSuggestion3,
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(27),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF2F80ED), Color(0xFF124A9B)],
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x331558B0),
                  blurRadius: 22,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              size: 36,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            AppStrings.chatGreetingTitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            AppStrings.chatGreetingSubtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.5,
              height: 1.6,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              for (final suggestion in _suggestions)
                _SuggestionChip(
                  text: suggestion,
                  onTap: () => onPick(suggestion),
                ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            AppStrings.chatDisclaimer,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11.5,
              height: 1.5,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  const _SuggestionChip({required this.text, required this.onTap});

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.28),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  text,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.north_east_rounded,
                size: 15,
                color: AppColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Dock input pinned bawah dengan hairline atas + SafeArea.
class _InputDock extends StatelessWidget {
  const _InputDock({
    required this.controller,
    required this.sending,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool sending;
  final ValueChanged<String> onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.neutral.withValues(alpha: 0.18)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
          child: ChatInputBar(
            controller: controller,
            sending: sending,
            onSend: onSend,
          ),
        ),
      ),
    );
  }
}
