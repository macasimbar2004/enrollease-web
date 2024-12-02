import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enrollease_web/model/registrar_model.dart';
import 'package:enrollease_web/widgets/custom_confirmation_dialog.dart';
import 'package:enrollease_web/widgets/registrar_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void registrarsStreamDataSource(
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
          'id': docData['id'],
          'fullname': '${docData['firstName']} ${docData['middleName']} ${docData['lastName']}',
          'contact': docData['contact'],
          'actions': Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) => RegistrarDialog(
                            editMode: true,
                            id: '',
                            registrar: RegistrarModel(
                              id: docData['id'],
                              lastName: docData['lastName'],
                              firstName: docData['firstName'],
                              middleName: docData['middleName'],
                              dateOfBirth: docData['dateOfBirth'],
                              age: docData['age'],
                              contact: docData['contact'],
                              placeOfBirth: docData['placeOfBirth'],
                              address: docData['address'],
                              email: docData['email'],
                              remarks: docData['remarks'],
                              password: docData['password'],
                            ),
                          ));
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                child: const Text('Edit', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () async {
                  final confirmation = await showConfirmationDialog(context: context, title: 'Delete confirmation', message: 'Delete this registrar?', confirmText: 'Yes', cancelText: 'No');
                  if (confirmation != null && confirmation) {
                    await FirebaseFirestore.instance.collection('registrars').doc(docData['id']).delete();
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Remove', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
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
