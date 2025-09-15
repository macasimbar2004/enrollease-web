import 'package:enrollease_web/dev.dart';
import 'package:enrollease_web/model/enrollment_form_model.dart';
import 'package:enrollease_web/model/fees_model.dart';
import 'package:enrollease_web/model/grade_enum.dart';
import 'package:enrollease_web/model/user_model.dart';
import 'package:enrollease_web/states_management/side_menu_index_controller.dart';
import 'package:enrollease_web/utils/firebase_auth.dart';
import 'package:enrollease_web/utils/table_formatting.dart';
import 'package:enrollease_web/widgets/custom_add_dialog.dart';
import 'package:enrollease_web/widgets/custom_confirmation_dialog.dart';
import 'package:enrollease_web/widgets/custom_loading_dialog.dart';
import 'package:enrollease_web/widgets/custom_textformfields.dart';
import 'package:enrollease_web/widgets/custom_toast.dart';
import 'package:enrollease_web/pages/payments.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Data source for new users table
class BalanceAccTableSource extends DataTableSource {
  final BuildContext context;
  final List<Map<String, dynamic>> data;
  final bool fromPendingPage;
  final String userId;
  FirebaseAuthProvider firebaseAuthProvider = FirebaseAuthProvider();
  BalanceAccTableSource(
    this.context,
    this.data,
    this.fromPendingPage,
    this.userId,
  );

  @override
  DataRow? getRow(int index) {
    if (index >= data.length) return null;
    final rowData = data[index];
    return DataRow(cells: _buildDataCells(rowData));
  }

