import 'package:enrollease_web/states_management/account_data_controller.dart';
import 'package:enrollease_web/utils/app_size.dart';
import 'package:enrollease_web/utils/colors.dart';
import 'package:enrollease_web/utils/firebase_auth.dart';
import 'package:enrollease_web/utils/logos.dart';
import 'package:enrollease_web/utils/text_styles.dart';
import 'package:enrollease_web/widgets/custom_button.dart';
import 'package:enrollease_web/widgets/custom_card.dart';
import 'package:enrollease_web/widgets/custom_loading_dialog.dart';
import 'package:enrollease_web/widgets/custom_textformfields.dart';
import 'package:enrollease_web/widgets/custom_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final userTextController = TextEditingController();
  final passwordTextController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  FirebaseAuthProvider authProvider = FirebaseAuthProvider();
  bool toShow = true;
  bool isLoading = false;
  String providerJobLevel = '';

  Future<void> handleSignIn(BuildContext context) async {
    if (formKey.currentState?.validate() ?? false) {
      setState(() {
        isLoading = true;
      });
      showLoadingDialog(context, 'Signing in...');
      final identification = userTextController.text.trim();
      final password = passwordTextController.text.trim();
      bool signInSuccessful = await authProvider.signIn(context, identification, password);
      await Future.delayed(const Duration(milliseconds: 300));
      setState(() {
        isLoading = false;
      });
      if (signInSuccessful) {
        // If sign-in is successful, set the registrar in the provider
        if (context.mounted) {
          providerJobLevel = Provider.of<AccountDataController>(context, listen: false).currentRegistrar!.jobLevel;
        }

        // Navigate to the MainScreen on successful sign-in

        // Construct the URI for navigation with query parameters
        final uri = Uri(
          path: '/admin',
          queryParameters: {
            'userRole': providerJobLevel.isNotEmpty ? providerJobLevel : '',
          },
        );

        if (context.mounted) {
          await Provider.of<AccountDataController>(context, listen: false).setCurrentRoute(uri.path);
        }

        if (context.mounted) {
          // Navigate to the next page MainScreen()
          context.go(uri.toString());
        }
      } else {
        if (context.mounted) {
          Navigator.pop(context);
          DelightfulToast.showError(context, 'Error', 'Invalid identification or password.');
        }
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    userTextController.dispose();
    passwordTextController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppSizes().init(context);

    return Scaffold(
      backgroundColor: CustomColors.signInColor,
      body: SafeArea(
          bottom: false,
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: SizedBox(
                  height: 600,
                  width: 600,
                  child: CustomCard(
                    color: CustomColors.appBarColor,
                    child: Form(
                      key: formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Align(
                            alignment: Alignment.center,
                            child: CircleAvatar(
                                backgroundColor: Colors.transparent,
                                radius: 120,
                                child: Image.asset(
                                  CustomLogos.enrolleaseLogo,
                                )),
                          ),
                          RichText(
                            text: TextSpan(
                              style: CustomTextStyles.lusitanaFont(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ), // Default style for the text
                              children: const <TextSpan>[
                                TextSpan(text: 'WELCOME BACK\n', style: TextStyle(fontWeight: FontWeight.bold)), // Bold text
                                TextSpan(text: 'PLEASE LOGIN TO YOUR ACCOUNT', style: TextStyle(fontWeight: FontWeight.bold)),
                                // Bold text
                              ],
                            ),
                            textAlign: TextAlign.center, // Center the text
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: CustomTextFormField(
                              toShowPassword: false,
                              toShowIcon: false,
                              toShowPrefixIcon: true,
                              controller: userTextController,
                              hintText: 'Enter ID#',
                              iconData: CupertinoIcons.person_crop_circle,
                              toFillColor: true,
                              fillColor: Colors.white,
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: CustomTextFormField(
                              toShowPassword: toShow,
                              toShowIcon: true,
                              toShowPrefixIcon: true,
                              controller: passwordTextController,
                              hintText: 'Enter Password',
                              iconData: Icons.lock,
                              toFillColor: true,
                              fillColor: Colors.white,
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          SizedBox(
                            width: 200,
                            child: CustomBtn(onTap: isLoading ? null : () async => await handleSignIn(context), vertical: 10, colorBg: CustomColors.contentColor, colorTxt: Colors.white, btnTxt: 'LOGIN', btnFontWeight: FontWeight.normal, textStyle: CustomTextStyles.lusitanaFont(fontSize: 16, color: Colors.white, fontWeight: FontWeight.normal), txtSize: null),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )),
    );
  }
}
