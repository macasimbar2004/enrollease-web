import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class StudentModel {
  final String id;
  final String firstName;
  final String middleName;
  final String lastName;
  final String lrn;
  final String grade;
  final String age;
  final String dateOfBirth;
  final String placeOfBirth;
  final String religion;
  final String gender;
  final String address;
  final String motherTongue;
  final String civilStatus;
  final String ipOrIcc;
  final String sdaBaptismDate;
  final String cellno;
  final String lastSchoolAttended;
  final String parentsUserId;
  final String fathersFirstName;
  final String fathersMiddleName;
  final String fathersLastName;
  final String fathersOcc;
  final String mothersFirstName;
  final String mothersMiddleName;
  final String mothersLastName;
  final String mothersOcc;
  final String form138Link;
  final String cocLink;
  final String birthCertLink;
  final String goodMoralLink;
  final String sigOverNameLink;
  final String additionalInfo;
  final String status;
  final DateTime timestamp;

  StudentModel({
    required this.id,
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.lrn,
    required this.grade,
    required this.age,
    required this.dateOfBirth,
    required this.placeOfBirth,
    required this.religion,
    required this.gender,
    required this.address,
    required this.motherTongue,
    required this.civilStatus,
    required this.ipOrIcc,
    required this.sdaBaptismDate,
    required this.cellno,
    required this.lastSchoolAttended,
    required this.parentsUserId,
    required this.fathersFirstName,
    required this.fathersMiddleName,
    required this.fathersLastName,
    required this.fathersOcc,
    required this.mothersFirstName,
    required this.mothersMiddleName,
    required this.mothersLastName,
    required this.mothersOcc,
    required this.form138Link,
    required this.cocLink,
    required this.birthCertLink,
    required this.goodMoralLink,
    required this.sigOverNameLink,
    required this.additionalInfo,
    required this.status,
    required this.timestamp,
  });

  factory StudentModel.fromMap(Map<String, dynamic> map) {
    // Debug print to check map contents for debugging
    debugPrint('Creating StudentModel from map:');
    debugPrint('  id: ${map['id']}');
    debugPrint('  ALL KEYS: ${map.keys.toList()}');

    // Handle potential type issues for ALL fields by ensuring they're strings
    Map<String, dynamic> safeMap = {};

    // Copy all values to safe map, converting to strings as needed
    map.forEach((key, value) {
      if (value == null) {
        safeMap[key] = '';
      } else if (value is String) {
        safeMap[key] = value;
      } else if (value is int || value is double || value is bool) {
        safeMap[key] = value.toString();
      } else if (value is Timestamp) {
        // Keep timestamp objects as is for proper timestamp handling
        safeMap[key] = value;
      } else {
        // For any other type, convert to string
        safeMap[key] = value.toString();
      }
    });

    // Extract name fields using a more robust approach
    // Try multiple possible field names for firstName
    String firstName = '';
    for (var key in [
      'firstName',
      'FirstName',
      'firstname',
      'first_name',
      'FIRSTNAME'
    ]) {
      if (safeMap.containsKey(key) && safeMap[key].toString().isNotEmpty) {
        firstName = safeMap[key].toString();
        debugPrint('  Found firstName in field: $key = $firstName');
        break;
      }
    }

    // Try multiple possible field names for lastName
    String lastName = '';
    for (var key in [
      'lastName',
      'LastName',
      'lastname',
      'last_name',
      'LASTNAME'
    ]) {
      if (safeMap.containsKey(key) && safeMap[key].toString().isNotEmpty) {
        lastName = safeMap[key].toString();
        debugPrint('  Found lastName in field: $key = $lastName');
        break;
      }
    }

    // If still empty, try to extract from a potential fullName field
    if ((firstName.isEmpty || lastName.isEmpty) &&
        safeMap.containsKey('fullName')) {
      final fullName = safeMap['fullName'].toString();
      final parts = fullName.split(' ');
      if (parts.length >= 2) {
        if (firstName.isEmpty && parts.isNotEmpty) {
          firstName = parts[0];
          debugPrint('  Extracted firstName from fullName: $firstName');
        }
        if (lastName.isEmpty && parts.length > 1) {
          lastName = parts.last;
          debugPrint('  Extracted lastName from fullName: $lastName');
        }
      }
    }

    // If still empty after all attempts, use placeholder values
    if (firstName.isEmpty) firstName = 'Unknown';
    if (lastName.isEmpty) lastName = 'Student';

    return StudentModel(
      id: safeMap['id'] ?? '',
      firstName: firstName,
      middleName: safeMap['middleName'] ?? '',
      lastName: lastName,
      lrn: safeMap['lrn'] ?? '',
      grade: safeMap['grade'] ?? '',
      age: safeMap['age'] ?? '',
      dateOfBirth: safeMap['dateOfBirth'] ?? '',
      placeOfBirth: safeMap['placeOfBirth'] ?? '',
      religion: safeMap['religion'] ?? '',
      gender: safeMap['gender'] ?? '',
      address: safeMap['address'] ?? '',
      motherTongue: safeMap['motherTongue'] ?? '',
      civilStatus: safeMap['civilStatus'] ?? '',
      ipOrIcc: safeMap['ipOrIcc'] ?? '',
      sdaBaptismDate: safeMap['sdaBaptismDate'] ?? '',
      cellno: safeMap['cellno'] ?? '',
      lastSchoolAttended: safeMap['lastSchoolAttended'] ?? '',
      parentsUserId: safeMap['parentsUserId'] ?? '',
      fathersFirstName: safeMap['fathersFirstName'] ?? '',
      fathersMiddleName: safeMap['fathersMiddleName'] ?? '',
      fathersLastName: safeMap['fathersLastName'] ?? '',
      fathersOcc: safeMap['fathersOcc'] ?? '',
      mothersFirstName: safeMap['mothersFirstName'] ?? '',
      mothersMiddleName: safeMap['mothersMiddleName'] ?? '',
      mothersLastName: safeMap['mothersLastName'] ?? '',
      mothersOcc: safeMap['mothersOcc'] ?? '',
      form138Link: safeMap['form138Link'] ?? '',
      cocLink: safeMap['cocLink'] ?? '',
      birthCertLink: safeMap['birthCertLink'] ?? '',
      goodMoralLink: safeMap['goodMoralLink'] ?? '',
      sigOverNameLink: safeMap['sigOverNameLink'] ?? '',
      additionalInfo: safeMap['additionalInfo'] ?? '',
      status: safeMap['status'] ?? 'active',
      timestamp:
          (safeMap['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  String get fullName =>
      '$firstName ${middleName.isNotEmpty ? '$middleName ' : ''}$lastName';

  String get studentId => id;
}
