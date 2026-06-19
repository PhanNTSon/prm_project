class UserModel {
  final String userId;
  final String username;
  final String role;
  final String? avatarUrl;

  UserModel({
    required this.userId,
    required this.username,
    required this.role,
    this.avatarUrl,
  });

  /// Factory constructor khởi tạo đối tượng từ Map (JWT Payload)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      // Centurion JWT backend thường dùng 'sub' làm username
      username: json['sub'] ?? '',
      // userId có thể được map là 'userId' hoặc 'id' tùy cấu hình backend
      userId: json['userId']?.toString() ?? '',
      role: json['role'] ?? 'ROLE_USER',
      avatarUrl: json['avatarUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'sub': username,
      'role': role,
      'avatarUrl': avatarUrl,
    };
  }

  @override
  String toString() {
    return 'UserModel(userId: $userId, username: $username, role: $role)';
  }
}
