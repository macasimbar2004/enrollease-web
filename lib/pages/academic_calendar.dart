import 'package:enrollease_web/utils/colors.dart';
import 'package:enrollease_web/widgets/custom_header.dart';
import 'package:flutter/material.dart';

class AcademicCalendar extends StatefulWidget {
  const AcademicCalendar({super.key, this.userId});
  final String? userId;

  @override
  State<AcademicCalendar> createState() => _AcademicCalendarState();
}

class _AcademicCalendarState extends State<AcademicCalendar> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.contentColor,
      body: SafeArea(
          child: Column(
        children: [
          CustomDrawerHeader(
            headerName: 'academic calendar',
            userId: widget.userId,
          ),
          const SingleChildScrollView(
            child: Column(
              children: [],
            ),
          )
        ],
      )),
    );
  }
}
