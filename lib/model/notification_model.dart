class NotificationModel {
  final String content;
  final String title;
  final bool isRead;
  final DateTime timestamp;
  final String type;
  final String uid;

  NotificationModel({
    required this.title,
    required this.content,
    required this.isRead,
    required this.timestamp,
    required this.type,
    required this.uid,
  });
}

enum NotificationProps {
  content,
  isRead,
  timestamp,
  type,
  uid,
  title,
}
