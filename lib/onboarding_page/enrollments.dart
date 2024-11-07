import 'package:enrollease_web/utils/colors.dart';
import 'package:flutter/material.dart';

class Enrollments extends StatefulWidget {
  const Enrollments({super.key, this.userId});
  final String? userId;

  @override
  State<Enrollments> createState() => _EnrollmentsState();
}

class _EnrollmentsState extends State<Enrollments> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.contentColor,
      body: SafeArea(
          child: Container(
        color: Colors.red,
      )),
    );
  }
}
