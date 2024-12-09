import 'package:enrollease_web/dev.dart';
import 'package:enrollease_web/states_management/account_data_controller.dart';
import 'package:enrollease_web/states_management/side_menu_index_controller.dart';
import 'package:enrollease_web/utils/app_size.dart';
import 'package:enrollease_web/utils/colors.dart';
import 'package:enrollease_web/utils/firebase_auth.dart';
import 'package:enrollease_web/utils/logos.dart';
import 'package:enrollease_web/utils/nav.dart';
import 'package:enrollease_web/widgets/custom_header.dart';
import 'package:enrollease_web/widgets/custom_loading_dialog.dart';
import 'package:enrollease_web/widgets/custom_toast.dart';
import 'package:enrollease_web/widgets/profile_pic.dart';
import 'package:enrollease_web/widgets/responsive_widget.dart';
import 'package:enrollease_web/utils/text_validator.dart';
import 'package:enrollease_web/widgets/custom_button.dart';
import 'package:enrollease_web/widgets/custom_textformfields.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
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

  // final ImageService _imageService = ImageService();
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
  bool isLoading = false;
  bool isImageChanged = false;
  Map<String, dynamic> data = {};
  late int currentIndex;

  bool toSave = false;
  bool toSaveFirstName = false;
  bool toSaveMiddleName = false;
  bool toSaveLastName = false;
  bool toSaveContact = false;
  bool toSaveEmail = false;
  bool toSavePassword = false;

  @override
  void initState() {
    super.initState();
    setData(context);
    currentPassword = context.read<AccountDataController>().currentRegistrar?.password;
    contactNumberController.addListener(_ensurePrefix);
    currentIndex = context.read<SideMenuIndexController>().currentIndexSelected;
  }

  Future<PlatformFile?> getImage() async {
    FilePickerResult? img = await FilePicker.platform.pickFiles(
      withData: true,
      type: FileType.custom,
      allowedExtensions: [
        'png',
        'jpg',
        'jpeg',
        'png',
        'gif',
      ],
    );
    if (img != null) {
      PlatformFile? file = img.files.firstOrNull;
      if (file != null) {
        return file;
      }
    }
    return null;
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
        Provider.of<AccountDataController>(context, listen: false).updateRegistrarLocal(updatedFields);
        setState(() {
          changePassTapped = false;
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

  @override
  Widget build(BuildContext context) {
    AppSizes().init(context);

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
            const SizedBox(height: 20),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 15.0,
              runSpacing: 10.0,
              children: [
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
                        onPressed: () => updateProfilePic(),
                        child: const Text(
                          'Change',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      // if (isImageChanged)
                      //   CustomActionButton(
                      //     text: 'Save',
                      //     backgroundColor: Colors.green,
                      //     textColor: Colors.white,
                      //     onPressed: () {
                      //       if (_formKey.currentState!.validate()) {}
                      //     },
                      //   ),
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
                        // crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const SizedBox(
                            height: 300,
                            width: 300,
                            child: ProfilePic(),
                          ),
                          const SizedBox(height: 15),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextButton(
                                onPressed: () => updateProfilePic(),
                                child: const Text(
                                  'Change ',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              Text(
                                '(Image should be Min. of 1mb)',
                                style: TextStyle(color: Colors.blue.shade900),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          // if (isImageChanged)
                          //   CustomActionButton(
                          //     text: 'Save',
                          //     backgroundColor: Colors.green,
                          //     textColor: Colors.white,
                          //     onPressed: () {
                          //       if (_formKey.currentState!.validate()) {}
                          //     },
                          //   ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
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
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: IconButton(
                      tooltip: 'Save First Name',
                      onPressed: () async {
                        await handleFieldUpdate(context, {
                          'firstName': firstNameController.text.trim(),
                        });
                        if (!context.mounted) return;
                        setState(() {
                          toSaveFirstName = false;
                        });
                      },
                      icon: const Icon(
                        Icons.check,
                        color: Colors.white,
                      )),
                ),
            ],
          ),
          const SizedBox(height: 5),
          const Text(
            'Middle Name',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              Expanded(
                child: customTextFormField2(
                  middleNameController,
                  const TextStyle(color: Colors.black),
                  50,
                  null,
                  const InputDecoration(
                    labelStyle: TextStyle(color: Colors.black),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  // validator: (value) => value == null || value.isEmpty ? 'Middle name is required.' : null,
                  // enabled: middleNameController.text == 'Main Admin' ? false : true,
                  onChanged: (value) {
                    setState(() {
                      if (middleName != value) {
                        toSaveMiddleName = true;
                      } else {
                        toSaveMiddleName = false;
                      }
                    });
                  },
                ),
              ),
              if (toSaveMiddleName)
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: IconButton(
                      tooltip: 'Save Middle Name',
                      onPressed: () async {
                        await handleFieldUpdate(context, {
                          'middleName': middleNameController.text.trim(),
                        });
                        if (!context.mounted) return;
                        setState(() {
                          toSaveMiddleName = false;
                        });
                      },
                      icon: const Icon(
                        Icons.check,
                        color: Colors.white,
                      )),
                ),
            ],
          ),
          const SizedBox(height: 5),
          const Text(
            'Last Name',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              Expanded(
                child: customTextFormField2(
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
                  // enabled: lastNameController.text == 'Main Admin' ? false : true,
                  onChanged: (value) {
                    setState(() {
                      if (lastName != value) {
                        toSaveLastName = true;
                      } else {
                        toSaveLastName = false;
                      }
                    });
                  },
                ),
              ),
              if (toSaveLastName)
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: IconButton(
                      tooltip: 'Save Middle Name',
                      onPressed: () async {
                        await handleFieldUpdate(context, {
                          'lastName': lastNameController.text.trim(),
                        });
                        if (!context.mounted) return;
                        setState(() {
                          toSaveLastName = false;
                        });
                      },
                      icon: const Icon(
                        Icons.check,
                        color: Colors.white,
                      )),
                ),
            ],
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
          Row(
            children: [
              Expanded(
                child: customTextFormField2(
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
                        toSaveContact = true;
                      } else {
                        toSaveContact = false;
                      }
                    });
                  },
                  keyboardType: const TextInputType.numberWithOptions(),
                ),
              ),
              if (toSaveContact)
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: IconButton(
                      onPressed: () async {
                        await handleFieldUpdate(context, {
                          'contact': contactNumberController.text.trim(),
                        });
                        if (!context.mounted) return;
                        setState(() {
                          toSaveContact = false;
                        });
                      },
                      icon: const Icon(
                        Icons.check,
                        color: Colors.white,
                      )),
                ),
            ],
          ),
          const SizedBox(height: 5),
          const Text(
            'Email',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              Expanded(
                child: customTextFormField2(
                  emailController,
                  const TextStyle(color: Colors.black),
                  50,
                  null,
                  const InputDecoration(labelStyle: TextStyle(color: Colors.black), filled: true, fillColor: Colors.white),
                  validator: (value) => TextValidator.validateEmail(value),
                  onChanged: (value) {
                    setState(() {
                      if (email != value) {
                        toSaveEmail = true;
                      } else {
                        toSaveEmail = false;
                      }
                    });
                  },
                ),
              ),
              if (toSaveEmail)
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: IconButton(
                      onPressed: () async {
                        await handleFieldUpdate(context, {
                          'email': emailController.text.trim(),
                        });
                        if (!context.mounted) return;
                        setState(() {
                          toSaveEmail = false;
                        });
                      },
                      icon: const Icon(
                        Icons.check,
                        color: Colors.white,
                      )),
                ),
            ],
          ),
          const SizedBox(height: 5),
          const Text(
            'ID #',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
          ),
          const SizedBox(height: 5),
          customTextFormField2(
            identificationController,
            const TextStyle(color: Colors.black),
            12,
            null,
            const InputDecoration(
              labelStyle: TextStyle(color: Colors.black),
              filled: true,
              fillColor: Colors.white,
            ),
            enabled: false,
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
          const SizedBox(height: 20),
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
                  return 'This is not your password.';
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
                                await handleFieldUpdate(context, {'password': newPasswordController.text.trim()});
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

  void toggleLoading() => setState(() {
        isLoading = !isLoading;
      });

  void updateProfilePic() async {
    if (isLoading) return;
    toggleLoading();
    final file = await getImage();
    if (file != null) {
      if (!mounted) return;
      showLoadingDialog(context, 'Updating profile pic...');
      final id = Provider.of<AccountDataController>(context, listen: false).currentRegistrar!.id;
      final result = await authProvider.changeProfilePic(id, file);
      if (!mounted) return;
      if (result != null) {
        DelightfulToast.showError(context, 'Error', result);
      } else {
        context.read<AccountDataController>().toggleProfilePicChanged();
      }
      Nav.pop(context);
    }
    toggleLoading();
  }
}
