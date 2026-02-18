class UserModel {
  final String? fullname;
  final String email;
  final String password;

  UserModel({
    this.fullname,
    required this.email,
    required this.password,
  });
}
