import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enrollease_web/utils/firebase_auth.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream of notifications for a specific user and user type
  Stream<List<NotificationModel>> getUserNotifications(String userId,
      {String? userType}) {
    try {
      debugPrint(
          'Fetching notifications for user: $userId, userType: $userType');
      return _firestore
          .collection('notifications')
          .where('userId', whereIn: [userId, ''])
          .orderBy('timestamp', descending: true)
          .snapshots()
          .handleError((error) {
            debugPrint('Error listening to Firestore updates: $error');
          })
          .map((snapshot) {
            debugPrint('Received \\${snapshot.docs.length} notifications');
            return snapshot.docs
                .map((doc) {
                  final data = doc.data();
                  // Only show global notifications if targetType matches userType or is all
                  if ((data['userId'] == '' && userType != null) &&
                      (data['targetType'] != userType &&
                          data['targetType'] != 'all')) {
                    return null;
                  }
                  // Per-user read tracking for global notifications
                  final List readBy = (data['readBy'] ?? []) as List;
                  final isRead = data['userId'] == userId
                      ? (data['isRead'] ?? false)
                      : readBy.contains(userId);
                  return NotificationModel(
                    id: doc.id,
                    userId: data['userId'] ?? '',
                    title: data['title'] ?? '',
                    message: data['message'] ?? '',
                    type: data['type'] ?? 'info',
                    isRead: isRead,
                    timestamp: (data['timestamp'] as Timestamp).toDate(),
                    relatedDocId: data['relatedDocId'],
                    targetType: data['targetType'],
                    readBy: List<String>.from(readBy),
                  );
                })
                .where((notif) => notif != null)
                .cast<NotificationModel>()
                .toList();
          });
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
      return Stream.value([]);
    }
  }

  // Get notification count for a user (per-user unread tracking)
  Stream<int> getUnreadNotificationCount(String userId, {String? userType}) {
    try {
      debugPrint('Fetching unread notification count for user: $userId');
      return _firestore
          .collection('notifications')
          .where('userId', whereIn: [userId, ''])
          .orderBy('timestamp', descending: true)
          .snapshots()
          .handleError((error) {
            debugPrint('Error listening to Firestore updates: $error');
          })
          .map((snapshot) {
            int count = 0;
            for (final doc in snapshot.docs) {
              final data = doc.data();
              if (data['userId'] == userId) {
                if (data['isRead'] == false) count++;
              } else {
                final List readBy = (data['readBy'] ?? []) as List;
                if (!(readBy.contains(userId))) count++;
              }
            }
            debugPrint('Found $count unread notifications');
            return count;
          });
    } catch (e) {
      debugPrint('Error fetching unread notification count: $e');
      return Stream.value(0);
    }
  }

  // Mark a notification as read (per-user for global)
  Future<void> markAsRead(String notificationId, String userId) async {
    try {
      debugPrint(
          'Marking notification as read: $notificationId for user: $userId');
      final doc = await _firestore
          .collection('notifications')
          .doc(notificationId)
          .get();
      final data = doc.data();
      if (data == null) return;
      if (data['userId'] == userId) {
        await _firestore
            .collection('notifications')
            .doc(notificationId)
            .update({'isRead': true});
      } else {
        await _firestore
            .collection('notifications')
            .doc(notificationId)
            .update({
          'readBy': FieldValue.arrayUnion([userId])
        });
      }
      debugPrint('Successfully marked notification as read');
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  // Mark all notifications as read for a user (per-user for global)
  Future<void> markAllAsRead(String userId) async {
    try {
      debugPrint('Marking all notifications as read for user: $userId');
      final batch = _firestore.batch();
      final notifications = await _firestore
          .collection('notifications')
          .where('userId', whereIn: [userId, '']).get();
      for (var doc in notifications.docs) {
        final data = doc.data();
        if (data['userId'] == userId) {
          batch.update(doc.reference, {'isRead': true});
        } else {
          batch.update(doc.reference, {
            'readBy': FieldValue.arrayUnion([userId])
          });
        }
      }
      await batch.commit();
      debugPrint('Successfully marked all notifications as read');
    } catch (e) {
      debugPrint('Error marking all notifications as read: $e');
    }
  }

  // Create a new notification (global or user-specific)
  Future<void> createNotification({
    required String userId,
    required String title,
    required String message,
    String type = 'info',
    String? relatedDocId,
    String? targetType, // 'registrar', 'parent', or 'all'
  }) async {
    try {
      debugPrint(
          'Creating new notification for user: $userId, targetType: $targetType');
      final notifId = await FirebaseAuthProvider().generateNewIdentification(
        collectionName: 'notifications',
        prefix: 'NOTIF',
        padding: 6,
        includeYear: true,
      );
      await _firestore.collection('notifications').doc(notifId).set({
        'userId': userId,
        'title': title,
        'message': message,
        'type': type,
        'isRead': false,
        'timestamp': FieldValue.serverTimestamp(),
        'relatedDocId': relatedDocId,
        'targetType': targetType ?? '',
        'readBy': [],
      });
      debugPrint('Successfully created notification');
    } catch (e) {
      debugPrint('Error creating notification: $e');
    }
  }

  // Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      debugPrint('Deleting notification: $notificationId');
      await _firestore.collection('notifications').doc(notificationId).delete();
      debugPrint('Successfully deleted notification');
    } catch (e) {
      debugPrint('Error deleting notification: $e');
    }
  }

  // Show a snackbar notification
  static void showSnackBar(BuildContext context, String message,
      {NotificationType type = NotificationType.info}) {
    Color backgroundColor;

    switch (type) {
      case NotificationType.success:
        backgroundColor = Colors.green;
        break;
      case NotificationType.warning:
        backgroundColor = Colors.orange;
        break;
      case NotificationType.error:
        backgroundColor = Colors.red;
        break;
      case NotificationType.info:
        backgroundColor = Colors.blue;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(10),
      ),
    );
  }
}

// Notification type enum
enum NotificationType {
  info,
  success,
  warning,
  error,
}

// Notification model
class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final DateTime timestamp;
  final String? relatedDocId;
  final String? targetType;
  final List<String> readBy;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.timestamp,
    this.relatedDocId,
    this.targetType,
    required this.readBy,
  });
}
