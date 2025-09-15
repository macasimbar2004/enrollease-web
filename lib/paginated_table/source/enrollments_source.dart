import 'package:enrollease_web/appwrite.dart';
import 'package:enrollease_web/dev.dart';
import 'package:enrollease_web/model/balance_model.dart';
import 'package:enrollease_web/model/civil_status_enum.dart';
import 'package:enrollease_web/model/enrollment_form_model.dart';
import 'package:enrollease_web/model/enrollment_status_enum.dart';
import 'package:enrollease_web/model/fees_model.dart';
import 'package:enrollease_web/model/grade_enum.dart';
import 'package:enrollease_web/utils/balance_manager.dart';
import 'package:enrollease_web/utils/firebase_auth.dart';
import 'package:enrollease_web/utils/nav.dart';
import 'package:enrollease_web/utils/table_formatting.dart';
import 'package:enrollease_web/widgets/custom_add_dialog.dart';
import 'package:enrollease_web/widgets/custom_button.dart';
import 'package:enrollease_web/widgets/custom_confirmation_dialog.dart';
import 'package:enrollease_web/widgets/custom_loading_dialog.dart';
import 'package:enrollease_web/widgets/custom_toast.dart';
import 'package:enrollease_web/widgets/discounts_to_apply.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:enrollease_web/utils/certificate_generator.dart';
// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;
import 'dart:convert';

enum CredentialData {
  form138,
  coc,
  goodMoral,
  birthCert,
  sigOverName,
}

enum Discount {
  tuition,
  book,
}

extension CredString on CredentialData {
  String displayName() {
    switch (this) {
      case CredentialData.form138:
        return 'Card (Form 138)';
      case CredentialData.coc:
        return 'Cert. of Completion (Photocopy)';
      case CredentialData.goodMoral:
        return 'Good Moral';
      case CredentialData.birthCert:
        return 'NSO Birth Cert. (Photocopy)';
      case CredentialData.sigOverName:
        return 'Signature Over Printed Name';
    }
  }
}

// Data source for new users table
class EnrollmentsTableSource extends DataTableSource {
  final BuildContext context;
  final List<Map<String, dynamic>> data;
  final bool loading;
  final void Function(bool) toggleLoading;
  EnrollmentsTableSource(
    this.context,
    this.data,
    this.loading,
    this.toggleLoading,
  );

  final firebaseAuthProvider = FirebaseAuthProvider();
  final balanceManager = BalanceManager();
  @override
  DataRow? getRow(int index) {
    if (index >= data.length) return null;
    final rowData = data[index];
    return DataRow(cells: _buildDataCells(rowData));
  }

