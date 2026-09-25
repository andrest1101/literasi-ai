import '../entities/chat_message.dart';

/// Kontrak chat: riwayat dikirim agar AI punya konteks percakapan.
abstract class ChatRepository {
  Future<String> reply({
    required List<ChatMessage> history,
    required String message,
  });
}
