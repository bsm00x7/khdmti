class MessageModel {
  final int? id;
  final String idChat;
  final String? idSender;
  final DateTime createdAt;
  final bool isDeleted;
  final String content;

  MessageModel({
    this.id,
    required this.idChat,
    this.idSender,
    DateTime? createdAt,
    this.isDeleted = false,
    this.content = '',
  }) : createdAt = createdAt ?? DateTime.now();

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as int?,
      idChat: json['idChat'] as String,
      idSender: json['idSender'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      isDeleted: json['isDeleted'] as bool? ?? false,
      content: json['content'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'idChat': idChat,
      if (idSender != null) 'idSender': idSender,
      'isDeleted': isDeleted,
      'content': content,
    };
  }

  MessageModel copyWith({
    int? id,
    String? idChat,
    String? idSender,
    DateTime? createdAt,
    bool? isDeleted,
    String? content,
  }) {
    return MessageModel(
      id: id ?? this.id,
      idChat: idChat ?? this.idChat,
      idSender: idSender ?? this.idSender,
      createdAt: createdAt ?? this.createdAt,
      isDeleted: isDeleted ?? this.isDeleted,
      content: content ?? this.content,
    );
  }
}
