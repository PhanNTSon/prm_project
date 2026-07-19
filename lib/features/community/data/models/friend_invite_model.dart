class FriendInviteModel {
  final int senderId;
  final String senderName;
  final String? senderAvatar;

  FriendInviteModel({
    required this.senderId,
    required this.senderName,
    this.senderAvatar,
  });

  factory FriendInviteModel.fromJson(Map<String, dynamic> json) {
    return FriendInviteModel(
      senderId: json['senderId'] ?? 0,
      senderName: json['senderName'] ?? '',
      senderAvatar: json['senderAvatar'],
    );
  }
}
