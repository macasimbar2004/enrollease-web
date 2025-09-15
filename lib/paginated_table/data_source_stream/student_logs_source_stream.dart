import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void studentLogsStreamSource(
  BuildContext context,
  StreamController<List<Map<String, dynamic>>> streamController,
  String searchQuery, // Accept searchQuery as a parameter
) {
  if (streamController.isClosed) return;
  final collectionRef = FirebaseFirestore.instance
      .collection('student_logs')
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
          'timestamp': docData['timestamp'],
          'type': docData['type'],
        };
        resultData.removeWhere((k, v) => v == null);
        return resultData;
      }).where((item) {
        // Filter based on search query
        final content = item['content'] ?? '';
        final type = item['type'] ?? '';
        return content
                .trim()
                .toLowerCase()
                .contains(searchQuery.trim().toLowerCase()) ||
            type
                .trim()
                .toLowerCase()
                .contains(searchQuery.trim().toLowerCase());
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
