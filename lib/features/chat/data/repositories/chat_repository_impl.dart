import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/demo_chat_datasource.dart';
import '../datasources/gemini_chat_datasource.dart';

class ChatRepositoryImpl implements ChatRepository {
  ChatRepositoryImpl(
    this._datasource, {
    DemoChatDatasource? demoDatasource,
    String Function()? resolveApiKey,
    bool Function()? hasApiKey,
  }) : _demoDatasource = demoDatasource ?? DemoChatDatasource(),
       _resolveApiKey = resolveApiKey ?? (() => _compileKey),
       _hasApiKey = hasApiKey ?? (() => _defaultHasKey(resolveApiKey));

  static bool _defaultHasKey(String Function()? resolve) =>
      (resolve?.call() ?? _compileKey).isNotEmpty;

  static const String _compileKey = String.fromEnvironment('GEMINI_API_KEY');

  final GeminiChatDatasource _datasource;
  final DemoChatDatasource _demoDatasource;
  final String Function() _resolveApiKey;
  final bool Function() _hasApiKey;

  @override
  Future<String> reply({
    required List<ChatMessage> history,
    required String message,
  }) {
    if (!_hasApiKey()) {
      return Future.value(_demoDatasource.reply(message));
    }
    return _datasource.replyWithKey(
      history: history,
      message: message,
      apiKey: _resolveApiKey(),
    );
  }
}
