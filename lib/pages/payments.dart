import 'package:enrollease_web/paginated_table/table/payments_table.dart';
import 'package:enrollease_web/states_management/side_menu_index_controller.dart';
import 'package:enrollease_web/utils/colors.dart';
import 'package:enrollease_web/widgets/add_payment_dialog.dart';
import 'package:enrollease_web/widgets/custom_button.dart';
import 'package:enrollease_web/widgets/custom_header.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
  final String userId;
  const PaymentsPage({required this.userId, super.key});

  @override
  State<PaymentsPage> createState() => _PaymentsPageState();
}

class _PaymentsPageState extends State<PaymentsPage> {
  // late Map<String, dynamic> data;

  // @override
  // void initState() {
  //   super.initState();

  //   dPrint(data);
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.appBarColor,
      body: SafeArea(
          child: Column(
        children: [
          CustomDrawerHeader(
            headerName: 'Payments',
            userId: widget.userId,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
                child: SizedBox(
                  width: 200,
                  child: CustomBtn(
                    vertical: 10,
                    colorBg: Colors.red,
                    colorTxt: Colors.white,
                    txtSize: 18,
                    onTap: () {
                      context.read<SideMenuIndexController>().setSelectedIndex(3);
                    },
                    btnTxt: 'Back',
                    btnIcon: Icons.arrow_back,
                    textStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
              Consumer<SideMenuIndexController>(builder: (context, sideMenu, child) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
                  child: SizedBox(
                    width: 200,
                    child: CustomBtn(
                      vertical: 10,
                      colorBg: CustomColors.color1,
                      colorTxt: Colors.white,
                      txtSize: 18,
                      onTap: () {
                        showDialog(context: context, builder: (context) => AddPaymentDialog(sideMenu.data));
                      },
                      btnTxt: 'Add Payment',
                      btnIcon: Icons.add,
                      textStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18),
                    ),
                  ),
                );
              })
            ],
          ),
          Expanded(
              child: PaymentsTable(
            userId: widget.userId,
            balanceAccID: Provider.of<SideMenuIndexController>(context).data['id'],
          ))
        ],
      )),
    );
  }
}
