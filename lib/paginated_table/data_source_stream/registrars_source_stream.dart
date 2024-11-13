import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void registrarsStreamDataSource(
  BuildContext context,
  StreamController<List<Map<String, dynamic>>> streamController,
  String searchQuery, // Accept searchQuery as a parameter
) {
  if (streamController.isClosed) return;

  final collectionRef = FirebaseFirestore.instance
      .collection('registrars')
      .orderBy('identification', descending: false);

  collectionRef.snapshots().listen(
    (snapshot) {
      if (streamController.isClosed) return;

      // Map documents and filter based on search query
      final data = snapshot.docs.map((doc) {
        final docData = doc.data();

        return {
          "identification": docData['identification'],
          "fullname":
              '${docData['firstName']} ${docData['middleName']} ${docData['lastName']}',
          "contact": docData['contact'],
          "actions": Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  // Action handling can be implemented here
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                child:
                    const Text('Edit', style: TextStyle(color: Colors.white)),
              ),
              ElevatedButton(
                onPressed: () {
                  // Action handling can be implemented here
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child:
                    const Text('Delete', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        };
      }).where((item) {
        // Filter based on search query
        final identification = item['identification'] ?? '';
        final fullname = item['fullname'] ?? '';
        final contact = item['contact'] ?? '';

        return identification
                .toLowerCase()
                .contains(searchQuery.toLowerCase()) ||
            fullname.toLowerCase().contains(searchQuery.toLowerCase()) ||
            contact.toLowerCase().contains(searchQuery.toLowerCase());
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
