class UserModel {
  final String? firstName;
  final String? lastName;
  final String email;
  final String password;

  UserModel({
    this.firstName,
    this.lastName,
    required this.email,
    required this.password,
  });
}
