import 'package:enrollease_web/model/fees_model.dart';

class Payment {
  final String id;
  final String balanceAccID;
  final double? or;
  final Map<FeeType, double>? amount;
  final String? date;

  Payment({
    required this.id,
    required this.balanceAccID,
    required this.or,
    required this.date,
    required this.amount,
  });

  factory Payment.fromMap(String id, Map<String, dynamic> data) {
    final Map<FeeType, double> amount = {};
    if (data['amount'] != null) {
      for (final feeType in FeeType.values) {
        amount.addAll({feeType: data['amount'] ?? -1});
      }
    }
    return Payment(
      id: id,
      balanceAccID: data['balanceAccID'],
      or: double.tryParse(data['or']),
      // date: data['date'] == null ? null : (data['date'] as Timestamp).toDate(),
      date: data['date'],
      amount: amount,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'balanceAccID': balanceAccID,
      'or': or,
      'date': date,
      'amount': amount == null ? null : Map.fromIterable(amount!.entries.map((e) => {e.key.name: e.value})),
    };
  }

  double total() {
    double returnTotal = 0;
    if (amount != null) {
      for (final value in amount!.values) {
        returnTotal += value;
      }
    }
    return returnTotal;
  }
}
