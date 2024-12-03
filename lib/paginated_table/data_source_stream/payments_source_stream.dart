import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void paymentsStreamDataSource(
  BuildContext context,
  StreamController<List<Map<String, dynamic>>> streamController,
  String searchQuery, // Accept searchQuery as a parameter
) {
  if (streamController.isClosed) return;

  final collectionRef = FirebaseFirestore.instance.collection('registrars').orderBy('id');

  collectionRef.snapshots().listen(
    (snapshot) {
      if (streamController.isClosed) return;

      // Map documents and filter based on search query
      final data = snapshot.docs.map((doc) {
        final docData = doc.data();

        return {
          '': '',
        };
      }).where((item) {
        // Filter based on search query
        final id = item['id'] ?? '';
        final fullname = item['fullname'] ?? '';
        final contact = item['contact'] ?? '';

        return id.trim().toLowerCase().contains(searchQuery.trim().toLowerCase()) || fullname.trim().toLowerCase().contains(searchQuery.trim().toLowerCase()) || contact.trim().toLowerCase().contains(searchQuery.trim().toLowerCase());
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
