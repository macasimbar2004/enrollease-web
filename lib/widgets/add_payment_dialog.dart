import 'package:enrollease_web/model/fees_model.dart';
import 'package:enrollease_web/model/payment_model.dart';
import 'package:enrollease_web/utils/balance_manager.dart';
import 'package:enrollease_web/utils/nav.dart';
import 'package:enrollease_web/utils/text_validator.dart';
import 'package:enrollease_web/widgets/custom_textformfields.dart';
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

class AddPaymentDialog extends StatefulWidget {
  final Map<String, dynamic> balanceAcc;
  const AddPaymentDialog({required this.balanceAcc, super.key});

  @override
  State<AddPaymentDialog> createState() => _AddPaymentDialogState();
}

class _AddPaymentDialogState extends State<AddPaymentDialog> {
  final Map<FeeType, TextEditingController> feesControllers = {};
  final orController = TextEditingController();
  final dateController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  Widget msg = const SizedBox.shrink();
  bool loading = false;
  final balanceManager = BalanceManager();

  @override
  void initState() {
    super.initState();
    for (final type in FeeType.values) {
      feesControllers.addAll({type: TextEditingController()});
    }
  }

  void updateMsg(String text) => setState(() {
        msg = Text(
          text,
          style: const TextStyle(color: Colors.red),
        );
      });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 250),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                const Text(
                  'Add payment',
                  style: TextStyle(fontSize: 18),
                ),
                LayoutBuilder(builder: (context, constraints) {
                  return ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: constraints.maxWidth - 100,
                      maxHeight: constraints.maxHeight,
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        CustomTextFormField(
                          toShowIcon: true,
                          toShowPassword: false,
                          toShowPrefixIcon: true,
                          iconData: Icons.receipt,
                          toShowLabelText: true,
                          controller: orController,
                          hintText: 'OR',
                          validator: (value) => TextValidator.simpleValidator(value),
                        ),
                        const SizedBox(height: 10),
                        CustomTextFormField(
                          toShowIcon: true,
                          toShowPassword: false,
                          toShowPrefixIcon: true,
                          iconData: Icons.receipt,
                          toShowLabelText: true,
                          controller: dateController,
                          hintText: 'Date',
                          validator: (value) => TextValidator.simpleValidator(value),
                        ),
                        ...feesControllers.entries.map((e) => CustomTextFormField(
                              toShowIcon: true,
                              toShowPassword: false,
                              toShowPrefixIcon: true,
                              iconData: Icons.numbers,
                              toShowLabelText: true,
                              controller: e.value,
                              hintText: '${e.key.formalName()} (leave empty if none)',
                            )),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 20),
                msg,
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        if (loading) return;
                        toggleLoading();
                        updateMsg('');
                        final or = double.tryParse(orController.text.trim());
                        if (or == null || or <= 0) {
                          updateMsg('Invalid OR.');
                          toggleLoading();
                          return;
                        }
                        final date = dateController.text.trim();
                        final Map<FeeType, double> amounts = {};
                        double amountTotal = 0;
                        for (final entry in feesControllers.entries) {
                          final value = double.tryParse(entry.value.text.trim());
                          if (value == null) {
                            updateMsg('Please enter valid decimal numbers only.');
                            toggleLoading();
                            return;
                          }
                          if (value < 1) {
                            updateMsg('All amounts must be greater than 0.');
                            toggleLoading();
                            return;
                          }
                          if (value > FeesModel.fromMap(widget.balanceAcc['remainingBalance']).total()) {
                            updateMsg('All amounts must not exceed the remaining balance of the account.');
                            toggleLoading();
                            return;
                          }
                          amountTotal = amountTotal + value;
                          amounts.addAll({entry.key: value});
                        }
                        if (amountTotal > FeesModel.fromMap(widget.balanceAcc['remainingBalance']).total()) {
                          updateMsg('Total amount must not exceed the remaining balance of the account.');
                          toggleLoading();
                          return;
                        }
                        final result = await balanceManager.createPayment(Payment(
                          id: '',
                          balanceAccID: widget.balanceAcc['id'],
                          or: or,
                          date: date,
                          amount: amounts,
                        ));
                        if (result != null) {
                          updateMsg(result);
                          toggleLoading();
                        } else {
                          if (!context.mounted) return;
                          Nav.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: loading ? Colors.grey : Colors.green),
                      child: const Text('Save', style: TextStyle(color: Colors.white)),
                    ),
                    const SizedBox(width: 15),
                    ElevatedButton(
                      onPressed: () {
                        Nav.pop(context);
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text('Cancel', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void toggleLoading() => setState(() {
        loading = !loading;
      });
}
