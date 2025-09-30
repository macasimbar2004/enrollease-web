import 'package:enrollease_web/dev.dart';
import 'package:enrollease_web/model/payment_model.dart';
import 'package:enrollease_web/utils/nav.dart';
import 'package:enrollease_web/widgets/custom_button.dart';
import 'package:flutter/material.dart';

// Data source for registrars table
class PaymentsTableSource extends DataTableSource {
  final BuildContext context;
  final String userId;
  final List<Map<String, dynamic>> data;

  PaymentsTableSource(this.context, this.data, this.userId);

  @override
  DataRow? getRow(int index) {
    if (index >= data.length) return null;
    final rowData = data[index];
    return DataRow(cells: _buildDataCells(rowData));
  }

  List<DataCell> _buildDataCells(Map<String, dynamic> rowData) {
    const fields = [
      'or',
      'date',
      'amount',
      'action',
    ];

    //    const columnLabels = [
    //   'OR',
    //   'Date',
    //   'Amount',
    //   'Actions',
    // ]; // Column labels

    return fields.map((field) {
      String cellValue = field == 'amount'
          ? rowData[field].totalFormatted()
          : rowData[field].toString();
      if (field == 'action') {
        dPrint('row data is $rowData');
        return DataCell(ElevatedButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => PaymentBreakdown(
                payment: Payment.fromMap(
                  rowData['id'],
                  rowData,
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
          child: const Text('View breakdown',
              style: TextStyle(color: Colors.white)),
        ));
      }

      return DataCell(
        SelectableText(
          cellValue,
          style: const TextStyle(color: Colors.black, fontSize: 18),
        ),
      );
    }).toList();
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => data.length;

  @override
  int get selectedRowCount => 0;
}

class PaymentBreakdown extends StatelessWidget {
  final Payment payment;
  const PaymentBreakdown({required this.payment, super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Payment Breakdown',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ...payment.amount == null
                ? [const Text('Error reading individual breakdown')]
                : payment.amount!.toMap().entries.map((e) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [Text('${e.key}: '), Text(e.value.toString())],
                    );
                  }).toList(),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomBtn(
                  vertical: 10,
                  horizontal: 20,
                  colorBg: Colors.red,
                  colorTxt: Colors.white,
                  txtSize: 18,
                  onTap: () {
                    Nav.pop(context);
                  },
                  btnTxt: 'Back',
                  textStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 18),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
