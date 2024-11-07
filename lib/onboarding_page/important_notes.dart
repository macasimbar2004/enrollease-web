import 'package:enrollease_web/utils/colors.dart';
import 'package:flutter/material.dart';

class ImportantNotes extends StatefulWidget {
  const ImportantNotes({super.key, this.userId});
  final String? userId;

  @override
  State<ImportantNotes> createState() => _ImportantNotesState();
}

class _ImportantNotesState extends State<ImportantNotes> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.contentColor,
      body: SafeArea(
          child: Container(
        color: Colors.green,
      )),
    );
  }
}
