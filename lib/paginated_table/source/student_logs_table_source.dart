import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StudentLogsTableSource extends DataTableSource {
  final BuildContext context;
  final List<Map<String, dynamic>> data;
  StudentLogsTableSource(this.context, this.data);

  @override
  DataRow? getRow(int index) {
    if (index >= data.length) return null;
    return DataRow(
      cells: _buildDataCells(data[index]),
    );
  }

  List<DataCell> _buildDataCells(Map<String, dynamic> rowData) {
    final fields = [
      'content',
      'timestamp',
      'type',
      'notificationType',
    ];

    return fields.map((field) {
      String cellValue = '';
      if (field == 'timestamp' && rowData[field] != null) {
        cellValue = DateFormat('dd MMM yyyy, hh:mm a')
            .format((rowData[field] as Timestamp).toDate());
      } else if (field == 'type') {
        final type = rowData[field]?.toString().toLowerCase();
        cellValue = type == 'in' || type == 'entering'
            ? 'Entering'
            : (type == 'out' || type == 'exiting'
                ? 'Exiting'
                : (rowData[field] ?? '--'));
      } else {
        cellValue = rowData[field] ?? '--';
      }
      return DataCell(
        SelectableText(
          cellValue,
          style: TextStyle(
            color: field == 'type'
                ? (cellValue == 'Entering'
                    ? Colors.green
                    : (cellValue == 'Exiting' ? Colors.red : Colors.black))
                : Colors.black,
            fontSize: 18,
            fontWeight: field == 'type' ? FontWeight.bold : FontWeight.normal,
          ),
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
