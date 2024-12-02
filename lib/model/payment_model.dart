import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enrollease_web/model/fees_model.dart';

class Payment {
  final String id;
  final String balanceAccID;
  final double? or;
  final double? amount;
  final DateTime? date;
  final List<FeeType> description;

  Payment({
    required this.id,
    required this.balanceAccID,
    required this.or,
    required this.date,
    required this.amount,
    required this.description,
  });

  factory Payment.fromMap(String id, Map<String, dynamic> data) {
    return Payment(
      id: id,
      balanceAccID: data['balanceAccID'],
      or: double.tryParse(data['or']),
      date: data['date'] == null ? null : (data['date'] as Timestamp).toDate(),
      amount: double.tryParse(data['amount']),
      description: data['description'] ?? [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'balanceAccID': balanceAccID,
      'or': or,
      'date': date,
      'amount': amount,
      'description': description,
    };
  }
}
