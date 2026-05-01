enum NotificationType {
  matchFound,
  claimRequest,
  verificationSuccess,
  verificationNotifyFinder,
  newMessage,
  returnConfirmed,
  accountBanned,
  expiryWarning,
}

class NotificationModel {
  const NotificationModel({
    required this.notificationId,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    this.postId,
    this.isRead = false,
  });

  final String notificationId;
  final String userId;
  final NotificationType type;
  final String title;
  final String body;
  final DateTime createdAt;
  final String? postId;
  final bool isRead;
}

