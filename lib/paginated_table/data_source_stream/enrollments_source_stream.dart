import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enrollease_web/paginated_table/table/enrollments_table.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void enrollmentsSourceStream(
  BuildContext context,
  StreamController<List<Map<String, dynamic>>> streamController,
  String searchQuery, // Accept searchQuery as a parameter
  TableEnrollmentStatus eStatus,
) {
  if (streamController.isClosed) return;
  // dPrint('New e status is $eStatus');
  final collectionRef = eStatus == TableEnrollmentStatus.any
      ? FirebaseFirestore.instance.collection('enrollment_forms').orderBy('timestamp')
      : FirebaseFirestore.instance
          .collection('enrollment_forms')
          .where(
            'status',
            isEqualTo: eStatus.name,
          )
          .orderBy('timestamp');

  collectionRef.snapshots().listen(
    (snapshot) {
      if (streamController.isClosed) return;

      // Map documents and filter based on search query
      final data = snapshot.docs.map((doc) {
        final docData = doc.data();
        return {
          'address': docData['address'],
          'motherTongue': docData['motherTongue'],
          'civilStatus': docData['civilStatus'],
          'ipOrIcc': docData['ipOrIcc'],
          'regNo': docData['regNo'],
          'firstName': docData['firstName'],
          'lastName': docData['lastName'],
          'middleName': docData['middleName'],
          'lrn': docData['lrn'],
          'gender': docData['gender'],
          'enrollingGrade': docData['enrollingGrade'],
          'age': docData['age'],
          'dateOfBirth': docData['dateOfBirth'],
          'placeOfBirth': docData['placeOfBirth'],
          'religion': docData['religion'],
          'sdaBaptismDate': docData['sdaBaptismDate'],
          'cellno': docData['cellno'],
          'lastSchoolAttended': docData['lastSchoolAttended'],
          'unpaidBill': docData['unpaidBill'],
          'parentsUserId': docData['parentsUserId'],
          'fathersFirstName': docData['fathersFirstName'],
          'fathersMiddleName': docData['fathersMiddleName'],
          'fathersLastName': docData['fathersLastName'],
          'fathersOcc': docData['fathersOcc'],
          'mothersFirstName': docData['mothersFirstName'],
          'mothersMiddleName': docData['mothersMiddleName'],
          'mothersLastName': docData['mothersLastName'],
          'mothersOcc': docData['mothersOcc'],
          'form138Link': docData['form138Link'],
          'cocLink': docData['cocLink'],
          'birthCertLink': docData['birthCertLink'],
          'goodMoralLink': docData['goodMoralLink'],
          'sigOverNameLink': docData['sigOverNameLink'],
          'status': docData['status'],
          'additionalInfo': docData['additionalInfo'],
          'timestamp': docData['timestamp'],
        };
      }).where((item) {
        // Filter based on search query
        final regNo = item['regNo'] ?? '';
        final studentFullName = '${item['firstName']}${item['middleName']}${item['lastName']}';
        final enrollingGrade = item['enrollingGrade'] ?? '';

        return regNo.trim().toLowerCase().contains(searchQuery.trim().toLowerCase()) ||
            studentFullName.trim().toLowerCase().contains(searchQuery.trim().toLowerCase()) ||
            enrollingGrade.trim().toLowerCase().contains(
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
