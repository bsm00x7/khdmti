class UserPostModel {
  final int? id;
  final DateTime? createdAt;
  final String idUser;
  final String postTitle;
  final bool isEnable;
  final bool? isAvailable;
  final String? description;
  final String? sourceId;

  const UserPostModel({
    this.id,
    this.createdAt,
    required this.idUser,
    required this.postTitle,
    required this.isEnable,
    this.isAvailable,
    this.description,
    this.sourceId,
  });

  factory UserPostModel.fromJson(Map<String, dynamic> json) {
    return UserPostModel(
      id: json['id'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      idUser: json['id_user'],
      postTitle: json['postTitle'],
      isEnable: json['isEnable'],
      isAvailable: json['isAvailable'],
      description: json['discription'], // ← schema typo preserved
      sourceId: json['sourceId'],
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'id_user': idUser,
        'postTitle': postTitle,
        'isEnable': isEnable,
        'isAvailable': isAvailable,
        'discription': description, // ← schema typo preserved
        'sourceId': sourceId,
      };

  UserPostModel copyWith({
    bool? isEnable,
    bool? isAvailable,
    String? postTitle,
    String? description,
    String? sourceId,
  }) {
    return UserPostModel(
      id: id,
      createdAt: createdAt,
      idUser: idUser,
      postTitle: postTitle ?? this.postTitle,
      isEnable: isEnable ?? this.isEnable,
      isAvailable: isAvailable ?? this.isAvailable,
      description: description ?? this.description,
      sourceId: sourceId ?? this.sourceId,
    );
  }
}
