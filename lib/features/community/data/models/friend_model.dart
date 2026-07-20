class FriendModel {
  final int friendId;
  final String friendName;
  final String? friendAvatarUrl;

  FriendModel({
    required this.friendId,
    required this.friendName,
    this.friendAvatarUrl,
  });

  factory FriendModel.fromJson(Map<String, dynamic> json) {
    return FriendModel(
      friendId: json['friendId'] ?? 0,
      friendName: json['friendName'] ?? '',
      friendAvatarUrl: json['friendAvatarUrl'],
    );
  }
}
