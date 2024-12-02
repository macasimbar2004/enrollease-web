import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void approvedformsStreamSource(
  BuildContext context,
  StreamController<List<Map<String, dynamic>>> streamController,
  String searchQuery, // Accept searchQuery as a parameter
) {
  if (streamController.isClosed) return;

  final collectionRef = FirebaseFirestore.instance.collection('enrollment_forms').orderBy('timestamp', descending: false);

  collectionRef.snapshots().listen(
    (snapshot) {
      if (streamController.isClosed) return;

      // Map documents and filter based on search query
      final data = snapshot.docs
          .map((doc) {
            final docData = doc.data();

            // Only process the document if the status is 'approved'
            if (docData['status'] != 'approved') {
              return null; // Skip this document if it's not approved
            }

            return {
              'additionalInfo': docData['additionalInfo'],
              'age': docData['age'],
              'barangay': docData['barangay'],
              'city': docData['city'],
              'dateOfBirth': docData['dateOfBirth'],
              'email': docData['email'],
              'gender': docData['gender'],
              'gradeLevelToApply': docData['gradeLevelToApply'],
              'parentsOrGuardianName': docData['parentsOrGuardianName'],
              'parentsUserId': docData['parentsUserId'],
              'phoneNumber': docData['phoneNumber'],
              'previousSchool': docData['previousSchool'],
              'province': docData['province'],
              'regNo': docData['regNo'],
              'studentFullName': docData['studentFullName'],
              'timestamp': docData['timestamp'],
              'zipCode': docData['zipCode'],
            };
          })
          .where((item) => item != null) // Remove null values
          .map((item) => item!) // Safely unwrap the non-null items
          .where((item) {
            // Filter based on search query
            final regNo = item['regNo'] ?? '';
            final studentFullName = item['studentFullName'] ?? '';
            final gradeLevelToApply = item['gradeLevelToApply'] ?? '';
            final gender = item['gender'] ?? '';

            return regNo.trim().toLowerCase().contains(searchQuery.trim().toLowerCase()) || studentFullName.trim().toLowerCase().contains(searchQuery.trim().toLowerCase()) || gradeLevelToApply.trim().toLowerCase().contains(searchQuery.trim().toLowerCase()) || gender.trim().toLowerCase().contains(searchQuery.trim().toLowerCase());
          })
          .toList();

      streamController.add(data);
    },
    onError: (error) {
      if (kDebugMode) {
        print('Error listening to Firestore updates: $error');
      }
    },
  );
}
