import 'package:enrollease_web/utils/colors.dart';
import 'package:enrollease_web/utils/text_styles.dart';
import 'package:enrollease_web/widgets/privacy_policy_widget.dart';
import 'package:enrollease_web/widgets/terms_and_conditions_widget.dart';
import 'package:flutter/material.dart';

Widget bottomCredits(BuildContext context) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    height: 50,
    color: CustomColors.contentColor,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          ' © 2023 EnrollEase. All rights reserved.',
          style: CustomTextStyles.lusitanaFont(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          overflow: TextOverflow.clip,
        ),
        Row(
          children: [
            InkWell(
              onTap: () {
                showDialog(context: context, builder: (context) => const PrivacyPolicyWidget());
              },
              child: Text(
                'Privacy Policy',
                style: CustomTextStyles.lusitanaFont(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                overflow: TextOverflow.clip,
              ),
            ),
            const SizedBox(width: 20),
            InkWell(
              onTap: () {
                showDialog(context: context, builder: (context) => const TermsAndConditionsWidget());
              },
              child: Text(
                'Terms & Conditions  ',
                style: CustomTextStyles.lusitanaFont(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                overflow: TextOverflow.clip,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
