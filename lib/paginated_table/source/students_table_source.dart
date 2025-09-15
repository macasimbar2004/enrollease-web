import 'package:flutter/material.dart';
import 'package:enrollease_web/utils/table_formatting.dart';

class StudentsTableSource extends DataTableSource {
  final BuildContext context;
  final List<Map<String, dynamic>> data;
  final bool loading;
  final String userId;

  StudentsTableSource(this.context, this.data, this.loading, this.userId);

  @override
  DataRow? getRow(int index) {
    if (index >= data.length) return null;
    final rowData = data[index];
    return DataRow(cells: _buildDataCells(rowData));
  }

  List<DataCell> _buildDataCells(Map<String, dynamic> rowData) {
    const fields = [
      'id',
      'fullName',
      'gender',
      'age',
      'address',
      'cellno', 
      'grade',
      'actions',
    ];

    return fields.map((field) {
      if (field == 'actions') {
        return DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.visibility),
                onPressed: () {
                  // TODO: Implement view student details
                },
                tooltip: 'View Details',
              ),
              IconButton(
                icon: const Icon(Icons.grade),
                onPressed: () {
                  // TODO: Implement grade management
                },
                tooltip: 'Manage Grades',
              ),
              IconButton(
                icon: const Icon(Icons.block),
                onPressed: () {
                  // TODO: Implement deactivate student
                },
                tooltip: 'Deactivate Student',
              ),
            ],
          ),
        );
      }

      // Format specific fields using utility functions
      String cellValue = '';
      if (field == 'fullName') {
        cellValue = TableFormatting.formatFullName(
          firstName: rowData['firstName']?.toString(),
          middleName: rowData['middleName']?.toString(),
          lastName: rowData['lastName']?.toString(),
        );
      } else if (field == 'gender') {
        cellValue = TableFormatting.formatGender(rowData[field]?.toString());
      } else if (field == 'grade') {
        cellValue = TableFormatting.formatGradeLevel(rowData[field]?.toString());
      } else if (field == 'cellno') {
        cellValue = TableFormatting.formatPhoneNumber(rowData[field]?.toString());
      } else {
        cellValue = rowData[field]?.toString() ?? '';
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
