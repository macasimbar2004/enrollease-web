import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'dart:convert';
import '../model/chat_model.dart';
import 'package:flutter/foundation.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all conversations for a user
  Stream<List<Conversation>> getConversations(String userId) {
    return _firestore
        .collection('conversations')
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Conversation.fromMap(doc.data()))
          .toList();
    });
  }

  // Get messages for a specific conversation
  Stream<List<ChatMessage>> getMessages(String conversationId) {
    return _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ChatMessage.fromMap(doc.data()))
          .toList();
    });
  }

  // Convert image to base64
  Future<String> imageToBase64(dynamic imageData) async {
    if (imageData is String) {
      // For web: imageData is already a base64 string
      return imageData;
    } else if (imageData is File) {
      // For mobile: read file bytes
      final bytes = await imageData.readAsBytes();
      return base64Encode(bytes);
    }
    throw Exception('Unsupported image data type');
  }

  // Send a message
  Future<void> sendMessage({
    required String conversationId,
    required String senderId,
    required String senderName,
    required String content,
    dynamic imageData,
    String type = 'text',
  }) async {
    String contentToSend = content;
    if (imageData != null && type == 'image') {
      try {
        contentToSend = await imageToBase64(imageData);
      } catch (e) {
        debugPrint('Error converting image to base64: $e');
        return;
      }
    }

    final message = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: senderId,
      senderName: senderName,
      content: contentToSend,
      timestamp: DateTime.now(),
      type: type,
      isRead: false,
    );

    try {
      // Add message to conversation
      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .doc(message.id)
          .set(message.toMap());

      // Update conversation's last message
      await _firestore.collection('conversations').doc(conversationId).update({
        'lastMessage': type == 'image' ? '📷 Image' : content,
        'lastMessageTime': DateTime.now(),
        'lastSenderId': senderId,
        'hasUnread': true,
      });
    } catch (e) {
      debugPrint('Error sending message: $e');
    }
  }

  // Create a new conversation
  Future<String> createConversation(List<String> participants) async {
    final conversation = Conversation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      participants: participants,
      lastMessage: '',
      lastMessageTime: DateTime.now(),
    );

    await _firestore
        .collection('conversations')
        .doc(conversation.id)
        .set(conversation.toMap());

    return conversation.id;
  }

  // Mark messages as read
  Future<void> markMessagesAsRead(String conversationId, String userId) async {
    final messages = await _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .where('isRead', isEqualTo: false)
        .where('senderId', isNotEqualTo: userId)
        .get();

    for (var doc in messages.docs) {
      await doc.reference.update({'isRead': true});
    }

    await _firestore.collection('conversations').doc(conversationId).update({
      'hasUnread': false,
    });
  }
}
