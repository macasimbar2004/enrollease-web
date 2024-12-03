import 'package:enrollease_web/paginated_table/table/payments_table.dart';
import 'package:enrollease_web/utils/colors.dart';
import 'package:enrollease_web/widgets/add_payment_dialog.dart';
import 'package:enrollease_web/widgets/custom_button.dart';
import 'package:enrollease_web/widgets/custom_header.dart';
import 'package:enrollease_web/widgets/custom_loading_dialog.dart';
import 'package:flutter/material.dart';

//  return {
//           'id': doc.id,
//           'schoolYearStart': docData['schoolYearStart'],
//           'startingBalance': FeesModel.fromMap(docData['startingBalance']).toMap(),
//           'remainingBalance': FeesModel.fromMap(docData['remainingBalance']).toMap(),
//           'gradeLevel': docData['gradeLevel'],
//           'parent': parent,
//           'pupil': pupil,
//           'tuitionDiscount': docData['tuitionDiscount'],
//           'bookDiscount': docData['bookDiscount'],
//         }

class PaymentsPage extends StatefulWidget {
  final Map<String, dynamic> data;
  final String userId;
  const PaymentsPage({required this.userId, required this.data, super.key});

  @override
  State<PaymentsPage> createState() => _PaymentsPageState();
}

class _PaymentsPageState extends State<PaymentsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.contentColor,
      body: SafeArea(
          child: Column(
        children: [
          CustomDrawerHeader(
            headerName: 'Payments',
            userId: widget.userId,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
              child: SizedBox(
                width: 200,
                child: CustomBtn(
                  vertical: 10,
                  colorBg: CustomColors.color1,
                  colorTxt: Colors.white,
                  txtSize: 18,
                  onTap: () async {
                    showLoadingDialog(context, 'Loading');
                    if (context.mounted) {
                      Navigator.pop(context);
                      showDialog(
                          context: context,
                          builder: (context) => AddPaymentDialog(
                                balanceAcc: widget.data,
                              ));
                    }
                  },
                  btnTxt: 'Add Payment',
                  btnIcon: Icons.add,
                  textStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18),
                ),
              ),
            ),
          ),
          Expanded(
              child: PaymentsTable(
            userId: widget.userId,
          ))
        ],
      )),
    );
  }
}
