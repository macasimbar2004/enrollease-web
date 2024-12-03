import 'package:enrollease_web/model/payment_model.dart';
import 'package:enrollease_web/pages/payments.dart';
import 'package:enrollease_web/utils/nav.dart';
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
      String cellValue = rowData[field] == 'amount' ? Payment.fromMap(rowData['id'], rowData[field]).total().toString() : rowData[field].toString();
      if (field == 'action') {
        return DataCell(Column(
          children: [
            ElevatedButton(
              onPressed: () => Nav.push(context, PaymentsPage(userId: userId, data: rowData)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: const Text('View payments', style: TextStyle(color: Colors.white)),
            ),
          ],
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
