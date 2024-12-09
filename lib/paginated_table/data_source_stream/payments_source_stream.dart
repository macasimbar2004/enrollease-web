import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enrollease_web/model/fees_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void paymentsStreamDataSource(
  BuildContext context,
  StreamController<List<Map<String, dynamic>>> streamController,
  String searchQuery, // Accept searchQuery as a parameter
  String balanceAccID,
) {
  if (streamController.isClosed) return;

  final collectionRef = FirebaseFirestore.instance.collection('payments').where('balanceAccID', isEqualTo: balanceAccID).orderBy('date');

  collectionRef.snapshots().listen(
    (snapshot) {
      if (streamController.isClosed) return;

      // Map documents and filter based on search query
      final data = snapshot.docs.map((doc) {
        final docData = doc.data();

        return {
          'id': docData['id'],
          'balanceAccID': docData['balanceAccID'],
          'or': docData['or'],
          'date': docData['date'],
          'amount': docData['amount'] == null ? null : FeesModel.fromMap(docData['amount']),
        };
      }).where((item) {
        // Filter based on search query
        final or = item['or'] ?? 0;

        return or.toString().trim().toLowerCase().contains(
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
