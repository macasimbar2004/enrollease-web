import 'package:enrollease_web/paginated_table/table/enrollments_table.dart';
import 'package:enrollease_web/utils/colors.dart';
import 'package:enrollease_web/widgets/custom_header.dart';
import 'package:flutter/material.dart';

class Enrollments extends StatefulWidget {
  const Enrollments({super.key, this.userId});
  final String? userId;

  @override
  State<Enrollments> createState() => _EnrollmentsState();
}

class _EnrollmentsState extends State<Enrollments> {
  TableEnrollmentStatus eStatus = TableEnrollmentStatus.any;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.contentColor,
      body: SafeArea(
          child: Column(
        children: [
          CustomDrawerHeader(
            headerName: 'Enrollments',
            userId: widget.userId,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text(
                  'Status: ',
                  style: TextStyle(color: Colors.white),
                ),
                const SizedBox(width: 10),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white,
                  ),
                  child: DropdownButton<TableEnrollmentStatus>(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    underline: const SizedBox.shrink(),
                    borderRadius: BorderRadius.circular(20),
                    value: eStatus,
                    items: TableEnrollmentStatus.values
                        .map((e) => DropdownMenuItem(
                            value: e,
                            child: Text(
                              e.formalName(),
                              style: const TextStyle(color: Colors.black),
                            )))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        eStatus = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 30),
              ],
            ),
          ),
          Expanded(child: EnrollmentsTable(eStatus))
        ],
      )),
    );
  }
}
