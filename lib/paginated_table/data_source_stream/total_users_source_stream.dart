import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void usersStreamDataSource(
  BuildContext context,
  StreamController<List<Map<String, dynamic>>> streamController,
  String searchQuery, // Accept searchQuery as a parameter
) {
  if (streamController.isClosed) return;

  final collectionRef = FirebaseFirestore.instance
      .collection('users')
      .orderBy('uid', descending: false);

  collectionRef.snapshots().listen(
    (snapshot) {
      if (streamController.isClosed) return;

      // Map documents and filter based on search query
      final data = snapshot.docs.map((doc) {
        final docData = doc.data();

        return {
          'uid': docData['uid'],
          'userName': docData['userName'],
          'contactNumber': docData['contactNumber'],
          'email': docData['email'],
          'isActive': docData['isActive'],
          'role': docData['role'],
          'actions': Row(
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
                    const Text('Remove', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        };
      }).where((item) {
        // Filter based on search query
        final uid = item['uid'] ?? '';
        final userName = item['userName'] ?? '';
        final contactNumber = item['contactNumber'] ?? '';
        final email = item['email'] ?? '';
        final role = item['role'] ?? '';

        return uid
                .trim()
                .toLowerCase()
                .contains(searchQuery.trim().toLowerCase()) ||
            userName
                .trim()
                .toLowerCase()
                .contains(searchQuery.trim().toLowerCase()) ||
            contactNumber
                .trim()
                .toLowerCase()
                .contains(searchQuery.trim().toLowerCase()) ||
            email
                .trim()
                .toLowerCase()
                .contains(searchQuery.trim().toLowerCase()) ||
            role
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
