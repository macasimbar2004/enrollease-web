import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_model.dart';

class UsersTableSource extends DataTableSource {
  final BuildContext context;
  final List<Map<String, dynamic>> data;
  final bool loading;

  UsersTableSource(this.context, this.data, this.loading);

  @override
  DataRow? getRow(int index) {
    if (index >= data.length) return null;
    final rowData = data[index];
    return DataRow(cells: _buildDataCells(rowData));
  }

  List<DataCell> _buildDataCells(Map<String, dynamic> rowData) {
    const fields = [
      'userName',
      'email',
      'role',
      'contactNumber',
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
                  _showUserDetailsDialog(rowData);
                },
                tooltip: 'View Details',
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  _showDeleteConfirmation(rowData);
                },
                tooltip: 'Delete User',
              ),
            ],
          ),
        );
      }

      return DataCell(
        SelectableText(
          rowData[field]?.toString() ?? '',
          style: const TextStyle(color: Colors.black, fontSize: 16),
        ),
      );
    }).toList();
  }

  void _showUserDetailsDialog(Map<String, dynamic> userData) {
    // Create a UserModel from the map
    final user = UserModel.fromMap(userData);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('User Details - ${user.userName}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('User ID', user.uid),
              _buildDetailRow('Username', user.userName),
              _buildDetailRow('Email', user.email),
              _buildDetailRow('Role', user.role),
              _buildDetailRow('Contact Number', user.contactNumber),
              _buildDetailRow('Status', user.isActive ? 'Active' : 'Inactive'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(value.isNotEmpty ? value : 'Not specified'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(Map<String, dynamic> userData) {
    final user = UserModel.fromMap(userData);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User?'),
        content: Text(
          'Are you sure you want to delete the user "${user.userName}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            onPressed: () {
              _deleteUser(user.uid);
              Navigator.of(context).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteUser(String uid) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting user: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => data.length;

  @override
  int get selectedRowCount => 0;
}
