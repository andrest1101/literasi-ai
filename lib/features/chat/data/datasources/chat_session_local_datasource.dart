import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/chat_message.dart';

/// Satu sesi chat yang diarsipkan di SharedPreferences.
///
/// Pembacaan toleran korup: JSON rusak atau kosong menjadi null, bukan crash.
class ChatSessionArchive {
  const ChatSessionArchive({required this.savedAt, required this.messages});

  final DateTime savedAt;
  final List<ChatMessage> messages;

  Map<String, dynamic> toMap() => {
    'savedAt': savedAt.toIso8601String(),
    'messages': [
      for (final m in messages)
        {
          'id': m.id,
          'role': m.role.name,
          'text': m.text,
          'createdAt': m.createdAt.toIso8601String(),
          'status': m.status.name,
          if (m.verifySeed != null) 'verifySeed': m.verifySeed,
        },
    ],
  };

  static ChatSessionArchive? fromMap(Map<String, dynamic>? map) {
    if (map == null) return null;
    final rawMessages = map['messages'];
    final savedAt = DateTime.tryParse(map['savedAt']?.toString() ?? '');
    if (rawMessages is! List || savedAt == null) return null;
    final messages = <ChatMessage>[];
    for (final raw in rawMessages) {
      if (raw is! Map) continue;
      final createdAt = DateTime.tryParse(raw['createdAt']?.toString() ?? '');
      final role = switch (raw['role']?.toString()) {
        'user' => ChatRole.user,
        _ => ChatRole.ai,
      };
      final status = switch (raw['status']?.toString()) {
        'failed' => ChatStatus.failed,
        _ => ChatStatus.sent,
      };
      messages.add(
        ChatMessage(
          id: raw['id']?.toString() ?? 'm-${messages.length}',
          role: role,
          text: raw['text']?.toString() ?? '',
          createdAt: createdAt ?? DateTime.now(),
          status: status,
          verifySeed: raw['verifySeed']?.toString(),
        ),
      );
    }
    return messages.isEmpty
        ? null
        : ChatSessionArchive(savedAt: savedAt, messages: messages);
  }

  String encode() => jsonEncode(toMap());

  static ChatSessionArchive? decode(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      return fromMap(decoded is Map<String, dynamic> ? decoded : null);
    } catch (_) {
      return null;
    }
  }
}

/// Datasource lokal satu slot arsip: menyimpan sesi chat terakhir agar
/// tidak hilang saat "Mulai baru" maupun restart aplikasi.
class ChatSessionLocalDatasource {
  ChatSessionLocalDatasource(this._prefs);

  final SharedPreferences _prefs;

  static const String key = 'chat_last_session_v1';

  Future<void> save(ChatSessionArchive archive) async {
    await _prefs.setString(key, archive.encode());
  }

  ChatSessionArchive? load() =>
      ChatSessionArchive.decode(_prefs.getString(key));

  Future<void> clear() => _prefs.remove(key);
}
