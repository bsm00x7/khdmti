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

  /// Create object from Supabase JSON
  factory UserPostModel.fromJson(Map<String, dynamic> json) {
    return UserPostModel(
      id: json['id'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      idUser: json['id_user'],
      postTitle: json['postTitle'],
      isEnable: json['isEnable'],
      isAvailable: json['isAvailable'],
      description: json['discription'],
      sourceId: json['sourceId'],
    );
  }

  /// Convert object to JSON for insert/update
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'id_user': idUser,
      'postTitle': postTitle,
      'isEnable': isEnable,
      'isAvailable': isAvailable,
      'discription': description,
      'sourceId': sourceId,
    };
  }
}
