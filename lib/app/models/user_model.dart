class UserModel {
  final String id;
  final String name;
  final List<String> role;
  final String username;
  final String jwt;

  UserModel({
    required this.id,
    required this.name,
    required this.role,
    required this.username,
    required this.jwt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['nama'],
      role: List<String>.from(json['rolePengguna'] ?? []),
      username: json['username'],
      jwt: json['jwt'],
    );
  }
}