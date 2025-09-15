import 'package:enrollease_web/privacy_policy.dart';
import 'package:enrollease_web/utils/nav.dart';
import 'package:enrollease_web/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class PrivacyPolicyWidget extends StatelessWidget {
  const PrivacyPolicyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Column(
        // mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              child: Markdown(data: privacyPolicy),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomBtn(
                vertical: 10,
                horizontal: 50,
                colorBg: Colors.blue,
                colorTxt: Colors.white,
                txtSize: 16,
                btnTxt: 'Ok',
                onTap: () {
                  Nav.pop(context);
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
