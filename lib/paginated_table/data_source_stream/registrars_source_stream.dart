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
  String? userTypeFilter, // Accept userTypeFilter as a parameter
  List<String>? roleFilters, // Accept roleFilters as a parameter
) {
  if (streamController.isClosed) return;

  final collectionRef =
      FirebaseFirestore.instance.collection('faculty_staff').orderBy('id');

  collectionRef.snapshots().listen(
    (snapshot) {
      if (streamController.isClosed) return;

      // Map documents and filter based on search query
      final data = snapshot.docs.map((doc) {
        final docData = doc.data();

        return {
          'profilePicData': docData['profilePicData'],
          'id': docData['id'],
          'fullname':
              '${docData['firstName']} ${docData['middleName']} ${docData['lastName']}',
          'userType': docData['userType'] ?? 'Staff',
          'roles': docData['roles'] ?? ['Staff'],
          'gradeLevel': docData['gradeLevel'],
          'status': docData['status'] ?? 'active',
          'contact': docData['contact'],
          'actions': Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // View Button
              ElevatedButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) => RegistrarDialog(
                            editMode: true,
                            id: '',
                            registrar: RegistrarModel(
                              profilePicData: docData['profilePicData'],
                              profilePicLink: docData['profilePicLink'],
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
                              userType: docData['userType'],
                              roles: (docData['roles'] as List<dynamic>?)
                                  ?.cast<String>(),
                              status: docData['status'],
                              gradeLevel: docData['gradeLevel'],
                            ),
                          ));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                child: const Icon(
                  Icons.visibility,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),

              // Disable/Enable Button (Primary Action)
              ElevatedButton(
                onPressed: () async {
                  final currentStatus = docData['status'] ?? 'active';
                  final newStatus =
                      currentStatus == 'active' ? 'disabled' : 'active';
                  final actionText =
                      currentStatus == 'active' ? 'Disable' : 'Enable';

                  final confirmation = await showConfirmationDialog(
                      context: context,
                      title: '$actionText Account',
                      message:
                          'Are you sure you want to ${actionText.toLowerCase()} this account?\n\n'
                          '${currentStatus == 'active' ? 'The user will not be able to log in, but their data will be preserved.' : 'The user will be able to log in again.'}',
                      confirmText: actionText,
                      cancelText: 'Cancel');

                  if (confirmation != null && confirmation) {
                    await FirebaseFirestore.instance
                        .collection('faculty_staff')
                        .doc(docData['id'])
                        .update({'status': newStatus});
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: (docData['status'] ?? 'active') == 'active'
                      ? Colors.orange
                      : Colors.green,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                child: Icon(
                  (docData['status'] ?? 'active') == 'active'
                      ? Icons.block
                      : Icons.check_circle,
                  color: Colors.white,
                  size: 18,
                ),
              ),

              // Delete Button (Only show if user is disabled)
              if ((docData['status'] ?? 'active') == 'disabled') ...[
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () async {
                    // Show advanced warning dialog
                    final advancedConfirmation = await showConfirmationDialog(
                      context: context,
                      title: '⚠️ DANGER ZONE ⚠️',
                      message: 'PERMANENT DELETION WARNING\n\n'
                          'This action will:\n'
                          '• Permanently delete the user record\n'
                          '• Remove all associated data\n'
                          '• Break all audit trail references\n'
                          '• This action CANNOT be undone\n\n'
                          'Are you absolutely sure you want to proceed?',
                      confirmText: 'YES, DELETE PERMANENTLY',
                      cancelText: 'CANCEL',
                    );

                    if (advancedConfirmation != null && advancedConfirmation) {
                      // Final confirmation
                      final finalConfirmation = await showConfirmationDialog(
                        context: context,
                        title: 'Final Confirmation',
                        message: 'This is your last chance to cancel.\n\n'
                            'The user "${docData['firstName']} ${docData['lastName']}" will be permanently deleted.\n\n'
                            'Are you sure you want to proceed with permanent deletion?',
                        confirmText: 'CONFIRM DELETE',
                        cancelText: 'CANCEL',
                      );

                      if (finalConfirmation != null && finalConfirmation) {
                        await FirebaseFirestore.instance
                            .collection('faculty_staff')
                            .doc(docData['id'])
                            .delete();
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade800,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  child: const Icon(
                    Icons.delete_forever,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ],
            ],
          ),
        };
      }).where((item) {
        // Filter based on search query
        final id = item['id'] ?? '';
        final fullname = item['fullname'] ?? '';
        final contact = item['contact'] ?? '';
        final userType = item['userType'] ?? '';
        final roles = (item['roles'] as List<dynamic>?)?.cast<String>() ?? [];

        // Search filter
        final matchesSearch = id
                .trim()
                .toLowerCase()
                .contains(searchQuery.trim().toLowerCase()) ||
            fullname
                .trim()
                .toLowerCase()
                .contains(searchQuery.trim().toLowerCase()) ||
            contact
                .trim()
                .toLowerCase()
                .contains(searchQuery.trim().toLowerCase());

        // User type filter
        final matchesUserType =
            userTypeFilter == null || userType == userTypeFilter;

        // Role filter
        final matchesRole = roleFilters == null ||
            roleFilters.isEmpty ||
            roleFilters.any((filterRole) => roles.contains(filterRole));

        return matchesSearch && matchesUserType && matchesRole;
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
