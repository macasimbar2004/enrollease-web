// should be created every time enrollment is approved
import 'package:enrollease_web/model/fees_model.dart';

class BalanceAccount {
  final String id;
  final String gradeLevel; // e.g. K1-01, K1-02, K1-03, auto-generated
  final int? schoolYearStart;
  final String parentID; // UserModel
  /// from UserModel, we will get:
  /// user name
  final String pupilID; // EnrollmentFormModel
  /// from EnrollmentFormModel, we will get:
  /// first name
  /// middle name
  /// last name
  /// enrollingGrade
  /// gender
  /// age
  /// contact number
  /// address
  /// religion
  /// mother tongue
  /// civil status
  /// IP/ICC
  /// unpaidBill
  final double tuitionDiscount;
  final double bookDiscount;
  final FeesModel startingBalance; // starting balanace when created
  final FeesModel remainingBalance; // the remaining balanace
  BalanceAccount({
    required this.id,
    required this.schoolYearStart,
    required this.startingBalance,
    required this.remainingBalance,
    required this.gradeLevel,
    required this.parentID,
    required this.pupilID,
    required this.tuitionDiscount,
    required this.bookDiscount,
  });

  factory BalanceAccount.fromMap(String id, Map<String, dynamic> data) {
    return BalanceAccount(
      id: id,
      schoolYearStart: data['schoolYearStart'],
      startingBalance: FeesModel.fromMap(data['startingBalance']),
      remainingBalance: FeesModel.fromMap(data['remainingBalance']),
      gradeLevel: data['gradeLevel'],
      parentID: data['parentID'],
      pupilID: data['pupilID'],
      tuitionDiscount: data['tuitionDiscount'],
      bookDiscount: data['bookDiscount'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'schoolYearStart': schoolYearStart,
      'startingBalance': startingBalance.toMap(),
      'remainingBalance': remainingBalance.toMap(),
      'gradeLevel': gradeLevel,
      'parentID': parentID,
      'pupilID': pupilID,
      'tuitionDiscount': tuitionDiscount,
      'bookDiscount': bookDiscount,
    };
  }
}
