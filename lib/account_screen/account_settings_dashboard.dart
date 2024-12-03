import 'package:enrollease_web/dev.dart';
import 'package:enrollease_web/states_management/account_data_controller.dart';
import 'package:enrollease_web/states_management/side_menu_index_controller.dart';
import 'package:enrollease_web/utils/app_size.dart';
import 'package:enrollease_web/utils/colors.dart';
import 'package:enrollease_web/utils/firebase_auth.dart';
import 'package:enrollease_web/utils/logos.dart';
import 'package:enrollease_web/widgets/custom_header.dart';
import 'package:enrollease_web/widgets/custom_loading_dialog.dart';
import 'package:enrollease_web/widgets/custom_toast.dart';
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
  State<AccountSettingsDashboard> createState() => _AccountSettingsDashboardState();
}

class _AccountSettingsDashboardState extends State<AccountSettingsDashboard> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _passwordFormKey = GlobalKey<FormState>();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController middleNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController contactNumberController = TextEditingController(text: '+63');
  final TextEditingController emailController = TextEditingController();
  final TextEditingController identificationController = TextEditingController();
  final TextEditingController currentPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  final ImageService _imageService = ImageService();
  FirebaseAuthProvider authProvider = FirebaseAuthProvider();

  String? firstName;
  String? middleName;
  String? lastName;
  String? contactNumber;
  String? email;
  String? identificationNumber;
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
  bool toSaveFirstName = false;
  bool toSavePassword = false;

  @override
  void initState() {
    super.initState();
    setData(context);
    contactNumberController.addListener(_ensurePrefix);
  }

  Future<void> handleFieldUpdate(
    BuildContext context,
    Map<String, dynamic> updatedFields,
  ) async {
    try {
      if (mounted) {
        setState(() {
          changePassTapped = true;
        });
      }
      showLoadingDialog(context, 'Updating...');
      await authProvider.updateRegistrarField(
        documentId: identificationNumber!,
        updatedFields: updatedFields,
      );

      if (context.mounted) {
        Navigator.pop(context);
        // Update the local state dynamically
        Provider.of<AccountDataController>(context, listen: false).updateRegistrarLocal(updatedFields);
        setState(() {
          changePassTapped = false;
          toSaveFirstName = false;
        });
        DelightfulToast.showSuccess(context, 'Success', 'Update Success.');
      }
    } catch (e) {
      dPrint('error $e');
      if (context.mounted) {
        Navigator.pop(context);
        setState(() {
          changePassTapped = true;
        });
        DelightfulToast.showError(context, 'Error', 'Update failed.');
      }
    }
  }

  void setData(BuildContext context) {
    final providerData = Provider.of<AccountDataController>(context, listen: false).currentRegistrar;

    if (mounted) {
      setState(() {
        firstName = providerData!.firstName;
        middleName = providerData.middleName;
        lastName = providerData.lastName;
        contactNumber = providerData.contact;
        email = providerData.email;
        identificationNumber = providerData.id;

        firstNameController.text = firstName!;
        middleNameController.text = middleName!;
        lastNameController.text = lastName!;
        contactNumberController.text = contactNumber!;
        emailController.text = email!;
        identificationController.text = identificationNumber!;
      });
    }
  }

  void selectImage(BuildContext context) async {
    try {
      Uint8List? img = await _imageService.pickImage(context);
      if (img != null) {
        if (kDebugMode) print('Image picked successfully.');
        setState(() {
          _image = img;
          isImageChanged = true;
        });
      } else {
        if (kDebugMode) print('Image picking failed or was cancelled.');
        setState(() {
          isImageChanged = false;
        });
      }
    } catch (e) {
      if (kDebugMode) print('Error picking image: ${e.toString()}');
      setState(() {
        isImageChanged = false;
      });
    }
  }

  void _ensurePrefix() {
    const prefix = '+63';
    if (!contactNumberController.text.startsWith(prefix)) {
      contactNumberController.text = prefix;
      contactNumberController.selection = TextSelection.fromPosition(
        TextPosition(offset: contactNumberController.text.length),
      );
    }
  }

  @override
  void dispose() {
    contactNumberController.removeListener(_ensurePrefix);
    firstNameController.dispose();
    middleNameController.dispose();
    lastNameController.dispose();
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
    // Get the current index selected before going back
    int currentIndex = context.read<SideMenuIndexController>().currentIndexSelected;

    return Container(
      height: AppSizes.screenHeight,
      decoration: const BoxDecoration(
        color: CustomColors.appBarColor,
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const CustomDrawerHeader(
              headerName: 'profile',
              isToHide: true,
            ),
            const SizedBox(
              height: 100,
            ),
            Wrap(crossAxisAlignment: WrapCrossAlignment.center, spacing: 15.0, runSpacing: 10.0, children: [
              if (ResponsiveWidget.isSmallScreen(context) || ResponsiveWidget.isMediumScreen(context))
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
                        text: 'Save',
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
                    child: changePass == false ? accountInformation(context, currentIndex) : accountChangePassword(context, currentIndex),
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
                            text: 'Save',
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
            'First Name',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              Expanded(
                child: customTextFormField2(
                  firstNameController,
                  const TextStyle(color: Colors.black),
                  50,
                  null,
                  const InputDecoration(
                    labelStyle: TextStyle(color: Colors.black),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'First name is required.' : null,
                  enabled: firstNameController.text == 'Main Admin' ? false : true,
                  onChanged: (value) {
                    setState(() {
                      if (firstName != value) {
                        toSaveFirstName = true;
                      } else {
                        toSaveFirstName = false;
                      }
                    });
                  },
                ),
              ),
              if (toSaveFirstName)
                IconButton(
                    tooltip: 'Save First Name',
                    onPressed: () async {
                      await handleFieldUpdate(context, {
                        'firstName': firstNameController.text.trim(),
                      });
                    },
                    icon: const Icon(
                      Icons.check,
                      color: Colors.white,
                    )),
            ],
          ),
          const SizedBox(height: 5),
          const Text(
            'Middle Name',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
          ),
          const SizedBox(height: 5),
          customTextFormField2(
            middleNameController,
            const TextStyle(color: Colors.black),
            50,
            null,
            const InputDecoration(
              labelStyle: TextStyle(color: Colors.black),
              filled: true,
              fillColor: Colors.white,
            ),
            validator: (value) => value == null || value.isEmpty ? 'Middle name is required.' : null,
            enabled: middleNameController.text == 'Main Admin' ? false : true,
            onChanged: (value) {
              setState(() {
                if (middleName != value) {
                  toSave = true;
                } else {
                  toSave = false;
                }
              });
            },
          ),
          const SizedBox(height: 5),
          const Text(
            'Last Name',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
          ),
          const SizedBox(height: 5),
          customTextFormField2(
            lastNameController,
            const TextStyle(color: Colors.black),
            50,
            null,
            const InputDecoration(
              labelStyle: TextStyle(color: Colors.black),
              filled: true,
              fillColor: Colors.white,
            ),
            validator: (value) => value == null || value.isEmpty ? 'Last name is required.' : null,
            enabled: lastNameController.text == 'Main Admin' ? false : true,
            onChanged: (value) {
              setState(() {
                if (lastName != value) {
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
              13,
              [
                FilteringTextInputFormatter.allow(RegExp(r'^[+]?[0-9]*$')),
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
              keyboardType: const TextInputType.numberWithOptions()),
          const SizedBox(height: 5),
          const Text(
            'Email',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
          ),
          const SizedBox(height: 5),
          customTextFormField2(
            emailController,
            const TextStyle(color: Colors.black),
            50,
            null,
            const InputDecoration(labelStyle: TextStyle(color: Colors.black), filled: true, fillColor: Colors.white),
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
          const SizedBox(height: 5),
          const Text(
            'ID #',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
          ),
          const SizedBox(height: 5),
          customTextFormField2(identificationController, const TextStyle(color: Colors.black), 12, null, const InputDecoration(labelStyle: TextStyle(color: Colors.black), filled: true, fillColor: Colors.white), validator: (value) => TextValidator.validateEmail(value), enabled: false),
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
                text: 'Back',
                backgroundColor: Colors.white,
                textColor: Colors.black,
                onPressed: () {
                  // Handle back navigation to basePage based on currentIndex
                  context.read<SideMenuIndexController>().updatePageIndex(currentIndex);
                },
              ),
              if (toSave)
                CustomActionButton(
                  text: 'Save',
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
                dPrint('Value entered: ${value.trim()}');
                dPrint('Current password: ${currentPassword?.trim()}');
                if (value.trim() != currentPassword!.trim()) {
                  return 'Current password does not match!';
                }
              }
              return null;
            },
            onChanged: (value) {
              setState(() {
                if (value.isNotEmpty && newPasswordController.text.isNotEmpty && confirmPasswordController.text.isNotEmpty) {
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
              } else if (value.trim() != confirmPasswordController.text.trim()) {
                return 'Passwords do not match.';
              }
              return null;
            },
            onChanged: (value) {
              setState(() {
                if (value.isNotEmpty && currentPasswordController.text.isNotEmpty && confirmPasswordController.text.isNotEmpty) {
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
                if (value.isNotEmpty && currentPasswordController.text.isNotEmpty && newPasswordController.text.isNotEmpty) {
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
                text: 'Back',
                backgroundColor: Colors.white,
                textColor: Colors.black,
                onPressed: () {
                  // Handle back navigation to basePage based on currentIndex
                  context.read<SideMenuIndexController>().updatePageIndex(currentIndex);
                },
              ),
              if (toSavePassword)
                CustomActionButton(
                  text: 'Save',
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

                              dPrint('Failed to change password: $e');
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