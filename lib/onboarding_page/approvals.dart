import 'package:enrollease_web/utils/colors.dart';
import 'package:flutter/material.dart';

class Approvals extends StatefulWidget {
  const Approvals({super.key, this.userId});
  final String? userId;

  @override
  State<Approvals> createState() => _ApprovalsState();
}

class _ApprovalsState extends State<Approvals> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.contentColor,
      body: SafeArea(
          child: Container(
        color: Colors.orange,
      )),
    );
  }
}
