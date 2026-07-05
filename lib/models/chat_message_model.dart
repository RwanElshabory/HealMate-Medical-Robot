class ChatMessageModel {
  final int messageId;
  final int senderId;
  final int receiverId;
  final String type;
  final String contentPath;
  final DateTime sentAt;
  final bool isRead;

  ChatMessageModel({
    required this.messageId,
    required this.senderId,
    required this.receiverId,
    required this.type,
    required this.contentPath,
    required this.sentAt,
    required this.isRead,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      messageId: json["messageId"] ?? 0,
      senderId: json["senderId"] ?? 0,
      receiverId: json["receiverId"] ?? 0,
      type: json["type"] ?? "",
      contentPath: json["contentPath"] ?? json["contentUrl"] ?? "",
      sentAt: DateTime.tryParse(json["sentAt"] ?? "") ?? DateTime.now(),
      isRead: json["isRead"] ?? false,
    );
  }
}