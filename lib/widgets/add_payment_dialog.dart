import 'package:enrollease_web/dev.dart';
import 'package:enrollease_web/model/fees_model.dart';
import 'package:enrollease_web/model/payment_model.dart';
import 'package:enrollease_web/states_management/side_menu_index_controller.dart';
import 'package:enrollease_web/utils/balance_manager.dart';
import 'package:enrollease_web/utils/nav.dart';
import 'package:enrollease_web/utils/text_validator.dart';
import 'package:enrollease_web/widgets/custom_textformfields.dart';
import 'package:enrollease_web/widgets/custom_textformfields_mobile.dart';
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

class AddPaymentDialog extends StatefulWidget {
  final Map<String, dynamic> balanceAcc;
  const AddPaymentDialog(this.balanceAcc, {super.key});

  @override
  State<AddPaymentDialog> createState() => _AddPaymentDialogState();
}

class _AddPaymentDialogState extends State<AddPaymentDialog> {
  final Map<FeeType, TextEditingController> feesControllers = {};
  final orController = TextEditingController();
  final dateController = TextEditingController();
  final scrollController = ScrollController();
  final formKey = GlobalKey<FormState>();
  Widget msg = const SizedBox.shrink();
  bool loading = false;
  final balanceManager = BalanceManager();
  late FeesModel remainingBalance;
  late Map<String, dynamic> balanceAcc;

  @override
  void initState() {
    super.initState();
    balanceAcc = widget.balanceAcc;
    remainingBalance = FeesModel.fromMap(balanceAcc['remainingBalance']);
    dPrint('yes $remainingBalance');
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
          constraints: const BoxConstraints(maxWidth: 1000, maxHeight: 500),
          child: Form(
            key: formKey,
            child: Scrollbar(
              controller: scrollController,
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 15),
                    const Text(
                      'Add payment',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      alignment: WrapAlignment.center,
                      children: [
                        SizedBox(
                          width: 300,
                          child: CustomTextFormField(
                            toShowIcon: false,
                            toShowPassword: false,
                            toShowPrefixIcon: true,
                            iconData: Icons.receipt,
                            toShowLabelText: true,
                            controller: orController,
                            hintText: 'OR',
                            validator: (value) => TextValidator.simpleValidator(value),
                          ),
                        ),
                        const SizedBox(width: 10, height: 10),
                        SizedBox(
                          width: 300,
                          child: _buildDateField(),
                        ),
                      ],
                    ),
                    Wrap(
                      alignment: WrapAlignment.center,
                      children: feesControllers.entries.map((e) {
                        final double feeRemainingBalance = balanceAcc['remainingBalance'][e.key.name];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                          child: SizedBox(
                            width: 300,
                            child: CustomTextFormField(
                              toShowIcon: false,
                              toShowPassword: false,
                              toShowPrefixIcon: true,
                              iconData: Icons.numbers,
                              toShowLabelText: true,
                              controller: e.value,
                              helperText: 'Remaining is ${formatTotal(feeRemainingBalance)}',
                              hintText: '${e.key.formalName()} (leave empty if none)',
                              validator: (value) {
                                dPrint(feeRemainingBalance);
                                if (value == null || value.isEmpty) {
                                  return null;
                                }
                                if (double.parse(value) > feeRemainingBalance) {
                                  return 'Payment must not exceed remaining balance.';
                                }
                                return null;
                              },
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    msg,
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            if (!formKey.currentState!.validate()) return;
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
                            double amountTotal = 0;
                            Map<String, dynamic> amountsToSend = {};
                            FeesModel remainingBalance = FeesModel.fromMap(balanceAcc['remainingBalance']);
                            for (final entry in feesControllers.entries) {
                              final value = double.tryParse(entry.value.text.trim());
                              if (entry.value.text.trim().isEmpty) {
                                continue;
                              }
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
                              if (value > remainingBalance.total()) {
                                updateMsg('All amounts must not exceed the remaining balance of the account.');
                                toggleLoading();
                                return;
                              }
                              amountTotal = amountTotal + value;
                              amountsToSend.addAll({entry.key.name: value});
                            }
                            final amount = FeesModel.fromMap(amountsToSend);
                            if (amountTotal > remainingBalance.total()) {
                              updateMsg('Total amount must not exceed the remaining balance of the account.');
                              toggleLoading();
                              return;
                            }
                            final payment = Payment(
                              id: '',
                              balanceAccID: balanceAcc['id'],
                              or: or,
                              date: date,
                              amount: amount,
                            );
                            String? result;
                            result = await balanceManager.createPayment(payment);
                            dPrint(result);
                            result = await balanceManager.minusRemainingBalance(payment: payment);
                            dPrint(result);
                            if (!context.mounted) return;
                            if (result == null) {
                              Provider.of<SideMenuIndexController>(context, listen: false).setData(balanceAcc);
                              setState(() {
                                balanceAcc = Provider.of<SideMenuIndexController>(context, listen: false).data;
                              });
                            }
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
        ),
      ),
    );
  }

  Widget _buildDateField() {
    return CustomTextFormFieldMobile(
      toShow: false,
      controller: dateController,
      hintText: 'Date',
      isDateTime: true,
      iconDataSuffix: Icons.calendar_month,
      toShowIcon: true,
      toShowPrefixIcon: false,
      validator: (value) => TextValidator.simpleValidator(value),
    );
    // return Row(
    //   children: [
    //     Expanded(
    //       flex: 3,
    //       child: CustomTextFormFieldMobile(
    //         toShow: false,
    //         controller: dateOfBirthController,
    //         ageController: ageController,
    //         hintText: 'Date of Birth',
    //         isDateTime: true,
    //         iconDataSuffix: Icons.calendar_month,
    //         toShowIcon: true,
    //         toShowPrefixIcon: false,
    //         validator: validator,
    //       ),
    //     ),
    //     const SizedBox(width: 5),
    //     Expanded(
    //       child: CustomTextFormFieldMobile(
    //         toShow: false,
    //         controller: ageController,
    //         hintText: 'Age',
    //         isDateTime: true,
    //         leftPadding: 20,
    //         toShowIcon: false,
    //         toShowPrefixIcon: false,
    //         validator: validator,
    //       ),
    //     ),
    //   ],
    // );
  }

  void toggleLoading() => setState(() {
        loading = !loading;
      });
}
