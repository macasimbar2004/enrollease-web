import 'package:flutter/material.dart';

// Data source for registrars table
class RegistarsTableSource extends DataTableSource {
  final BuildContext context;
  final List<Map<String, dynamic>> data;
  final List<DataRow> Function(List<Map<String, dynamic>>) buildDataRows;

  RegistarsTableSource(
    this.context,
    this.data,
    this.buildDataRows,
  );

  @override
  DataRow? getRow(int index) {
    if (index >= data.length) return null;
    return buildDataRows(data)[index];
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => data.length;

  @override
  int get selectedRowCount => 0;
}
