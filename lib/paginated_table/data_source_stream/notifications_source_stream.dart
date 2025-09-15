import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void notificationsStreamSource(
  BuildContext context,
  StreamController<List<Map<String, dynamic>>> streamController,
  String searchQuery, // Accept searchQuery as a parameter
) {
  if (streamController.isClosed) return;
  // final userID = context.read<AccountDataController>().currentRegistrar?.id;
  final collectionRef = FirebaseFirestore.instance
      .collection('notifications')
      .where(
        'type',
        isEqualTo: 'registrar',
      )
      .orderBy('timestamp', descending: true);

  collectionRef.snapshots().listen(
    (snapshot) {
      if (streamController.isClosed) return;

      // Map documents and filter based on search query
      final data = snapshot.docs.map((doc) {
        Map<String, dynamic> docData = doc.data();
        final resultData = {
          'id': doc.id,
          'content': docData['content'],
          'isRead': docData['isRead'],
          'timestamp': docData['timestamp'],
          'type': docData['type'],
          'uid': docData['uid'],
        };
        resultData.removeWhere((k, v) => v == null);
        return resultData;
      }).where((item) {
        // Filter based on search query
        final content = item['content'] ?? '';
        final title = item['title'] ?? '';
        return content.trim().toLowerCase().contains(searchQuery.trim().toLowerCase()) ||
            title.trim().toLowerCase().contains(
                  searchQuery.trim().toLowerCase(),
                );
      }).toList();

      streamController.add(data);
    },
    onError: (error) {
      if (kDebugMode) {
        print('Error listening to Firestore updates: $error');
      }
    },
  );
}
