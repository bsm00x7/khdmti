class ChatModel {
  final String idChat;
  final String? idUser1; // nullable to match schema
  final String? idUser2; // nullable to match schema
  final DateTime createdAt;

  const ChatModel({
    required this.idChat,
    this.idUser1,
    this.idUser2,
    required this.createdAt,
  });

  factory ChatModel.fromJson(Map<dynamic, dynamic> json) {
    return ChatModel(
      idChat: json['idChat'].toString(),
      idUser1: json['idUser1'] as String?, // nullable
      idUser2: json['idUser2'] as String?, // nullable
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idChat': idChat,
      'idUser1': idUser1,
      'idUser2': idUser2,
      'created_at': createdAt.toIso8601String(),
    };
  }

  ChatModel copyWith({
    String? idChat,
    String? idUser1,
    String? idUser2,
    DateTime? createdAt,
  }) {
    return ChatModel(
      idChat: idChat ?? this.idChat,
      idUser1: idUser1 ?? this.idUser1,
      idUser2: idUser2 ?? this.idUser2,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
