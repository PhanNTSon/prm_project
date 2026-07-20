class UserSearchModel {
  final int userId;
  final String username;
  final String? avatarUrl;

  UserSearchModel({
    required this.userId,
    required this.username,
    this.avatarUrl,
  });

  factory UserSearchModel.fromJson(Map<String, dynamic> json) {
    return UserSearchModel(
      userId: json['userId'] ?? 0,
      username: json['username'] ?? '',
      avatarUrl: json['avatarUrl'],
    );
  }
}
