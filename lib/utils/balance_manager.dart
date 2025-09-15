import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enrollease_web/dev.dart';
import 'package:enrollease_web/model/balance_model.dart';
import 'package:enrollease_web/model/fees_model.dart';
import 'package:enrollease_web/model/payment_model.dart';

class BalanceManager {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<BalanceAccount?> getBalanceAccount({
    required String parentsUserId,
    required String pupilID,
    required int schoolYearStart,
  }) async {
    if (parentsUserId.isEmpty) throw ('ID was empty!!');
    try {
      final doc = await _firestore
          .collection('balance_accounts')
          .where('parentID', isEqualTo: parentsUserId)
          .where('pupilID', isEqualTo: pupilID)
          .where(
            'schoolYearStart',
            isEqualTo: schoolYearStart,
          )
          .limit(1)
          .get();
      if (doc.docs.isNotEmpty && doc.docs.first.exists) {
        return BalanceAccount.fromMap(doc.docs.first.id, doc.docs.first.data());
      }
      return null;
    } catch (e) {
      dPrint(e);
      return null;
    }
  }

  Future<String?> createBalanceAccount(BalanceAccount acc) async {
    // if (acc.id.isEmpty) throw ('Must provide parentsUserId!');
    try {
      await _firestore.collection('balance_accounts').doc().set(acc.toMap());
      return null;
    } catch (e) {
      dPrint(e);
      return e.toString();
    }
  }

  Future<String?> getBalanceID() async {
    final yearPrefix = 'SDAB${DateTime.now().year % 100}-';
    try {
      String lastGeneratedEnrollmentNo = '';
      final querySnapshot = await _firestore.collection('balance_accounts').get();
      if (querySnapshot.docs.isEmpty) {
        lastGeneratedEnrollmentNo = '$yearPrefix-${_getUniqueSuffix()}';
        return lastGeneratedEnrollmentNo;
      }
      final lastDoc = querySnapshot.docs.last.id;

      // Check if the last ID starts with the correct year prefix
      if (!lastDoc.startsWith(yearPrefix)) {
        lastGeneratedEnrollmentNo = '$yearPrefix-${_getUniqueSuffix()}';
        return lastGeneratedEnrollmentNo;
      }

      // Extract the numeric part (the 6-digit number) from the last document ID
      final suffixStartIndex = yearPrefix.length;
      final dashIndex = lastDoc.indexOf('-', suffixStartIndex);

      // If the dash is not found, generate a new number
      if (dashIndex == -1) {
        lastGeneratedEnrollmentNo = '$yearPrefix-${_getUniqueSuffix()}';
        return lastGeneratedEnrollmentNo;
      }

      final lastNumberString = lastDoc.substring(suffixStartIndex, dashIndex);
      final lastNumber = int.tryParse(lastNumberString) ?? 0;
      int newNumber = lastNumber + 1;

      // Ensure the new number is padded to 6 digits
      final newIncrement = newNumber.toString().padLeft(6, '0');

      // Generate the final enrollment number with unique timestamp suffix
      lastGeneratedEnrollmentNo = '$yearPrefix$newIncrement-${_getUniqueSuffix()}';

      // Emit the new registration number
      return lastGeneratedEnrollmentNo;
    } catch (e) {
      dPrint('Error generating new enrollment number: $e');
      return null;
    }
  }

// Helper function to get the unique microsecond or millisecond suffix
  String _getUniqueSuffix() {
    final timeSuffix = DateTime.now().millisecondsSinceEpoch.toString().substring(7); // Last 6 digits of milliseconds
    return timeSuffix.padLeft(6, '0'); // Ensure 6 digits
  }

  Future<String?> createPayment(Payment payment) async {
    // if (acc.id.isEmpty) throw ('Must provide parentsUserId!');
    try {
      await _firestore.collection('payments').doc().set(payment.toMap());
      return null;
    } catch (e) {
      dPrint(e);
      return e.toString();
    }
  }

  Future<String?> minusRemainingBalance({
    required Payment payment,
  }) async {
    if (payment.balanceAccID.isEmpty) throw ('Must provide balanceAccID!');
    try {
      final ref = _firestore.collection('balance_accounts').doc(payment.balanceAccID);
      final balanceData = await ref.get();
      final balance = BalanceAccount.fromMap(payment.balanceAccID, balanceData.data()!);
      final newBalance = balance.copyWith(
          remainingBalance: FeesModel(
        entrance: balance.remainingBalance.entrance - (payment.amount?.entrance ?? 0),
        tuition: balance.remainingBalance.tuition - (payment.amount?.tuition ?? 0),
        misc: balance.remainingBalance.misc - (payment.amount?.misc ?? 0),
        books: balance.remainingBalance.books - (payment.amount?.books ?? 0),
        watchman: balance.remainingBalance.watchman - (payment.amount?.watchman ?? 0),
        aircon: balance.remainingBalance.aircon - (payment.amount?.aircon ?? 0),
        others: balance.remainingBalance.others - (payment.amount?.others ?? 0),
      ));
      ref.update(newBalance.toMap());
      return null;
    } catch (e) {
      dPrint(e);
      return e.toString();
    }
  }
}
