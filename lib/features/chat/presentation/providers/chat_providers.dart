import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/api_key_resolver.dart';
import '../../data/datasources/chat_session_local_datasource.dart';
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
  String resolveKey() => ref.read(apiKeyStatusProvider).valueOrNull?.key ?? '';
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

final chatControllerProvider = NotifierProvider<ChatController, ChatState>(
  ChatController.new,
);

class ChatController extends Notifier<ChatState> {
  int _counter = 0;
  bool _stopped = false;

  ChatSessionLocalDatasource? _archiveDatasource;

  @override
  ChatState build() => const ChatState();

  Future<ChatSessionLocalDatasource?> _archive() async {
    final cached = _archiveDatasource;
    if (cached != null) return cached;
    try {
      final prefs = await SharedPreferences.getInstance();
      _archiveDatasource = ChatSessionLocalDatasource(prefs);
      return _archiveDatasource;
    } catch (_) {
      return null;
    }
  }

  /// Simpan daftar pesan berjalan sebagai arsip terakhir yang bisa dibuka lagi.
  Future<void> _persist(List<ChatMessage> messages) async {
    final ds = await _archive();
    if (ds == null) return;
    final archiveable = messages
        .where((m) => m.text.isNotEmpty && !m.isFailed)
        .toList(growable: false);
    if (archiveable.length >= 2) {
      await ds.save(
        ChatSessionArchive(savedAt: DateTime.now(), messages: archiveable),
      );
    }
  }

  Future<void> _persistCurrent() => _persist(state.messages);

  /// Arsip sesi terakhir bila JSON valid: null bila kosong/korup/belum ada.
  Future<ChatSessionArchive?> loadArchive() async {
    final ds = await _archive();
    return ds?.load();
  }

  /// Hapus arsip sesi terakhir dari perangkat.
  Future<void> clearArchive() async {
    final ds = await _archive();
    await ds?.clear();
  }

  /// Ganti pesan aktif dengan arsip: daftar pesan kembali ke sesi lama.
  void restoreArchive(ChatSessionArchive archive) {
    if (state.sending) return;
    state = ChatState(messages: List.of(archive.messages));
  }

  Future<void> send(String rawMessage) async {
    if (state.sending) return;
    _stopped = false;
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
    _stopped = false;
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

  /// Tulis ulang jawaban AI dengan pertanyaan sumber yang sama.
  Future<void> regenerate(String aiMessageId) async {
    if (state.sending) return;
    _stopped = false;
    final index = state.messages.indexWhere((m) => m.id == aiMessageId);
    if (index < 0) return;
    final target = state.messages[index];
    if (target.role != ChatRole.ai || target.text.isEmpty) return;
    final seed = target.verifySeed?.trim().isNotEmpty == true
        ? target.verifySeed!.trim()
        : _seedFor(index);
    if (seed.trim().isEmpty) return;
    final typing = target.copyWith(text: '', status: ChatStatus.sent);
    final updated = [...state.messages];
    updated[index] = typing;
    state = ChatState(messages: updated);
    await _resolve(typing.id, seed: seed);
  }

  /// Hentikan jawaban yang sedang dibuat: bubble mengetik dibatalkan,
  /// pesan user tetap ada, dan sesi bisa dipakai lagi tanpa menunggu.
  void stop() {
    if (!state.sending) return;
    _stopped = true;
    final updated = state.messages
        .where((m) => !(m.role == ChatRole.ai && m.text.isEmpty))
        .toList(growable: false);
    state = ChatState(messages: updated, sending: false);
  }

  /// Mulai baru: layar kosong seketika, arsip disimpan di belakang layar.
  ///
  /// Reset state sengaja sinkron agar UI tidak menunggu storage: pesan lama
  /// tetap bisa dipulihkan lewat tombol riwayat.
  void clear() {
    if (state.sending) return;
    final previous = state.messages;
    state = const ChatState();
    if (previous.length >= 2) {
      unawaited(_persist(previous));
    }
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
      if (_stopped) return;
      _replace(
        typingId,
        (m) => m.copyWith(text: answer, status: ChatStatus.sent),
      );
    } catch (error) {
      if (_stopped) return;
      final message = error is Failure
          ? error.message
          : 'Pesan gagal dikirim. Coba lagi.';
      _replace(
        typingId,
        (m) => m.copyWith(text: message, status: ChatStatus.failed),
      );
    } finally {
      _stopped = false;
      state = ChatState(messages: state.messages);
      await _persistCurrent();
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
