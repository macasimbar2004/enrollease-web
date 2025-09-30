import 'package:enrollease_web/utils/theme_colors.dart';
import 'package:enrollease_web/utils/text_styles.dart';
import 'package:enrollease_web/widgets/privacy_policy_widget.dart';
import 'package:enrollease_web/widgets/terms_and_conditions_widget.dart';
import 'package:enrollease_web/states_management/theme_provider.dart';
import 'package:enrollease_web/states_management/footer_config_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Widget bottomCredits(BuildContext context) {
  return Consumer2<ThemeProvider, FooterConfigProvider>(
    builder: (context, themeProvider, footerProvider, child) {
      return Container(
        height: 50,
        color: themeProvider.currentColors['content'] ??
            ThemeColors.content(context),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              footerProvider.copyrightText,
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
                    showDialog(
                        context: context,
                        builder: (context) => const PrivacyPolicyWidget());
                  },
                  child: Text(
                    footerProvider.privacyPolicyText,
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
                    showDialog(
                        context: context,
                        builder: (context) => const TermsAndConditionsWidget());
                  },
                  child: Text(
                    footerProvider.termsAndConditionsText,
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
    },
  );
}
