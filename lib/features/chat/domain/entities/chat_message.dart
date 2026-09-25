/// Pesan chat: entity murni Dart, tanpa dependensi Flutter/Firebase.
///
/// [verifySeed] hanya diisi pada pesan AI: teks klaim pengguna yang memicu
/// respons tersebut, dipakai tombol "Verifikasi ini" untuk membuka sesi
/// Quick Check dengan konteks yang benar.
enum ChatRole { user, ai }

enum ChatStatus { sent, failed }

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.role,
    required this.text,
    required this.createdAt,
    this.status = ChatStatus.sent,
    this.verifySeed,
  });

  final String id;
  final ChatRole role;
  final String text;
  final DateTime createdAt;
  final ChatStatus status;
  final String? verifySeed;

  bool get isUser => role == ChatRole.user;
  bool get isFailed => status == ChatStatus.failed;

  ChatMessage copyWith({String? text, ChatStatus? status, String? verifySeed}) {
    return ChatMessage(
      id: id,
      role: role,
      text: text ?? this.text,
      createdAt: createdAt,
      status: status ?? this.status,
      verifySeed: verifySeed ?? this.verifySeed,
    );
  }
}
