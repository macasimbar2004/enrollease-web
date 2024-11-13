import 'package:flutter/material.dart';

// Data source for registrars table
class RegistarsTableSource extends DataTableSource {
  final BuildContext context;
  final List<Map<String, dynamic>> data;

  RegistarsTableSource(this.context, this.data);

  @override
  DataRow? getRow(int index) {
    if (index >= data.length) return null;

    final rowData = data[index];

    return DataRow(cells: _buildDataCells(rowData));
  }

  List<DataCell> _buildDataCells(Map<String, dynamic> rowData) {
    return [
      // Image
      DataCell(
        rowData['image'] != null
            ? ClipOval(
                child: Image.asset(
                  rowData['image'],
                  height: 50,
                  width: 50,
                  fit: BoxFit.cover,
                ),
              )
            : const Icon(Icons.person, size: 50, color: Colors.grey),
      ),

      // Identification
      DataCell(
        SelectableText(
          rowData['identification'] ?? '',
          style: const TextStyle(color: Colors.black, fontSize: 16),
        ),
      ),

      // Fullname
      DataCell(
        SelectableText(
          rowData['fullname'] ?? '',
          style: const TextStyle(color: Colors.black, fontSize: 16),
        ),
      ),

      // Contact
      DataCell(
        SelectableText(
          rowData['contact'] ?? '',
          style: const TextStyle(color: Colors.black, fontSize: 16),
        ),
      ),

      // Actions (buttons or action labels)
      DataCell(rowData['actions']),
    ];
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => data.length;

  @override
  int get selectedRowCount => 0;
}
