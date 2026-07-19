class MessageModel {
  final int? id;
  final String? senderId;
  final String? senderName;
  final String? receiverUsername;
  final String? content;
  final DateTime? sentAt;
  final bool isMine; // Thêm thuộc tính này để dễ dàng check UI

  MessageModel({
    this.id,
    this.senderId,
    this.senderName,
    this.receiverUsername,
    this.content,
    this.sentAt,
    this.isMine = false,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json, {String? currentUsername}) {
    final senderName = json['senderName'] ?? json['senderUsername'] ?? '';
    return MessageModel(
      id: json['id'] as int?,
      senderId: json['senderId']?.toString(),
      senderName: senderName,
      receiverUsername: json['receiverUsername']?.toString(),
      content: json['messageContent'] ?? json['content'] ?? '',
      sentAt: json['sentAt'] != null ? DateTime.tryParse(json['sentAt']) : null,
      isMine: currentUsername != null && senderName == currentUsername,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'senderId': senderId,
      'senderUsername': senderName,
      'receiverUsername': receiverUsername,
      'content': content,
    };
  }
}
