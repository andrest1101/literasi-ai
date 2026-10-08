import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../quick_check/presentation/widgets/session_back_button.dart';
import '../../../score/presentation/screens/api_key_screen.dart';
import '../../domain/entities/chat_message.dart';
import '../../data/datasources/chat_session_local_datasource.dart';
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
    // Umpan balik taktil ringan saat mengirim: pola sama dengan hero Cek,
    // tile mode, dan navbar.
    HapticFeedback.lightImpact();
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

  /// Buka arsip percakapan terakhir: sesi lama tidak hilang saat "Mulai baru".
  Future<void> _openArchive() async {
    final notifier = ref.read(chatControllerProvider.notifier);
    final archive = await notifier.loadArchive();
    if (!mounted) return;
    if (archive == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.chatHistoryEmpty),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheetContext) => _ArchiveSheet(
        archive: archive,
        onContinue: () {
          Navigator.of(sheetContext).pop();
          notifier.restoreArchive(archive);
          _scrollToBottom();
          messenger.showSnackBar(
            const SnackBar(
              content: Text(AppStrings.chatArchiveRestored),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        onDelete: () async {
          Navigator.of(sheetContext).pop();
          await notifier.clearArchive();
          if (!context.mounted) return;
          messenger.showSnackBar(
            const SnackBar(
              content: Text(AppStrings.chatArchiveDeleted),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
    );
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
          _HistoryAction(onOpen: _openArchive),
          const SizedBox(width: 8),
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
                          final previous = index == 0
                              ? null
                              : chat.messages[index - 1];
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (_needsDateDivider(previous, message))
                                _DateDivider(date: message.createdAt),
                              ChatBubble(
                                message: message,
                                onRetry: () => ref
                                    .read(chatControllerProvider.notifier)
                                    .retry(message.id),
                                onRegenerate: message.role == ChatRole.ai
                                    ? () => ref
                                          .read(chatControllerProvider.notifier)
                                          .regenerate(message.id)
                                    : null,
                              ),
                            ],
                          );
                        },
                      ),
              ),
              _InputDock(
                controller: _inputController,
                sending: chat.sending,
                onSend: _send,
                onStop: () => ref.read(chatControllerProvider.notifier).stop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Pemisah tanggal: hanya muncul saat hari pesan berubah, supaya percakapan
/// panjang punya orientasi waktu tanpa mengulang label di tiap bubble.
class _DateDivider extends StatelessWidget {
  const _DateDivider({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          const Expanded(child: Divider(height: 1)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              _label(date),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const Expanded(child: Divider(height: 1)),
        ],
      ),
    );
  }

  static String _label(DateTime date) {
    final now = DateTime.now();
    final local = date.toLocal();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(local.year, local.month, local.day);
    final days = today.difference(target).inDays;
    if (days <= 0) return AppStrings.chatToday;
    if (days == 1) return AppStrings.chatYesterday;
    return '${local.day.toString().padLeft(2, '0')}/'
        '${local.month.toString().padLeft(2, '0')}/${local.year}';
  }
}

bool _needsDateDivider(ChatMessage? previous, ChatMessage current) {
  if (previous == null) return true;
  final a = previous.createdAt.toLocal();
  final b = current.createdAt.toLocal();
  return a.year != b.year || a.month != b.month || a.day != b.day;
}

/// Aksi riwayat di AppBar: membuka arsip percakapan terakhir.
///
/// Berdampingan dengan "Mulai baru" sehingga aksi hapus tidak lagi satu
///-satunya jalan keluar: sesi lama bisa dipulihkan kapan saja.
class _HistoryAction extends StatelessWidget {
  const _HistoryAction({required this.onOpen});

  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: AppStrings.chatHistoryTooltip,
      child: Tooltip(
        message: AppStrings.chatHistoryTooltip,
        child: Material(
          color: AppColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: onOpen,
            borderRadius: BorderRadius.circular(12),
            child: const Padding(
              padding: EdgeInsets.all(10),
              child: Icon(
                Icons.history_rounded,
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

/// Bottom sheet arsip: ringkasan singkat + lanjutkan atau hapus.
class _ArchiveSheet extends StatelessWidget {
  const _ArchiveSheet({
    required this.archive,
    required this.onContinue,
    required this.onDelete,
  });

  final ChatSessionArchive archive;
  final VoidCallback onContinue;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final preview = archive.messages
        .firstWhere((m) => m.isUser, orElse: () => archive.messages.first)
        .text;
    final answerCount = archive.messages.where((m) => !m.isUser).length;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.neutral.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              AppStrings.chatHistoryTitle,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.2,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              '${archive.messages.length} pesan · $answerCount jawaban',
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: AppColors.background,
                border: Border.all(
                  color: AppColors.neutral.withValues(alpha: 0.2),
                ),
              ),
              child: Text(
                preview,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              AppStrings.chatHistoryMeta,
              style: TextStyle(
                fontSize: 12,
                height: 1.5,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 50,
              child: FilledButton.icon(
                onPressed: onContinue,
                icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                label: const Text(AppStrings.chatHistoryContinue),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 48,
              child: TextButton.icon(
                onPressed: onDelete,
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  size: 18,
                  color: AppColors.danger,
                ),
                label: const Text(
                  AppStrings.chatHistoryDelete,
                  style: TextStyle(color: AppColors.danger),
                ),
              ),
            ),
          ],
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
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
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
          // Banner sempit: aksi turun ke bawah teks agar kolom tombol tidak
          // menggigit teks. Ambang 420px (bukan 340px) karena dua tombol
          // banner membutuhkan ~215px saat font aksesibilitas besar; pada
          // lebar 412-420px teks sempat tergigit hanya ~60px dan membungkus
          //undreds baris sehingga banner menutupi layar (RenderFlex
          // overflow). Di bawah ambang ini selalu susun bertumpuk; tablet
          // dan desktop tetap satu baris lewat maxWidth 680.
          if (constraints.maxWidth < 420) {
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

  // Label tombol banner dibatasi satu baris: lebar intrinsik yang tidak
  // terbatasi membuat teks menggigit kolom judul pada layar sempit.
  static const _bannerLabel = TextStyle(
    fontSize: 12.5,
    fontWeight: FontWeight.w800,
    color: Colors.white,
  );

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
                    Flexible(
                      child: Text(
                        AppStrings.apiKeyOpenSettings,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: _bannerLabel,
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
                    Flexible(
                      child: Text(
                        AppStrings.chatKeyCopy,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
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
    required this.onStop,
  });

  final TextEditingController controller;
  final bool sending;
  final ValueChanged<String> onSend;
  final VoidCallback onStop;

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
            onStop: onStop,
          ),
        ),
      ),
    );
  }
}
