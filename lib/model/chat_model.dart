import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String content; // Used for both text and base64 image
  final DateTime timestamp;
  final bool isRead;
  final String type; // 'text' or 'image'

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.timestamp,
    this.isRead = false,
    this.type = 'text',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderId': senderId,
      'senderName': senderName,
      'content': content,
      'timestamp': timestamp,
      'isRead': isRead,
      'type': type,
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    bool isReadValue = false;
    if (map['isRead'] is bool) {
      isReadValue = map['isRead'] as bool;
    } else if (map['isRead'] is Map) {
      isReadValue = false;
    } else {
      isReadValue = false;
    }
    return ChatMessage(
      id: map['id'] ?? '',
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      content: map['content'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      isRead: isReadValue,
      type: map['type'] ?? 'text',
    );
  }
}

class Conversation {
  final String id;
  final List<String> participants;
  final String lastMessage;
  final DateTime lastMessageTime;
  final bool hasUnread;
  final String? lastSenderId;

  Conversation({
    required this.id,
    required this.participants,
    required this.lastMessage,
    required this.lastMessageTime,
    this.hasUnread = false,
    this.lastSenderId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'participants': participants,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime,
      'hasUnread': hasUnread,
      'lastSenderId': lastSenderId,
    };
  }

  factory Conversation.fromMap(Map<String, dynamic> map) {
    return Conversation(
      id: map['id'] ?? '',
      participants: List<String>.from(map['participants'] ?? []),
      lastMessage: map['lastMessage'] ?? '',
      lastMessageTime: (map['lastMessageTime'] as Timestamp).toDate(),
      hasUnread: map['hasUnread'] ?? false,
      lastSenderId: map['lastSenderId'],
    );
  }
}
