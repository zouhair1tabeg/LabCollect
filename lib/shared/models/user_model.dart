/// User model for authentication
class UserModel {
  final String id;
  final String name;
  final String email;
  final String token;
  final String role;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.token,
    this.role = 'collector',
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      token: json['token'] as String,
      role: json['role'] as String? ?? 'collector',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'token': token,
      'role': role,
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? token,
    String? role,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      token: token ?? this.token,
      role: role ?? this.role,
    );
  }
}
