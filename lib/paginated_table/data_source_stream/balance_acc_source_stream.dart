import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enrollease_web/model/enrollment_form_model.dart';
import 'package:enrollease_web/model/fees_model.dart';
import 'package:enrollease_web/model/user_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void balanceAccStreamSource(
  BuildContext context,
  StreamController<List<Map<String, dynamic>>> streamController,
  String searchQuery, // Accept searchQuery as a parameter
  DateTimeRange range,
) {
  if (streamController.isClosed) return;
  final db = FirebaseFirestore.instance;
  final collectionRef = db
      .collection('balance_accounts')
      .where(
        'schoolYearStart',
        isGreaterThanOrEqualTo: range.start.year,
      )
      .where(
        'schoolYearStart',
        isLessThanOrEqualTo: range.end.year,
      );
  // final startOfYear = Timestamp.fromDate(DateTime(range.start.year, 1, 1));
  // final endOfYear = Timestamp.fromDate(DateTime(range.end.year, 12, 31, 23, 59, 59));

  // final collectionRef = db.collection('balance_accounts').where(
  //       'schoolYearStart',
  //       isGreaterThanOrEqualTo: startOfYear,
  //     )
  // .where(
  //   'schoolYearStart',
  //   isLessThanOrEqualTo: endOfYear,
  // );

  collectionRef.snapshots().listen(
    (snapshot) async {
      if (streamController.isClosed) return;

      try {
        // Use async mapping to handle await calls inside the listen
        var data = await Future.wait(snapshot.docs.map((doc) async {
          final docData = doc.data();
          // dPrint('Data was: ${docData}');

          // Fetch related documents asynchronously
          final parentDoc = await db.collection('users').doc(docData['parentID']).get();
          final pupilDoc = await db.collection('enrollment_forms').doc(docData['pupilID']).get();

          final parent = UserModel.fromMap(parentDoc.data()!);
          final pupil = EnrollmentFormModel.fromMap(pupilDoc.data()!);

          return {
            'id': doc.id,
            'schoolYearStart': docData['schoolYearStart'],
            'startingBalance': FeesModel.fromMap(docData['startingBalance']).toMap(),
            'remainingBalance': FeesModel.fromMap(docData['remainingBalance']).toMap(),
            'gradeLevel': docData['gradeLevel'],
            'parent': parent,
            'pupil': pupil,
            'tuitionDiscount': docData['tuitionDiscount'],
            'bookDiscount': docData['bookDiscount'],
          };
        }).toList());

        data = data.where((e) {
          final parent = e['parent'] as UserModel;
          final pupil = e['pupil'] as EnrollmentFormModel;
          final pupilName = '${pupil.firstName}${pupil.middleName}${pupil.lastName}';
          return parent.userName.contains(searchQuery) || pupilName.contains(searchQuery);
        }).toList();
        // Add mapped data to the stream
        streamController.add(data);
      } catch (error) {
        if (kDebugMode) {
          print('Error processing Firestore updates: $error');
        }
      }
    },
    onError: (error) {
      if (kDebugMode) {
        print('Error listening to Firestore updates: $error');
      }
    },
  );
}
