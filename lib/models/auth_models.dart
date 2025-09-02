// models/auth_models.dart

class LoginRequest {
  final String email;
  final String password;

  LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() {
    return {'email': email, 'password': password};
  }

  @override
  String toString() {
    return 'LoginRequest{email: $email, password: [HIDDEN]}';
  }
}

class LoginResponse {
  final String token;
  final int userId;
  final String role;

  LoginResponse({
    required this.token,
    required this.userId,
    required this.role,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'] ?? '',
      userId: json['user_id'] ?? 0,
      role: json['role'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'token': token, 'user_id': userId, 'role': role};
  }

  @override
  String toString() {
    return 'LoginResponse{userId: $userId, role: $role, token: ${token.length > 10 ? '${token.substring(0, 10)}...' : token}}';
  }
}

class User {
  final int id;
  final String name;
  final String email;
  final String? emailVerifiedAt;
  final String role;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.emailVerifiedAt,
    required this.role,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      emailVerifiedAt: json['email_verified_at'],
      role: json['role'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'email_verified_at': emailVerifiedAt,
      'role': role,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'User{id: $id, name: $name, email: $email, role: $role}';
  }
}
