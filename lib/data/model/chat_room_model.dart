class ChatMessageModel {
  const ChatMessageModel({
    required this.messageId,
    required this.roomId,
    required this.senderUserId,
    required this.message,
    required this.createdAt,
    this.isReported = false,
  });

  final String messageId;
  final String roomId;
  final String senderUserId;
  final String message;
  final DateTime createdAt;
  final bool isReported;
}

class ChatRoomModel {
  ChatRoomModel({
    required this.roomId,
    required this.postId,
    required this.finderUserId,
    required this.claimantUserId,
    required this.createdAt,
    List<ChatMessageModel>? messages,
  }) : messages = messages ?? <ChatMessageModel>[];

  final String roomId;
  final String postId;
  final String finderUserId;
  final String claimantUserId;
  final DateTime createdAt;
  final List<ChatMessageModel> messages;
}
