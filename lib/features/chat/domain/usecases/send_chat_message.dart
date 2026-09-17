import '../../../../core/errors/failures.dart';
import '../entities/chat_message.dart';
import '../repositories/chat_repository.dart';

/// Validasi pesan chat sebelum dikirim ke AI.
///
/// Batas 1-1.000 karakter: cukup pendek agar hemat kuota free tier, cukup
/// panjang untuk pertanyaan literasi yang wajar.
class SendChatMessage {
  SendChatMessage(this._repository);

  final ChatRepository _repository;

  static const int maxLength = 1000;

  Future<String> call({
    required List<ChatMessage> history,
    required String rawMessage,
  }) async {
    final message = _normalize(rawMessage);
    if (message.isEmpty) {
      throw const UnknownFailure(
        'Tulis pertanyaan dulu sebelum dikirim ke AI.',
      );
    }
    if (message.length > maxLength) {
      throw const UnknownFailure(
        'Pertanyaan terlalu panjang. Batasi maksimal 1.000 karakter.',
      );
    }
    return _repository.reply(history: history, message: message);
  }

  String _normalize(String value) {
    return value.trim().replaceAll(RegExp(r'\s+'), ' ');
  }
}
