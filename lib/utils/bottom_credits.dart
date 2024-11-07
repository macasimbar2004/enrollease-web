import 'package:enrollease_web/utils/colors.dart';
import 'package:enrollease_web/utils/text_styles.dart';
import 'package:flutter/material.dart';

Widget bottomCredits() {
  return Container(
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
                // Add privacy policy navigation
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
                // Add terms of service navigation
              },
              child: Text(
                'Terms of Service  ',
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
