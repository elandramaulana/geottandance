// Model untuk user session data
class UserSession {
  final String token;
  final int userId;
  final String role;
  final bool isLoggedIn;

  UserSession({
    required this.token,
    required this.userId,
    required this.role,
    required this.isLoggedIn,
  });

  @override
  String toString() {
    return 'UserSession{userId: $userId, role: $role, isLoggedIn: $isLoggedIn, token: ${token.substring(0, 10)}...}';
  }

  // Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'token': token,
      'userId': userId,
      'role': role,
      'isLoggedIn': isLoggedIn,
    };
  }

  // Create from Map
  factory UserSession.fromMap(Map<String, dynamic> map) {
    return UserSession(
      token: map['token'] ?? '',
      userId: map['userId'] ?? 0,
      role: map['role'] ?? '',
      isLoggedIn: map['isLoggedIn'] ?? false,
    );
  }
}