  List<DataCell> _buildDataCells(Map<String, dynamic> rowData) {
    const fields = [
      'gradeLevel',
      'parent',
      'pupil',
      'enrollingGrade',
      'remainingBalance',
      'action',
    ];

    //    const columnLabels = [
    //   'Grade Level #',
    //   'Parent Name',
    //   'Pupil Name',
    //   'Grade Level',
    //   'Pending balance',
    //   'Action',
    // ];

    return fields.map((field) {
      String cellValue = '';
      try {
        switch (field) {
          case 'parent':
            cellValue = (rowData[field] as UserModel?)?.userName ?? '--';
            break;
          case 'pupil':
            cellValue =
                (rowData[field] as EnrollmentFormModel?)?.firstName ?? '--';
            break;
          case 'remainingBalance':
            if (rowData[field] != null) {
              final feesModel = FeesModel.fromMap(rowData[field]);
              cellValue =
                  feesModel.total() == 0 ? 'Paid' : feesModel.totalFormatted();
            } else {
              cellValue = '--';
            }
            break;
          case 'enrollingGrade':
            cellValue = (rowData['pupil'] as EnrollmentFormModel?)
                    ?.enrollingGrade
                    .formalLongString() ??
                '--';
            break;
          default:
            cellValue = rowData[field]?.toString() ?? '--';
        }
      } catch (e) {
        cellValue = '--';
      }

      if (field == 'action') {
        return DataCell(
          ElevatedButton(
            onPressed: () {
              // Set the data in the controller for the payments page to access
              context.read<SideMenuIndexController>().setData(rowData);
              // Navigate directly to payments page
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => PaymentsPage(
                    userId: userId,
                    userName: (rowData['parent'] as UserModel?)?.userName,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text('View', style: TextStyle(color: Colors.white)),
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

  Future<void> viewPendingApprovalForm(Map<String, dynamic> rowData) async {
    return showDynamicDialog(
      context: context,
      title: rowData['regNo'],
      contentWidgets: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              runSpacing: 10,
              spacing: 10,
              children: [
                const Text('Parent\'s\\Guardian\'s Name: ',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text('${rowData['parentsOrGuardianName']}',
                    style: const TextStyle(fontSize: 20, color: Colors.black)),
              ],
            ),
          ),
          const Divider(
            thickness: 1,
            color: Colors.black,
          ),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('PERSONAL INFORMATION:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 20),
          buildTextField(
            labelText: 'Student\'s Full Name',
            initialValue: rowData['studentFullName'],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: buildTextField(
                    labelText: 'Date of Birth (MM/DD/YYYY)',
                    initialValue: rowData['dateOfBirth']),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: buildTextField(
                    labelText: 'Age', initialValue: rowData['age']),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildText('Gender: '),
              _buildText(
                  TableFormatting.formatGender(rowData['gender']?.toString())),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: buildTextField(
                  labelText: 'Province',
                  initialValue: rowData['province'],
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: buildTextField(
                  labelText: 'City',
                  initialValue: rowData['city'],
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: buildTextField(
                  labelText: 'Barangay',
                  initialValue: rowData['barangay'],
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: buildTextField(
                  labelText: 'Zip Code',
                  initialValue: rowData['zipCode'],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: buildTextField(
                  labelText: 'Phone Number',
                  initialValue: TableFormatting.formatPhoneNumber(
                      rowData['phoneNumber']?.toString()),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: buildTextField(
                  labelText: 'Email',
                  initialValue: rowData['email'],
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          const Divider(
            thickness: 1,
            color: Colors.black,
          ),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('ACADEMIC INFORMATION:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 20),
          buildTextField(
              labelText: 'Previous School',
              initialValue: rowData['previousSchool']),
          const SizedBox(height: 20),
          Align(
              alignment: Alignment.centerLeft,
              child: _buildText('Attach Files: ')),
          const SizedBox(height: 10),
          Container(
            height: 250,
            decoration: BoxDecoration(
                border: Border.all(width: 1, color: Colors.black),
                borderRadius: BorderRadius.circular(10)),
          ),
          const SizedBox(height: 20),
          buildTextField(
              labelText: 'Additional Info',
              initialValue: rowData['additionalInfo']),
        ],
      ),
      actionButtons: [
        Visibility(
          visible: fromPendingPage,
          child: ElevatedButton(
              onPressed: () async {
                await handleApprovingForms(
                    context, rowData, 'Approval', 'Approve');
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text(
                'Approve',
                style: TextStyle(color: Colors.white),
              )),
        ),
        const SizedBox(
          width: 5,
        ),
        Visibility(
          visible: fromPendingPage,
          child: ElevatedButton(
              onPressed: () async {
                await handleApprovingForms(
                    context, rowData, 'Disapproval', 'Disapprove');
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text(
                'Disapprove',
                style: TextStyle(color: Colors.white),
              )),
        )
      ],
    );
  }

  Future<void> handleApprovingForms(
      BuildContext context,
      Map<String, dynamic> rowData,
      String confirmText,
      String leftButtonText) async {
    try {
      final confirm = await showConfirmationDialog(
        context: context,
        title: 'Confirm $confirmText',
        message:
            'Are you sure you want to ${leftButtonText.toLowerCase()} the record for ${rowData['regNo']}?',
        confirmText: leftButtonText,
        cancelText: 'Cancel',
      );

      if (confirm == true) {
        if (context.mounted) {
          showLoadingDialog(context, 'Updating');
        }

        await firebaseAuthProvider.addNotification(
            content: 'Your enrollment form has been ${leftButtonText}d!\n'
                'Registration Number: ${rowData['regNo']}',
            type: 'user',
            uid: rowData['parentsUserId']);

        await firebaseAuthProvider.updateStatus(
            rowData['regNo'], '${leftButtonText.toLowerCase()}d');
        if (context.mounted) {
          Navigator.pop(context); // Close the loading dialog
          Navigator.pop(context); // Close the current dialog or page
          DelightfulToast.showSuccess(
              context, 'Success', 'Enrollment form ${leftButtonText}d.');
        }
      } else {
        dPrint('Approval canceled by user.');
      }
    } catch (e) {
      dPrint('Error: $e');
    }
  }

  Widget _buildText(String text) {
    return Text(
      text,
      style: const TextStyle(
          color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
    );
  }
}
