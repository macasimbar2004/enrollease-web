import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enrollease_web/dev.dart';
import 'package:enrollease_web/model/fees_model.dart';
import 'package:enrollease_web/model/payment_model.dart';
import 'package:enrollease_web/utils/balance_manager.dart';
import 'package:enrollease_web/utils/nav.dart';
import 'package:enrollease_web/utils/text_validator.dart';
import 'package:enrollease_web/widgets/custom_textformfields.dart';
import 'package:enrollease_web/widgets/custom_textformfields_mobile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

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
  final VoidCallback? onPaymentAdded;
  const AddPaymentDialog({
    required this.balanceAcc, 
    this.onPaymentAdded,
    super.key,
  });

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
  bool generatingOR = true;
  double? generatedOR; // Store the actual OR value
  final balanceManager = BalanceManager();

  @override
  void initState() {
    super.initState();
    for (final type in FeeType.values) {
      feesControllers.addAll({type: TextEditingController()});
    }

    // Set current date as default
    dateController.text = DateFormat('MM/dd/yyyy').format(DateTime.now());

    // Generate OR number automatically
    _generateORNumber();
  }

  Future<void> _generateORNumber() async {
    setState(() {
      generatingOR = true;
    });

    try {
      // Get the balance account ID
      final balanceAccId = widget.balanceAcc['id'] as String;
      if (balanceAccId.isEmpty) {
        throw Exception('Balance Account ID is empty');
      }

      // Get the last payment with this balance account ID to find the latest OR number
      final querySnapshot = await FirebaseFirestore.instance
          .collection('payments')
          .where('balanceAccID', isEqualTo: balanceAccId)
          .orderBy('or', descending: true)
          .limit(1)
          .get();

      int nextNumber = 1; // default start

      if (querySnapshot.docs.isNotEmpty) {
        // Extract current OR number and increment
        final lastPayment = querySnapshot.docs.first.data();
        final lastOR = lastPayment['or'];

        if (lastOR is double) {
          // Try to extract the incremental part from the OR
          final lastORString = lastOR.toString();
          final dotIndex = lastORString.indexOf('.');
          if (dotIndex != -1) {
            final incrementalPart = lastORString.substring(dotIndex + 1);
            final lastNumber = int.tryParse(incrementalPart);
            if (lastNumber != null) {
              nextNumber = lastNumber + 1;
            }
          }
        }
      }

      // Format the OR number: balanceAccId.incrementalNumber
      final numericBalanceId =
          int.tryParse(balanceAccId.replaceAll(RegExp(r'[^0-9]'), ''));
      if (numericBalanceId == null) {
        throw Exception(
            'Could not extract numeric part from Balance Account ID');
      }

      final formattedOR = double.parse('$numericBalanceId.$nextNumber');

      setState(() {
        orController.text = 'OR-$numericBalanceId-$nextNumber';
        generatedOR = formattedOR; // Store the actual value for saving
        generatingOR = false;
      });
    } catch (e) {
      dPrint('Error generating OR number: $e');
      setState(() {
        orController.text = 'Error generating OR';
        generatedOR = null;
        generatingOR = false;
      });
    }
  }

  void updateMsg(String text) => setState(() {
        msg = Text(
          text,
          style: const TextStyle(color: Colors.red),
        );
      });

  void toggleLoading() => setState(() {
        loading = !loading;
      });

  Widget _buildFeeFieldWithBalance(FeeType feeType, TextEditingController controller) {
    // Get remaining balance for this fee type
    FeesModel remainingBalance = FeesModel.fromMap(widget.balanceAcc['remainingBalance']);
    double remainingForType = 0;
    
    switch (feeType) {
      case FeeType.entrance:
        remainingForType = remainingBalance.entrance;
        break;
      case FeeType.tuition:
        remainingForType = remainingBalance.tuition;
        break;
      case FeeType.misc:
        remainingForType = remainingBalance.misc;
        break;
      case FeeType.books:
        remainingForType = remainingBalance.books;
        break;
      case FeeType.watchman:
        remainingForType = remainingBalance.watchman;
        break;
      case FeeType.aircon:
        remainingForType = remainingBalance.aircon;
        break;
      case FeeType.others:
        remainingForType = remainingBalance.others;
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Fee type field
        customTextFormField2(
          controller,
          const TextStyle(
            fontWeight: FontWeight.w400,
            color: Colors.black,
            fontSize: 16.0,
          ),
          null,
          [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
          ],
          InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: const BorderSide(color: Colors.white, width: 1.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: const BorderSide(color: Colors.blue, width: 1.5),
            ),
            prefixIcon: Icon(Icons.numbers, size: 22, color: Colors.grey.shade600),
            contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
            hintText: '${feeType.formalName()} (leave empty if none)',
            labelText: '${feeType.formalName()} (leave empty if none)',
            labelStyle: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
              fontSize: 14.0,
            ),
          ),
        ),
        // Remaining balance display
        if (remainingForType > 0) ...[
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.info_outline, size: 16, color: Colors.blue.shade600),
                const SizedBox(width: 6),
                Text(
                  'Remaining: ₱${NumberFormat('#,##0.00').format(remainingForType)}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
          ),
        ] else if (remainingForType == 0) ...[
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.shade200, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle_outline, size: 16, color: Colors.green.shade600),
                const SizedBox(width: 6),
                Text(
                  'Fully Paid',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000, maxHeight: 500),
          child: Form(
            key: formKey,
            child: Wrap(
              alignment: WrapAlignment.center,
              runAlignment: WrapAlignment.center,
              children: [
                const SizedBox(height: 15),
                const Text(
                  'Add Payment',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Wrap(
                  alignment: WrapAlignment.center,
                  children: [
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 300,
                          child: generatingOR
                              ? const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        CircularProgressIndicator(),
                                        SizedBox(height: 8),
                                        Text('Generating OR number...',
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey))
                                      ],
                                    ),
                                  ),
                                )
                              : Card(
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side:
                                        BorderSide(color: Colors.grey.shade300),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(Icons.receipt,
                                                size: 22,
                                                color: Colors.grey.shade600),
                                            const SizedBox(width: 8),
                                            const Text(
                                              'OR Number',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          orController.text,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          width: 300,
                          child: _buildDateField(),
                        ),
                      ],
                    ),
                    ...feesControllers.entries.map((e) => Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 10),
                          child: SizedBox(
                            width: 300,
                            child: _buildFeeFieldWithBalance(e.key, e.value),
                          ),
                        )),
                  ],
                ),
                const SizedBox(height: 20),
                msg,
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        if (loading || generatingOR) return;
                        toggleLoading();
                        updateMsg('');

                        // Check if we have a valid OR generated
                        if (generatedOR == null) {
                          updateMsg('Invalid OR number. Please try again.');
                          toggleLoading();
                          return;
                        }

                        final date = dateController.text.trim();
                        double amountTotal = 0;
                        Map<String, dynamic> amountsToSend = {};
                        FeesModel remainingBalance = FeesModel.fromMap(
                            widget.balanceAcc['remainingBalance']);
                        for (final entry in feesControllers.entries) {
                          if (entry.value.text.trim().isEmpty) {
                            continue;
                          }
                          final value =
                              double.tryParse(entry.value.text.trim());
                          if (value == null) {
                            updateMsg(
                                'Please enter valid decimal numbers only.');
                            toggleLoading();
                            return;
                          }
                          if (value <= 0) {
                            updateMsg('All amounts must be greater than 0.');
                            toggleLoading();
                            return;
                          }

                          // Get the remaining balance for this specific fee type
                          double remainingForType = 0;
                          switch (entry.key) {
                            case FeeType.entrance:
                              remainingForType = remainingBalance.entrance;
                              break;
                            case FeeType.tuition:
                              remainingForType = remainingBalance.tuition;
                              break;
                            case FeeType.misc:
                              remainingForType = remainingBalance.misc;
                              break;
                            case FeeType.books:
                              remainingForType = remainingBalance.books;
                              break;
                            case FeeType.watchman:
                              remainingForType = remainingBalance.watchman;
                              break;
                            case FeeType.aircon:
                              remainingForType = remainingBalance.aircon;
                              break;
                            case FeeType.others:
                              remainingForType = remainingBalance.others;
                              break;
                          }

                          if (value > remainingForType) {
                            updateMsg(
                                '${entry.key.formalName()} payment (${value.toStringAsFixed(2)}) exceeds the remaining balance (${remainingForType.toStringAsFixed(2)}).');
                            toggleLoading();
                            return;
                          }

                          amountTotal = amountTotal + value;
                          amountsToSend.addAll({entry.key.name: value});
                        }

                        // Check if any payment amount was entered
                        if (amountTotal <= 0) {
                          updateMsg(
                              'Please enter at least one payment amount.');
                          toggleLoading();
                          return;
                        }

                        final amount = FeesModel.fromMap(amountsToSend);
                        if (amountTotal > remainingBalance.total()) {
                          updateMsg(
                              'Total amount must not exceed the remaining balance of the account.');
                          toggleLoading();
                          return;
                        }
                        final payment = Payment(
                          id: '',
                          balanceAccID: widget.balanceAcc['id'],
                          or: generatedOR!, // Use the stored numeric OR
                          date: date,
                          amount: amount,
                        );
                        String? result;
                        result = await balanceManager.createPayment(payment);
                        dPrint(result);
                        result = await balanceManager.minusRemainingBalance(
                            payment: payment);
                        dPrint(result);
                        if (result != null) {
                          updateMsg(result);
                          toggleLoading();
                        } else {
                          // Payment successful - close dialog immediately for smooth UX
                          if (!context.mounted) return;
                          Nav.pop(context);
                          
                          // Refresh parent data in background after dialog closes
                          if (widget.onPaymentAdded != null) {
                            widget.onPaymentAdded!();
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: loading || generatingOR
                              ? Colors.grey
                              : Colors.green),
                      child: const Text('Save',
                          style: TextStyle(color: Colors.white)),
                    ),
                    const SizedBox(width: 15),
                    ElevatedButton(
                      onPressed: () {
                        Nav.pop(context);
                      },
                      style:
                          ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text('Cancel',
                          style: TextStyle(color: Colors.white)),
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
  }
}
