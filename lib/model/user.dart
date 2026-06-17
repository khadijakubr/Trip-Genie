class UserModel {
  final String id;          // uid dari Firebase Auth
  final String name;        // nama display user
  final String email;       // email user

  UserModel({
    required this.id,
    required this.name,
    required this.email,
  });
}