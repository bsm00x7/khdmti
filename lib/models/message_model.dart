/// Matches table: public.message
/// Columns: id, created_at, "idChat", "isDeleted", content, "idSender"
class MessageModel {
  final int? id;
  final DateTime createdAt;
  final String idChat; // uuid — FK to chats."idChat"
  final bool isDeleted;
  final String content;
  final String?
      idSender; // uuid — FK to auth.users.id (nullable, default auth.uid())

  const MessageModel({
    this.id,
    DateTime? createdAt,
    required this.idChat,
    this.isDeleted = false,
    required this.content,
    this.idSender,
  }) : createdAt = createdAt ?? const _Now(); // handled below

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as int?,
      createdAt: DateTime.parse(json['created_at']),
      idChat: json['idChat'],
      isDeleted: json['isDeleted'] ?? false,
      content: json['content'],
      idSender: json['idSender'],
    );
  }

  /// Only send the fields required for INSERT.
  /// idSender  → omitted, DB defaults to auth.uid()
  /// isDeleted → omitted, DB defaults to false
  /// id        → omitted, DB auto-generates
  /// created_at→ omitted, DB defaults to now()
  Map<String, dynamic> toJson() => {
        'idChat': idChat,
        'content': content,
      };
}

// Workaround: const constructor can't call DateTime.now(),
// so we use a real default in the factory / named constructor.
class _Now implements DateTime {
  const _Now();
  @override
  noSuchMethod(i) => DateTime.now();
}
