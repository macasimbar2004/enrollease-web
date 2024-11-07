import 'package:enrollease_web/utils/colors.dart';
import 'package:flutter/material.dart';

class Students extends StatefulWidget {
  const Students({super.key, this.userId});
  final String? userId;

  @override
  State<Students> createState() => _StudentsState();
}

class _StudentsState extends State<Students> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.contentColor,
      body: SafeArea(
          child: Container(
        color: Colors.yellow,
      )),
    );
  }
}
