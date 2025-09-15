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

  @override
  void initState() {
    super.initState();
    // Check if there's already a user session on startup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final accountController =
          Provider.of<AccountDataController>(context, listen: false);
      if (accountController.isLoggedIn) {
        // User is already logged in, navigate to main screen
        final uri = Uri(
          path: '/admin',
          queryParameters: {
            'userRole': accountController.currentRegistrar?.jobLevel ?? '',
          },
        );
        context.go(uri.toString());
      }
    });
  }

  Future<void> handleSignIn(BuildContext context) async {
    if (formKey.currentState?.validate() ?? false) {
      setState(() {
        isLoading = true;
      });
      showLoadingDialog(context, 'Signing in...');
      final identification = userTextController.text.trim();
      final password = passwordTextController.text.trim();
      bool signInSuccessful =
          await authProvider.signIn(context, identification, password);
      await Future.delayed(const Duration(milliseconds: 300));
      if (!context.mounted) return;

      // Handle successful sign in
      if (signInSuccessful) {
        final accountController =
            Provider.of<AccountDataController>(context, listen: false);
        final registrar = accountController.currentRegistrar!;

        // Update last activity time
        accountController.updateLastActivityTime();

        // Add notification
        await FirebaseAuthProvider().addNotification(
          content:
              'Registrar ${registrar.firstName} ${registrar.lastName} has logged in.\nRegistration Number: $identification',
          type: 'registrar',
          uid: '',
          targetType: 'registrar',
        );

        setState(() {
          isLoading = false;
        });

        if (context.mounted) {
          providerJobLevel = registrar.jobLevel;
        }

        // Construct the URI for navigation with query parameters
        final uri = Uri(
          path: '/admin',
          queryParameters: {
            'userRole': providerJobLevel.isNotEmpty ? providerJobLevel : '',
          },
        );

        if (context.mounted) {
          await accountController.setCurrentRoute(uri.path);
        }

        if (context.mounted) {
          // Navigate to the next page MainScreen()
          context.go(uri.toString());
        }
      } else {
        if (context.mounted) {
          Navigator.pop(context);
          DelightfulToast.showError(
              context, 'Error', 'Invalid identification or password.');
        }
        setState(() {
          isLoading = false;
        });
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 450),
                child: CustomCard(
                  elevation: 4.0,
                  color: CustomColors.appBarColor,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo
                        Align(
                          alignment: Alignment.center,
                          child: CircleAvatar(
                              backgroundColor: Colors.white.withValues(alpha: 0.9),
                              radius: 80,
                              child: Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Image.asset(
                                  CustomLogos.enrolleaseLogo,
                                  fit: BoxFit.contain,
                                ),
                              )),
                        ),
                        const SizedBox(height: 24),

                        // Welcome text
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: RichText(
                            text: TextSpan(
                              style: CustomTextStyles.lusitanaFont(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              children: const <TextSpan>[
                                TextSpan(
                                    text: 'WELCOME BACK\n',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                TextSpan(
                                    text: 'PLEASE LOGIN TO YOUR ACCOUNT',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 30),

                        // User ID field
                        CustomTextFormField(
                          toShowPassword: false,
                          toShowIcon: false,
                          toShowPrefixIcon: true,
                          controller: userTextController,
                          hintText: 'Enter ID#',
                          iconData: CupertinoIcons.person_crop_circle,
                          toFillColor: true,
                          fillColor: Colors.white,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your ID';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Password field
                        CustomTextFormField(
                          toShowPassword: toShow,
                          toShowIcon: true,
                          toShowPrefixIcon: true,
                          controller: passwordTextController,
                          hintText: 'Enter Password',
                          iconData: Icons.lock,
                          toFillColor: true,
                          fillColor: Colors.white,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 30),

                        // Login button
                        SizedBox(
                          width: 220,
                          child: CustomBtn(
                            onTap: isLoading
                                ? null
                                : () async => await handleSignIn(context),
                            vertical: 12,
                            height: 48,
                            colorBg: CustomColors.contentColor,
                            colorTxt: Colors.white,
                            btnTxt: 'LOGIN',
                            btnFontWeight: FontWeight.w600,
                            textStyle: CustomTextStyles.lusitanaFont(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                            txtSize: null,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
