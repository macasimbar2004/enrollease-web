import 'package:enrollease_web/model/fees_model.dart';

class Payment {
  final String id;
  final String balanceAccID;
  final double? or;
  final FeesModel? amount;
  final String? date;

  Payment({
    required this.id,
    required this.balanceAccID,
    required this.or,
    required this.date,
    required this.amount,
  });

  factory Payment.fromMap(String id, Map<String, dynamic> data) {
    FeesModel? amount;
    if (data['amount'] != null && data['amount'] is! FeesModel) {
      amount = FeesModel.fromMap(data['amount']);
    }
    return Payment(
      id: id,
      balanceAccID: data['balanceAccID'],
      or: double.tryParse(data['or'].toString()),
      // date: data['date'] == null ? null : (data['date'] as Timestamp).toDate(),
      date: data['date'],
      amount: amount ?? data['amount'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'balanceAccID': balanceAccID,
      'or': or,
      'date': date,
      'amount': amount?.toMap(),
    };
  }

  double total() => amount?.total() ?? 0;
}
