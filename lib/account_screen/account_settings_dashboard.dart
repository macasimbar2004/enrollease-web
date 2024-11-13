import 'package:enrollease_web/states_management/side_menu_drawer_controller.dart';
import 'package:enrollease_web/states_management/side_menu_index_controller.dart';
import 'package:enrollease_web/utils/app_size.dart';
import 'package:enrollease_web/utils/colors.dart';
import 'package:enrollease_web/utils/logos.dart';
import 'package:enrollease_web/widgets/responsive_widget.dart';
import 'package:enrollease_web/utils/text_validator.dart';
import 'package:enrollease_web/widgets/custom_button.dart';
import 'package:enrollease_web/widgets/custom_textformfields.dart';
import 'package:enrollease_web/widgets/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

class AccountSettingsDashboard extends StatefulWidget {
  final String? userId;

  const AccountSettingsDashboard({super.key, this.userId});

  @override
  State<AccountSettingsDashboard> createState() =>
      _AccountSettingsDashboardState();
}

class _AccountSettingsDashboardState extends State<AccountSettingsDashboard> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _passwordFormKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController contactNumberController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController currentPasswordController =
      TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final ImageService _imageService = ImageService();

  String? name;
  String? contactNumber;
  String? email;
  String? role;
  String? division;

  String? currentPassword;
  String error = '';
  Uint8List? _image;
  bool changePass = false;
  bool changePassTapped = false;
  bool isLoading = true;
  bool isImageChanged = false;
  Map<String, dynamic> data = {};

  bool toSave = false;
  bool toSavePassword = false;

  @override
  void initState() {
    super.initState();
  }

  void selectImage(BuildContext context) async {
    try {
      Uint8List? img = await _imageService.pickImage(context);
      if (img != null) {
        if (kDebugMode) print("Image picked successfully.");
        setState(() {
          _image = img;
          isImageChanged = true;
        });
      } else {
        if (kDebugMode) print("Image picking failed or was cancelled.");
        setState(() {
          isImageChanged = false;
        });
      }
    } catch (e) {
      if (kDebugMode) print("Error picking image: ${e.toString()}");
      setState(() {
        isImageChanged = false;
      });
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    contactNumberController.dispose();
    emailController.dispose();
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppSizes().init(context);

    final isSmallScreen = ResponsiveWidget.isSmallScreen(context);
    final isMediumScreen = ResponsiveWidget.isMediumScreen(context);
    final isLargeScreen = ResponsiveWidget.isLargeScreen(context);
    final readMenuVisibility = Provider.of<SideMenuIndexController>(context,
        listen: false); // Access the provider

    // Get the current index selected before going back
    int currentIndex =
        context.read<SideMenuIndexController>().currentIndexSelected;

    return Container(
      height: AppSizes.screenHeight,
      decoration: const BoxDecoration(
        color: CustomColors.contentColor,
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 50.0, left: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isSmallScreen || isMediumScreen)
                    IconButton(
                      onPressed: () {
                        context.read<SideMenuDrawerController>().controlMenu();
                      },
                      icon: const Icon(Icons.menu),
                    ),
                  if (!readMenuVisibility.isMenuVisible && isLargeScreen)
                    IconButton(
                      onPressed: () {
                        context
                            .read<SideMenuIndexController>()
                            .toggleMenuVisibility();
                      },
                      icon: const Icon(Icons.menu),
                    ),
                  Image.asset(
                    CustomLogos.enrolleaseLogo,
                    height: 40.0,
                    width: 40.0,
                  ),
                  const Flexible(
                    fit: FlexFit.tight,
                    child: Text(
                      'Profile',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 45),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 100,
            ),
            Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 15.0,
                runSpacing: 10.0,
                children: [
                  if (ResponsiveWidget.isSmallScreen(context) ||
                      ResponsiveWidget.isMediumScreen(context))
                    Center(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        SizedBox(
                          height: 250,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(25),
                            child: _image != null
                                ? kIsWeb
                                    ? Image.memory(
                                        _image!,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.memory(
                                        _image!,
                                        fit: BoxFit.cover,
                                      )
                                : Image.asset(
                                    CustomLogos.editProfileImage,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => selectImage(context),
                          child: const Text(
                            'Edit',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        if (isImageChanged)
                          CustomActionButton(
                            text: "Save",
                            backgroundColor: Colors.green,
                            textColor: Colors.white,
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {}
                            },
                          ),
                      ],
                    )),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        width: 300,
                        child: changePass == false
                            ? accountInformation(context, currentIndex)
                            : accountChangePassword(context, currentIndex),
                      ),
                      if (ResponsiveWidget.isLargeScreen(context))
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            SizedBox(
                              height: 369,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(25),
                                child: _image != null
                                    ? kIsWeb
                                        ? Image.memory(
                                            _image!,
                                            fit: BoxFit.cover,
                                          )
                                        : Image.memory(
                                            _image!,
                                            fit: BoxFit.cover,
                                          )
                                    : Image.asset(
                                        CustomLogos.editProfileImage,
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ),
                            TextButton(
                              onPressed: () => selectImage(context),
                              child: const Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'Edit ',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    TextSpan(
                                      text: '(Image should be Min. of 1mb)',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            if (isImageChanged)
                              CustomActionButton(
                                text: "Save",
                                backgroundColor: Colors.green,
                                textColor: Colors.white,
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {}
                                },
                              ),
                          ],
                        ),
                    ],
                  ),
                ]),
          ],
        ),
      ),
    );
  }

  Widget accountInformation(BuildContext context, int currentIndex) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Name',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
          ),
          const SizedBox(height: 5),
          customTextFormField2(
            nameController,
            const TextStyle(color: Colors.black),
            50,
            null,
            const InputDecoration(
              labelStyle: TextStyle(color: Colors.black),
              filled: true,
              fillColor: Colors.white,
            ),
            validator: (value) =>
                value == null || value.isEmpty ? 'Name is required.' : null,
            enabled: nameController.text == 'Main Admin' ? false : true,
            onChanged: (value) {
              setState(() {
                if (name != value) {
                  toSave = true;
                } else {
                  toSave = false;
                }
              });
            },
          ),
          const SizedBox(height: 5),
          const Text(
            'Contact Number',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 5),
          customTextFormField2(
            contactNumberController,
            const TextStyle(color: Colors.black),
            11,
            [
              FilteringTextInputFormatter.digitsOnly,
            ],
            const InputDecoration(
              labelStyle: TextStyle(color: Colors.black),
              filled: true,
              fillColor: Colors.white,
            ),
            validator: (value) => TextValidator.validateContact(value),
            onChanged: (value) {
              setState(() {
                if (value.trim() != contactNumber) {
                  toSave = true;
                } else {
                  toSave = false;
                }
              });
            },
          ),
          const SizedBox(height: 5),
          const Text(
            'Email',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
          ),
          const SizedBox(height: 5),
          customTextFormField2(
            emailController,
            const TextStyle(color: Colors.black),
            50,
            null,
            const InputDecoration(
                labelStyle: TextStyle(color: Colors.black),
                filled: true,
                fillColor: Colors.white),
            validator: (value) => TextValidator.validateEmail(value),
            onChanged: (value) {
              setState(() {
                if (email != value) {
                  toSave = true;
                } else {
                  toSave = false;
                }
              });
            },
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (changePassTapped)
                  const SpinKitFadingCircle(
                    color: Colors.blue,
                    size: 24.0,
                  ),
                if (changePassTapped)
                  const Text(
                    'Updating',
                    style: TextStyle(color: Colors.blueAccent),
                  ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    if (mounted) {
                      setState(() {
                        changePass = !changePass;
                      });
                    }
                  },
                  child: const Text(
                    'Change Password',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomActionButton(
                text: "Back",
                backgroundColor: Colors.grey,
                textColor: Colors.black,
                onPressed: () {
                  // Handle back navigation to basePage based on currentIndex
                  context
                      .read<SideMenuIndexController>()
                      .updatePageIndex(currentIndex);
                },
              ),
              if (toSave)
                CustomActionButton(
                  text: "Save",
                  backgroundColor: Colors.blue,
                  textColor: Colors.white,
                  onPressed: changePassTapped
                      ? null
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            try {
                              if (mounted) {
                                setState(() {
                                  changePassTapped = true;
                                });
                                // _handleBasicSaveInfo(context,
                                //     int.parse(widget.userId.toString()));
                              }
                            } catch (e) {
                              // Handle errors during saving data
                              if (mounted) {
                                setState(() {
                                  changePassTapped = false;
                                });
                                Future.delayed(const Duration(seconds: 1), () {
                                  if (mounted) {
                                    setState(() {
                                      changePassTapped = false;
                                    });
                                  }
                                });
                              }
                              if (kDebugMode) {
                                print('Failed to save data: $e');
                              }
                            }
                          }
                        },
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget accountChangePassword(BuildContext context, int currentIndex) {
    return Form(
      key: _passwordFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Current Password',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 5),
          customTextFormField2(
            currentPasswordController,
            const TextStyle(
              color: Colors.black,
            ),
            50,
            null,
            const InputDecoration(
              labelStyle: TextStyle(color: Colors.black),
              filled: true,
              fillColor: Colors.white,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Current password is required.';
              } else {
                debugPrint('Value entered: ${value.trim()}');
                debugPrint('Current password: ${currentPassword?.trim()}');
                if (value.trim() != currentPassword!.trim()) {
                  return 'Current password does not match!';
                }
              }
              return null;
            },
            onChanged: (value) {
              setState(() {
                if (value.isNotEmpty &&
                    newPasswordController.text.isNotEmpty &&
                    confirmPasswordController.text.isNotEmpty) {
                  toSavePassword = true;
                } else {
                  toSavePassword = false;
                }
              });
            },
          ),
          const SizedBox(height: 5),
          const Text(
            'New Password',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 5),
          customTextFormField2(
            newPasswordController,
            const TextStyle(color: Colors.black),
            50,
            null,
            const InputDecoration(
              labelStyle: TextStyle(color: Colors.black),
              filled: true,
              fillColor: Colors.white,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'New password is required.';
              } else if (value.trim() !=
                  confirmPasswordController.text.trim()) {
                return 'Passwords do not match.';
              }
              return null;
            },
            onChanged: (value) {
              setState(() {
                if (value.isNotEmpty &&
                    currentPasswordController.text.isNotEmpty &&
                    confirmPasswordController.text.isNotEmpty) {
                  toSavePassword = true;
                } else {
                  toSavePassword = false;
                }
              });
            },
          ),
          const SizedBox(height: 5),
          const Text(
            'Confirm Password',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 5),
          customTextFormField2(
            confirmPasswordController,
            const TextStyle(color: Colors.black),
            50,
            null,
            const InputDecoration(
              labelStyle: TextStyle(color: Colors.black),
              filled: true,
              fillColor: Colors.white,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please confirm your new password.';
              } else if (value.trim() != newPasswordController.text.trim()) {
                return 'Passwords do not match.';
              }
              return null;
            },
            onChanged: (value) {
              setState(() {
                if (value.isNotEmpty &&
                    currentPasswordController.text.isNotEmpty &&
                    newPasswordController.text.isNotEmpty) {
                  toSavePassword = true;
                } else {
                  toSavePassword = false;
                }
              });
            },
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Row(
              children: [
                if (changePassTapped)
                  const SpinKitFadingCircle(
                    color: Colors.blue,
                    size: 24.0,
                  ),
                if (changePassTapped)
                  const Text(
                    'Updating',
                    style: TextStyle(color: Colors.blueAccent),
                  ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    if (mounted) {
                      setState(() {
                        changePass = !changePass;
                      });
                    }
                  },
                  child: const Text(
                    'Return',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomActionButton(
                text: "Back",
                backgroundColor: Colors.grey,
                textColor: Colors.black,
                onPressed: () {
                  // Handle back navigation to basePage based on currentIndex
                  context
                      .read<SideMenuIndexController>()
                      .updatePageIndex(currentIndex);
                },
              ),
              if (toSavePassword)
                CustomActionButton(
                  text: "Save",
                  backgroundColor: Colors.blue,
                  textColor: Colors.white,
                  onPressed: changePassTapped
                      ? null
                      : () async {
                          if (_passwordFormKey.currentState!.validate()) {
                            try {
                              if (mounted) {
                                setState(() {
                                  changePassTapped = true;
                                });
                                // await _handleSavePassword(context,
                                //     int.parse(widget.userId.toString()));
                              }
                            } catch (e) {
                              // Handle errors during password change
                              if (mounted) {
                                setState(() {
                                  changePassTapped = false;
                                });
                                Future.delayed(const Duration(seconds: 1), () {
                                  if (mounted) {
                                    setState(() {
                                      changePassTapped = false;
                                    });
                                  }
                                });
                              }

                              debugPrint('Failed to change password: $e');
                            }
                          }
                        },
                ),
            ],
          ),
        ],
      ),
    );
  }
}


// isLoading
//           ? const Center(
//               child: SpinKitFadingCircle(
//                 color: Colors.blue,
//                 size: 34.0,
//               ),
//             )
//           :