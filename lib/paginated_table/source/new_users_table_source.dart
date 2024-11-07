import 'package:flutter/material.dart';

// Data source for new users table
class NewUsersTableSource extends DataTableSource {
  final BuildContext context;
  final List<Map<String, dynamic>> data;

  NewUsersTableSource(this.context, this.data);

  @override
  DataRow? getRow(int index) {
    if (index >= data.length) return null;

    final rowData = data[index];

    return DataRow(cells: _buildDataCells(rowData));
  }

  List<DataCell> _buildDataCells(Map<String, dynamic> rowData) {
    const fields = ['name', 'user id', 'status', 'role'];

    return fields.map((field) {
      String cellValue = rowData[field]?.toString() ?? '';

      if (field == 'status' && cellValue == 'ACTIVE') {
        return DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Text(
              cellValue,
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
        );
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
