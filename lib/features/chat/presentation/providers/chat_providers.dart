import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/api_key_resolver.dart';
import '../../data/datasources/gemini_chat_datasource.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../domain/usecases/send_chat_message.dart';

final geminiChatDatasourceProvider = Provider<GeminiChatDatasource>((ref) {
  final status = ref.watch(apiKeyStatusProvider).valueOrNull;
  return GeminiChatDatasource(apiKey: status?.key ?? '');
});

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  // Closure live agar kunci BYOK yang baru disimpan langsung dipakai
  // request berikutnya tanpa restart layar chat.
  String resolveKey() =>
      ref.read(apiKeyStatusProvider).valueOrNull?.key ?? '';
  bool hasKey() =>
      ref.read(apiKeyStatusProvider).valueOrNull?.configured ?? false;
  return ChatRepositoryImpl(
    ref.watch(geminiChatDatasourceProvider),
    resolveApiKey: resolveKey,
    hasApiKey: hasKey,
  );
});

final sendChatMessageProvider = Provider<SendChatMessage>((ref) {
  return SendChatMessage(ref.watch(chatRepositoryProvider));
});

/// True bila kunci API tersedia (compile atau user): dipakai UI untuk
/// menampilkan banner pratinjau sekali-lihat, bukan error mentah setelah kirim.
final chatKeyConfiguredProvider = Provider<bool>((ref) {
  return ref.watch(apiKeyStatusProvider).valueOrNull?.configured ?? false;
});

/// State chat: daftar pesan + status kirim.
///
/// Pesan pengguna tampil optimistis langsung, bubble AI "mengetik" diganti
/// respons asli saat selesai. Kegagalan menandai pesan AI gagal + retry per
/// pesan tanpa menghapus riwayat.
class ChatState {
  const ChatState({this.messages = const [], this.sending = false});

  final List<ChatMessage> messages;
  final bool sending;
}

final chatControllerProvider =
    NotifierProvider<ChatController, ChatState>(ChatController.new);

class ChatController extends Notifier<ChatState> {
  int _counter = 0;

  @override
  ChatState build() => const ChatState();

  Future<void> send(String rawMessage) async {
    if (state.sending) return;
    final text = rawMessage.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (text.isEmpty) return;
    final userMessage = ChatMessage(
      id: 'user-${_counter++}-${DateTime.now().microsecondsSinceEpoch}',
      role: ChatRole.user,
      text: text,
      createdAt: DateTime.now(),
    );
    final typing = ChatMessage(
      id: 'ai-${_counter++}-${DateTime.now().microsecondsSinceEpoch}',
      role: ChatRole.ai,
      text: '',
      createdAt: DateTime.now(),
      verifySeed: text,
    );
    state = ChatState(messages: [...state.messages, userMessage, typing]);
    await _resolve(typing.id, seed: text);
  }

  Future<void> retry(String failedId) async {
    if (state.sending) return;
    final index = state.messages.indexWhere((m) => m.id == failedId);
    if (index < 0) return;
    final failed = state.messages[index];
    if (failed.role != ChatRole.ai || !failed.isFailed) return;
    final seed = failed.verifySeed ?? _seedFor(index);
    final typing = failed.copyWith(text: '', status: ChatStatus.sent);
    final updated = [...state.messages];
    updated[index] = typing;
    state = ChatState(messages: updated);
    await _resolve(typing.id, seed: seed);
  }

  void clear() {
    if (state.sending) return;
    state = const ChatState();
  }

  Future<void> _resolve(String typingId, {required String seed}) async {
    state = ChatState(messages: state.messages, sending: true);
    try {
      final history = state.messages
          .where((m) => m.id != typingId && m.text.isNotEmpty)
          .toList();
      final answer = await ref
          .read(sendChatMessageProvider)
          .call(history: history, rawMessage: seed);
      _replace(
        typingId,
        (m) => m.copyWith(text: answer, status: ChatStatus.sent),
      );
    } catch (error) {
      final message = error is Failure
          ? error.message
          : 'Pesan gagal dikirim. Coba lagi.';
      _replace(
        typingId,
        (m) => m.copyWith(text: message, status: ChatStatus.failed),
      );
    } finally {
      state = ChatState(messages: state.messages);
    }
  }

  void _replace(String id, ChatMessage Function(ChatMessage) update) {
    final updated = state.messages
        .map((m) => m.id == id ? update(m) : m)
        .toList(growable: false);
    state = ChatState(messages: updated, sending: state.sending);
  }

  String _seedFor(int aiIndex) {
    for (var i = aiIndex - 1; i >= 0; i--) {
      final candidate = state.messages[i];
      if (candidate.isUser && candidate.text.isNotEmpty) {
        return candidate.text;
      }
    }
    return '';
  }
}
