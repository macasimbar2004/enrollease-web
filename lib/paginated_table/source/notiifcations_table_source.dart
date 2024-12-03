import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enrollease_web/utils/firebase_auth.dart';
import 'package:enrollease_web/widgets/custom_add_dialog.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Data source for notifications table
class NotifcationsTableSource extends DataTableSource {
  final BuildContext context;
  final List<Map<String, dynamic>> data;
  FirebaseAuthProvider firebaseAuthProvider = FirebaseAuthProvider();
  NotifcationsTableSource(this.context, this.data);

  @override
  DataRow? getRow(int index) {
    if (index >= data.length) return null;
    return DataRow(
      onSelectChanged: (value) {
        viewNotification(data[index]);
      },
      color: data[index]['isRead'] == true ? const WidgetStatePropertyAll(Colors.grey) : null,
      cells: _buildDataCells(data[index]),
    );
  }

  List<DataCell> _buildDataCells(Map<String, dynamic> rowData) {
    // dPrint(rowData.toString());
    final fields = [
      'title',
      'content',
      'timestamp',
    ];
    return fields.map((field) {
      String cellValue = '';
      if (field == 'timestamp') {
        cellValue = DateFormat('dd MMM yyyy').format((rowData[field] as Timestamp).toDate());
      } else {
        cellValue = rowData[field] ?? '';
      }

      // if (field == 'action') {
      //   return DataCell(
      //     ElevatedButton(
      //       onPressed: () async {}, // Action handling can be implemented here
      //       style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
      //       child: const Text('View', style: TextStyle(color: Colors.white)),
      //     ),
      //   );
      // }

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

  Future<void> viewNotification(Map<String, dynamic> rowData) async {
    return showDynamicDialog(
      context: context,
      title: rowData['title'] ?? '--',
      contentWidgets: Column(
        children: [
          const SizedBox(height: 20),
          _buildText(rowData['content']),
          const SizedBox(height: 20),
          const Divider(
            thickness: 1,
            color: Colors.black,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildText('Date Created: '),
                  _buildText(rowData['timestamp'] != null ? DateFormat('dd MMM yyyy').format((rowData['timestamp'] as Timestamp).toDate()) : '--'),
                ],
              ),
              IconButton(
                  onPressed: () async {
                    await deleteNotif(rowData['id']);
                    if (!context.mounted) return;
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.delete))
            ],
          )
        ],
      ),
      actionButtons: [
        // Visibility(
        //   visible: fromPendingPage,
        //   child: ElevatedButton(
        //       onPressed: () async {
        //         await handleApprovingForms(context, rowData, 'Approval', 'Approve');
        //       },
        //       style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
        //       child: const Text(
        //         'Approve Record',
        //         style: TextStyle(color: Colors.black),
        //       )),
        // ),
        // const SizedBox(
        //   width: 5,
        // ),
        // Visibility(
        //   visible: fromPendingPage,
        //   child: ElevatedButton(
        //       onPressed: () async {
        //         await handleApprovingForms(context, rowData, 'Disapproval', 'Disapprove');
        //       },
        //       style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
        //       child: const Text(
        //         'Disapprove Record',
        //         style: TextStyle(color: Colors.black),
        //       )),
        // )
      ],
    );
  }

  Future<String?> deleteNotif(String id) async {
    if (id.isEmpty) return 'Empty ID';
    try {
      await FirebaseFirestore.instance.collection('notifications').doc(id).delete();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Widget _buildText(String text) {
    return Text(
      text,
      style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
    );
  }
}
