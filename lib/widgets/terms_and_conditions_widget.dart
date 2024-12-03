import 'package:enrollease_web/terms_and_conditions.dart';
import 'package:enrollease_web/utils/nav.dart';
import 'package:enrollease_web/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class TermsAndConditionsWidget extends StatelessWidget {
  const TermsAndConditionsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: Column(
        children: [
          Expanded(child: Markdown(data: termsAndConditions)),
          CustomBtn(
            vertical: 10,
            colorBg: Colors.blue,
            colorTxt: Colors.white,
            txtSize: 16,
            onTap: () {
              Nav.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
