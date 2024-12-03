import 'package:enrollease_web/paginated_table/table/balance_acc_forms_table.dart';
import 'package:enrollease_web/utils/colors.dart';
import 'package:enrollease_web/widgets/custom_header.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StatementOfAccount extends StatefulWidget {
  final String? userId;
  const StatementOfAccount({super.key, this.userId});

  @override
  State<StatementOfAccount> createState() => _StatementOfAccountState();
}

class _StatementOfAccountState extends State<StatementOfAccount> {
  late final List<DateTimeRange> dates;
  late DateTimeRange selectedDate;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    dates = List.generate(10, (i) {
      return DateTimeRange(
        start: DateTime(DateTime.now().year - (i + 1)),
        end: DateTime(
          DateTime.now().year - (i),
        ),
      );
    });
    selectedDate = dates.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.contentColor,
      body: SafeArea(
        child: Column(
          children: [
            CustomDrawerHeader(
              headerName: 'Statement Of Account',
              userId: widget.userId,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'School year: ',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                const SizedBox(
                  width: 10,
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white.withOpacity(0.8),
                  ),
                  child: DropdownButton<DateTimeRange>(
                    borderRadius: BorderRadius.circular(20),
                    value: selectedDate,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    underline: const SizedBox.shrink(),
                    items: dates.map((e) {
                      return DropdownMenuItem<DateTimeRange>(
                        value: e,
                        child: Text(
                          '${DateFormat('yyyy').format(e.start)} - ${DateFormat('yyyy').format(e.end)}',
                          style: const TextStyle(color: Colors.black),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedDate = value;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Expanded(
              child: SingleChildScrollView(
                child: BalanceAccountsTable(
                  range: selectedDate,
                  userId: widget.userId!,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
