import 'package:enrollease_web/paginated_table/source/enrollments_source.dart';
import 'package:enrollease_web/utils/nav.dart';
import 'package:enrollease_web/utils/text_validator.dart';
import 'package:enrollease_web/widgets/custom_textformfields.dart';
import 'package:flutter/material.dart';

class DiscountsToApplyDialog extends StatefulWidget {
  const DiscountsToApplyDialog({super.key});

  @override
  State<DiscountsToApplyDialog> createState() => _DiscountsToApplyDialogState();
}

class _DiscountsToApplyDialogState extends State<DiscountsToApplyDialog> {
  final tuitionDiscountController = TextEditingController();
  final bookDiscountController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  Widget msg = SizedBox.shrink();

  void updateMsg(String text) => setState(() {
        msg = Text(
          text,
          style: TextStyle(color: Colors.red),
        );
      });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 500, maxHeight: 250),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                const Text(
                  'Discounts to apply:',
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
                          toShowPrefixIcon: false,
                          toShowLabelText: true,
                          controller: tuitionDiscountController,
                          hintText: 'Tuition Discount (leave blank if none)',
                          iconDataSuffix: Icons.percent,
                        ),
                        const SizedBox(height: 10),
                        CustomTextFormField(
                          toShowIcon: true,
                          toShowPassword: false,
                          toShowPrefixIcon: false,
                          toShowLabelText: true,
                          controller: bookDiscountController,
                          hintText: 'Book Discount (leave blank if none)',
                          iconDataSuffix: Icons.percent,
                        ),
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
                      onPressed: () {
                        final t = tuitionDiscountController.text.trim();
                        final b = bookDiscountController.text.trim();
                        updateMsg('');
                        if (double.tryParse(t) == null || double.tryParse(b) == null) {
                          updateMsg('Please enter valid decimal numbers only.');
                          return;
                        }
                        if (double.parse(t) <= 0 || double.parse(b) <= 0) {
                          updateMsg('All discounts must be greater than 0%.');
                          return;
                        }
                        if (double.parse(t) > 100 || double.parse(b) > 100) {
                          updateMsg('All discounts must be equal to or lesser than 100%.');
                          return;
                        }
                        Nav.pop(context, {
                          Discount.tuition: double.parse(t),
                          Discount.book: double.parse(b),
                        });
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      child: const Text('Apply', style: TextStyle(color: Colors.white)),
                    ),
                    const SizedBox(width: 15),
                    ElevatedButton(
                      onPressed: () {
                        Nav.pop(context);
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text('Skip', style: TextStyle(color: Colors.white)),
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
}
