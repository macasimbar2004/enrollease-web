import 'package:enrollease_web/model/civil_status_enum.dart';
import 'package:enrollease_web/model/enrollment_status_enum.dart';
import 'package:enrollease_web/model/gender_enum.dart';
import 'package:enrollease_web/model/grade_enum.dart';

class EnrollmentFormModel {
  final String regNo;
  final String firstName;
  final String lastName;
  final String middleName;
  final String lrn;
  final Grade enrollingGrade;
  final int age;
  final String dateOfBirth;
  final String placeOfBirth;
  final String religion;
  final String address;
  final String motherTongue;
  final CivilStatus civilStatus;
  final bool? ipOrIcc;
  final String? sdaBaptismDate;
  final int cellno;
  final String lastSchoolAttended;
  final double unpaidBill;
  final Gender gender; // not in original form, but needed for balance account
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
  final EnrollmentStatus status;
  final String additionalInfo;
  final DateTime timestamp;

  EnrollmentFormModel({
    required this.address,
    required this.motherTongue,
    required this.civilStatus,
    required this.ipOrIcc,
    required this.regNo,
    required this.firstName,
    required this.lastName,
    required this.middleName,
    required this.lrn,
    required this.enrollingGrade,
    required this.age,
    required this.dateOfBirth,
    required this.placeOfBirth,
    required this.religion,
    required this.gender,
    required this.sdaBaptismDate,
    required this.cellno,
    required this.lastSchoolAttended,
    required this.unpaidBill,
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

  // Convert model to Map
  Map<String, dynamic> toMap() {
    return {
      'address': address,
      'motherTongue': motherTongue,
      'civilStatus': civilStatus.name,
      'ipOrIcc': ipOrIcc,
      'regNo': regNo,
      'firstName': firstName,
      'lastName': lastName,
      'middleName': middleName,
      'lrn': lrn,
      'gender': gender.name,
      'enrollingGrade': enrollingGrade.name,
      'age': age,
      'dateOfBirth': dateOfBirth,
      'placeOfBirth': placeOfBirth,
      'religion': religion,
      'sdaBaptismDate': sdaBaptismDate,
      'cellno': cellno,
      'lastSchoolAttended': lastSchoolAttended,
      'unpaidBill': unpaidBill,
      'parentsUserId': parentsUserId,
      'fathersFirstName': fathersFirstName,
      'fathersMiddleName': fathersMiddleName,
      'fathersLastName': fathersLastName,
      'fathersOcc': fathersOcc,
      'mothersFirstName': mothersFirstName,
      'mothersMiddleName': mothersMiddleName,
      'mothersLastName': mothersLastName,
      'mothersOcc': mothersOcc,
      'form138Link': form138Link,
      'cocLink': cocLink,
      'birthCertLink': birthCertLink,
      'goodMoralLink': goodMoralLink,
      'sigOverNameLink': sigOverNameLink,
      'status': status.name,
      'additionalInfo': additionalInfo,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // Create model from Map
  factory EnrollmentFormModel.fromMap(Map<String, dynamic> map) {
    late Grade enrollingGrade;
    late EnrollmentStatus status;
    late Gender gender;
    late CivilStatus cs;
    switch (map['civilStatus']) {
      case 'single':
        cs = CivilStatus.single;
        break;
      case 'married':
        cs = CivilStatus.married;
        break;
    }
    switch (map['enrollingGrade']) {
      case 'nursery':
        enrollingGrade = Grade.nursery;
        break;
      case 'k1':
        enrollingGrade = Grade.k1;
        break;
      case 'k2':
        enrollingGrade = Grade.k2;
        break;
      case 'g1':
        enrollingGrade = Grade.g1;
        break;
      case 'g2':
        enrollingGrade = Grade.g2;
        break;
      case 'g3':
        enrollingGrade = Grade.g3;
        break;
      case 'g4':
        enrollingGrade = Grade.g4;
        break;
      case 'g5':
        enrollingGrade = Grade.g5;
        break;
      case 'g6':
        enrollingGrade = Grade.g6;
        break;
    }
    switch (map['status']) {
      case 'approved':
        status = EnrollmentStatus.approved;
        break;
      case 'disapproved':
        status = EnrollmentStatus.disapproved;
        break;
      case 'pending':
        status = EnrollmentStatus.pending;
        break;
    }
    switch (map['gender']) {
      case 'male':
        gender = Gender.male;
        break;
      case 'female':
        gender = Gender.female;
        break;
    }
    return EnrollmentFormModel(
      address: map['address'] ?? '',
      motherTongue: map['motherTongue'] ?? '',
      civilStatus: cs,
      ipOrIcc: map['ipOrIcc'] ?? false,
      regNo: map['regNo'] ?? '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      middleName: map['middleName'] ?? '',
      additionalInfo: map['additionalInfo'] ?? '',
      lrn: map['lrn'] ?? '',
      enrollingGrade: enrollingGrade,
      gender: gender,
      age: map['age'] ?? 0,
      dateOfBirth: map['dateOfBirth'],
      placeOfBirth: map['placeOfBirth'] ?? '',
      religion: map['religion'] ?? '',
      sdaBaptismDate: map['sdaBaptismDate'],
      cellno: map['cellno'] ?? 0,
      lastSchoolAttended: map['lastSchoolAttended'] ?? '',
      unpaidBill: (map['unpaidBill'] as num).toDouble(),
      parentsUserId: map['parentsUserId'] ?? '',
      fathersFirstName: map['fathersFirstName'] ?? '',
      fathersMiddleName: map['fathersMiddleName'] ?? '',
      fathersLastName: map['fathersLastName'] ?? '',
      fathersOcc: map['fathersOcc'] ?? '',
      mothersFirstName: map['mothersFirstName'] ?? '',
      mothersMiddleName: map['mothersMiddleName'] ?? '',
      mothersLastName: map['mothersLastName'] ?? '',
      mothersOcc: map['mothersOcc'] ?? '',
      form138Link: map['form138Link'] ?? '',
      cocLink: map['cocLink'] ?? '',
      birthCertLink: map['birthCertLink'] ?? '',
      goodMoralLink: map['goodMoralLink'] ?? '',
      sigOverNameLink: map['sigOverNameLink'] ?? '',
      status: status,
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}
