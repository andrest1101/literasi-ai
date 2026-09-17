import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/gemini_chat_datasource.dart';

class ChatRepositoryImpl implements ChatRepository {
  ChatRepositoryImpl(this._datasource);

  final GeminiChatDatasource _datasource;

  @override
  Future<String> reply({
    required List<ChatMessage> history,
    required String message,
  }) => _datasource.reply(history: history, message: message);
}
