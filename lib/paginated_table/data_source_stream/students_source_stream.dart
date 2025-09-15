import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

void studentsStreamDataSource(
  BuildContext context,
  StreamController<List<Map<String, dynamic>>> streamController,
  String searchQuery,
) {
  if (streamController.isClosed) return;

  final collectionRef = FirebaseFirestore.instance
      .collection('students')
      .orderBy('timestamp', descending: true);

  collectionRef.snapshots().listen(
    (snapshot) {
      if (streamController.isClosed) return;

      final data = snapshot.docs.map((doc) {
        final docData = doc.data();
        docData['id'] = doc.id;
        // Combine firstName and lastName for full name
        docData['fullName'] = '${docData['firstName']} ${docData['lastName']}';
        return docData;
      }).toList();

      // Apply search filter if query is not empty
      if (searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        data.removeWhere((item) {
          final firstName = item['firstName']?.toString().toLowerCase() ?? '';
          final lastName = item['lastName']?.toString().toLowerCase() ?? '';
          final id = item['id']?.toString().toLowerCase() ?? '';
          return !firstName.contains(query) &&
              !lastName.contains(query) &&
              !id.contains(query);
        });
      }

      streamController.add(data);
    },
    onError: (error) {
      if (streamController.isClosed) return;
      streamController.addError(error);
    },
  );
}