  List<DataCell> _buildDataCells(Map<String, dynamic> rowData) {
    const fields = [
      'regNo',
      'studentFullName',
      'enrollingGrade',
      'status',
      'action'
    ];

    return fields.map((field) {
      if (field == 'studentFullName') {
        String fullName = TableFormatting.formatFullName(
          firstName: rowData['firstName']?.toString(),
          middleName: rowData['middleName']?.toString(),
          lastName: rowData['lastName']?.toString(),
        );
        return DataCell(
          SelectableText(
            fullName,
            style: const TextStyle(color: Colors.black, fontSize: 18),
          ),
        );
      }

      if (field == 'action') {
        return DataCell(
          ElevatedButton(
            onPressed: () async {
              if (loading) return;
              toggleLoading(true);
              final enrollmentData = EnrollmentFormModel.fromMap(rowData);
              final ids = [
                enrollmentData.cocLink,
                enrollmentData.form138Link,
                enrollmentData.birthCertLink,
                enrollmentData.goodMoralLink,
                enrollmentData.sigOverNameLink,
              ];
              final Map<CredentialData, Uint8List?> credentialData = {};
              for (final credData in CredentialData.values) {
                for (final id in ids) {
                  credentialData.addAll({credData: await getData(id)});
                }
              }
              toggleLoading(false);
              await viewPendingApprovalForm(
                enrollmentData,
                credentialData,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child:
                const Text('View data', style: TextStyle(color: Colors.white)),
          ),
        );
      }

      String cellValue = '';
      
      // Format specific fields using utility functions
      if (field == 'enrollingGrade') {
        cellValue = TableFormatting.formatGradeLevel(rowData[field]?.toString());
      } else if (field == 'status') {
        cellValue = TableFormatting.formatStatus(rowData[field]?.toString());
      } else {
        // Default formatting for other fields
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

  Future<Uint8List?> getData(String id) async {
    if (id.isEmpty) return null;
    try {
      final bytes = await storage.getFileDownload(
        bucketId: bucketIDCredentialData,
        fileId: id,
      );
      if (bytes.isEmpty) return null;
      return bytes;
    } catch (e) {
      dPrint(e.toString());
      return null;
    }
  }

  Future<void> viewPendingApprovalForm(EnrollmentFormModel rowData,
      Map<CredentialData, Uint8List?> credentialData) async {
    if (!context.mounted) return;
    return showDynamicDialog(
      context: context,
      title: Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              // Calculate responsive height based on screen width
              final imageHeight =
                  constraints.maxWidth * 0.15; // 15% of screen width
              return Container(
                width: double.infinity,
                height: imageHeight,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Image.asset(
                  'assets/logos/banner.png',
                  fit: BoxFit.contain,
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          const Text(
            'Registration Details',
            style: TextStyle(fontSize: 20),
          ),
          const SizedBox(height: 5),
          Text('Reg. #: ${rowData.regNo}')
        ],
      ),
      contentWidgets: Column(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(color: Colors.black, endIndent: 20),
                const SizedBox(height: 10),
                const Text('PUPIL INFORMATION:',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                _buildText('First name', rowData.firstName),
                _buildText('Middle name', rowData.middleName),
                _buildText('Last name', rowData.lastName),
                _buildText('Date of Birth', rowData.dateOfBirth),
                _buildText('Address', rowData.address),
                _buildText('Age', rowData.age.toString()),
                _buildText('Gender', rowData.gender.name),
                _buildText('Religion', rowData.religion),
                _buildText('Mother Tongue', rowData.motherTongue),
                _buildText('Civil Status', rowData.civilStatus.formalName()),
                _buildText(
                    'IP/ICC',
                    rowData.ipOrIcc != null && rowData.ipOrIcc == true
                        ? 'Yes'
                        : 'No'),
                if (rowData.sdaBaptismDate != null)
                  _buildText('SDA baptism on', rowData.sdaBaptismDate ?? '--'),
                const SizedBox(height: 10),
                const Divider(color: Colors.black, endIndent: 20),
                const SizedBox(height: 10),
                const Text('FATHER\'S INFORMATION:',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                _buildText('First name', rowData.fathersFirstName),
                _buildText('Middle name', rowData.fathersMiddleName),
                _buildText('Last name', rowData.fathersLastName),
                _buildText('Occupation', rowData.fathersOcc),
                const Divider(color: Colors.black, endIndent: 20),
                const SizedBox(height: 10),
                const Text('MOTHER\'S INFORMATION:',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                _buildText('First name', rowData.mothersFirstName),
                _buildText('Middle name', rowData.mothersMiddleName),
                _buildText('Last name', rowData.mothersLastName),
                _buildText('Occupation', rowData.mothersOcc),
                const SizedBox(height: 10),
                const Divider(color: Colors.black, endIndent: 20),
                const SizedBox(height: 10),
                const Text('CONTACT INFORMATION:',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                _buildText('Phone number', rowData.cellno.toString()),
                const SizedBox(height: 10),
                const Divider(color: Colors.black, endIndent: 20),
                const SizedBox(height: 10),
                const Text('ACADEMIC INFORMATION:',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                _buildText('Last School Attended', rowData.lastSchoolAttended),
                _buildText('LRN', rowData.lrn),
                if (rowData.unpaidBill <= 0)
                  _buildText('Unpaid Bill', rowData.unpaidBill.toString()),
                _buildText('Grade to Enroll',
                    rowData.enrollingGrade.formalLongString()),
                const SizedBox(height: 20),
                const Divider(color: Colors.black, endIndent: 20),
                const SizedBox(height: 10),
                const Text('VALID CREDENTIALS:',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                ...credentialData.entries
                    .map((e) => _buildCredBtn(e.key, e.value)),
                const SizedBox(height: 5),
                _buildText('Additional Info', rowData.additionalInfo),
              ],
            ),
          )
        ],
      ),
      actionButtons: [
        Visibility(
          visible: rowData.status == EnrollmentStatus.pending,
          child: ElevatedButton(
              onPressed: () async {
                await handleApprovingForms(
                    context, rowData, 'Approval', EnrollmentStatus.approved);
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
          visible: rowData.status == EnrollmentStatus.pending,
          child: ElevatedButton(
              onPressed: () async {
                await handleApprovingForms(context, rowData, 'Disapproval',
                    EnrollmentStatus.disapproved);
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

  bool isPdf(Uint8List data) {
    // Check if the list has at least 4 bytes
    if (data.length < 4) return false;

    // Get the first 4 bytes
    String signature = String.fromCharCodes(data.sublist(0, 4));

    // Check if it matches '%PDF'
    return signature == '%PDF';
  }

  Widget _buildCredBtn(CredentialData type, Uint8List? data) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
        child: Row(
          children: [
            Text(type.displayName()),
            const SizedBox(width: 5),
            CustomBtn(
              vertical: 5,
              horizontal: 20,
              colorBg: Colors.blue,
              colorTxt: Colors.white,
              txtSize: 14,
              onTap: () {
                showDialog(
                    context: context,
                    builder: (context) => _buildDialog(type, data));
              },
              btnTxt: 'View',
            )
          ],
        ));
  }

  Widget _buildDialog(CredentialData type, Uint8List? data) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Column(
          children: [
            Text(
              type.displayName(),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ConstrainedBox(
                constraints:
                    const BoxConstraints(maxHeight: 500, maxWidth: 600),
                child: data == null
                    ? const Text('Error: No data found.')
                    : isPdf(data)
                        ? SfPdfViewer.memory(data)
                        : Image.memory(data),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomBtn(
                  vertical: 10,
                  horizontal: 20,
                  colorBg: Colors.red,
                  colorTxt: Colors.white,
                  txtSize: 16,
                  onTap: () {
                    Nav.pop(context);
                  },
                  btnTxt: 'Back',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> handleApprovingForms(
    BuildContext context,
    EnrollmentFormModel rowData,
    String confirmText,
    EnrollmentStatus status,
  ) async {
    try {
      // Auto-download Certificate of Enrollment PDF before approval
      if (status == EnrollmentStatus.approved) {
        final pdfBytes = await generateCertificateOfEnrollmentPdf(
          studentName:
              '${rowData.firstName} ${rowData.middleName} ${rowData.lastName}',
          lrn: rowData.lrn,
          grade: rowData.enrollingGrade.formalLongString(),
          schoolYear: '${rowData.timestamp.year}-${rowData.timestamp.year + 1}',
          dateIssued: DateTime.now(),
        );
        // Convert PDF to base64
        final base64Pdf = base64Encode(pdfBytes);
        // Store base64 PDF in Firestore
        await firebaseAuthProvider.updateStatus(rowData.regNo, status.name,
            pdfBase64: base64Pdf);
        // Auto-download for web
        final blob = html.Blob([pdfBytes], 'application/pdf');
        final url = html.Url.createObjectUrlFromBlob(blob);
        html.Url.revokeObjectUrl(url);
        DelightfulToast.showInfo(context, 'Downloaded',
            'Certificate of Enrollment PDF has been downloaded.');
      }
      final confirm = await showConfirmationDialog(
        context: context,
        title: 'Confirm $confirmText',
        message:
            'Are you sure you want to ${status.asVerb().toLowerCase()} the record for ${rowData.regNo}?',
        confirmText: status.asVerbUpper(),
        cancelText: 'Cancel',
      );
      if (confirm == true) {
        if (!context.mounted) return;
        await showConfirmationDialog(
          context: context,
          title: 'Balance Account creation',
          message: 'A balance account will now be generated for this enrollee.',
          confirmText: 'Ok',
          cancelText: '',
        );
        if (!context.mounted) return;
        final Map<Discount, double>? discountsToApply = await showDialog(
          context: context,
          builder: (context) => const DiscountsToApplyDialog(),
        );
        if (discountsToApply == null) {
          dPrint('No discounts applied.');
        }
        if (context.mounted) showLoadingDialog(context, 'Updating');
        // send notif to parent
        await firebaseAuthProvider.addNotification(
          content:
              'Your child, ${rowData.firstName} ${rowData.middleName} ${rowData.lastName}, has been approved for enrollment!\nRegistration Number: ${rowData.regNo}\nThe Certificate of Enrollment is now available to view.',
          type: 'user',
          uid: rowData.parentsUserId,
          targetType: 'parent',
        );

        // update registration status
        final result =
            await firebaseAuthProvider.updateStatus(rowData.regNo, status.name);
        if (result != null) {
          if (!context.mounted) return;
          DelightfulToast.showError(context, 'Error', result);
        }

        // create balance account if approved
        if (status == EnrollmentStatus.approved) {
          // Save student data to students collection
          final studentResult =
              await firebaseAuthProvider.saveStudentData(rowData);
          if (studentResult != null) {
            if (!context.mounted) return;
            DelightfulToast.showError(context, 'Error',
                'Failed to save student data: $studentResult');
            return;
          }

          // the given fees for this school year based on form from school
          final fees = FeesModel(
            entrance: 1500,
            tuition: 10000,
            misc: 1500,
            books: 2810,
            watchman: 0,
            aircon: 1500,
            others: 0,
          );
          // a null oldacc could mean that this is the first balance account for this user
          final oldAcc = await balanceManager.getBalanceAccount(
            parentsUserId: rowData.parentsUserId,
            pupilID: rowData.regNo,
            schoolYearStart: rowData.timestamp.year,
          );
          final gradeLevelID = await balanceManager.getBalanceID();
          if (gradeLevelID == null) {
            if (!context.mounted) return;
            DelightfulToast.showError(context, 'Error',
                'Failed to generate balance account ID. Try again.');
          }

          /// oldBalanceAcc + currentFees -  discounts
          /// NOTE: discounts apply to the total fee, not per payment
          /// unpaidBill from enrollment form is not consider, because it should be auto detected by system from previous balance
          final balance = FeesModel(
            tuition:
                (fees.tuition - (discountsToApply?[Discount.tuition] ?? 0)) +
                    (oldAcc?.remainingBalance.tuition ?? 0),
            books: (fees.books - (discountsToApply?[Discount.book] ?? 0)) +
                (oldAcc?.remainingBalance.books ?? 0),
            entrance: fees.entrance + (oldAcc?.remainingBalance.entrance ?? 0),
            misc: fees.misc + (oldAcc?.remainingBalance.misc ?? 0),
            watchman: fees.watchman + (oldAcc?.remainingBalance.watchman ?? 0),
            aircon: fees.aircon + (oldAcc?.remainingBalance.aircon ?? 0),
            others: fees.others + (oldAcc?.remainingBalance.others ?? 0),
          );
          final result =
              await balanceManager.createBalanceAccount(BalanceAccount(
            id: '',
            schoolYearStart:
                rowData.timestamp.year, // year which the enrollment was made
            startingBalance: balance,
            remainingBalance: balance,
            gradeLevel: gradeLevelID!,
            parentID: rowData.parentsUserId,
            pupilID: rowData.regNo,
            tuitionDiscount: discountsToApply?[Discount.tuition] ?? 0,
            bookDiscount: discountsToApply?[Discount.book] ?? 0,
          ));
          if (result != null) {
            if (!context.mounted) return;
            DelightfulToast.showError(context, 'Error',
                'Balance account could not be created:\n$result');
            return;
          }
        }
        if (context.mounted) {
          Navigator.pop(context); // Close the loading dialog
          Navigator.pop(context); // Close the current dialog or page
          DelightfulToast.showSuccess(
              context, 'Success', 'Enrollment form ${status.name}.');
        }
      } else {
        dPrint('Approval canceled by user.');
      }
    } catch (e) {
      dPrint('Error: $e');
    }
  }

  Widget _buildText(String title, String value) {
    return Row(
      children: [
        Text(
          '$title:',
          style: const TextStyle(color: Colors.black, fontSize: 18),
        ),
        const SizedBox(
          width: 10,
        ),
        Text(
          value,
          style: const TextStyle(
              color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        )
      ],
    );
  }
}
