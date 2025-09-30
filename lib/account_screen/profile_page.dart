import 'package:enrollease_web/dev.dart';
import 'package:enrollease_web/states_management/account_data_controller.dart';
import 'package:enrollease_web/states_management/side_menu_index_controller.dart';
import 'package:enrollease_web/utils/app_size.dart';

import 'package:enrollease_web/utils/theme_colors.dart';
import 'package:enrollease_web/states_management/theme_provider.dart';
import 'package:enrollease_web/utils/firebase_auth.dart';
import 'package:enrollease_web/widgets/custom_loading_dialog.dart';
import 'package:enrollease_web/widgets/custom_toast.dart';
import 'package:enrollease_web/widgets/profile_pic.dart';
import 'package:enrollease_web/utils/text_validator.dart';
import 'package:enrollease_web/widgets/custom_button.dart';
import 'package:enrollease_web/widgets/custom_textformfields.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

class ProfileDialog extends StatefulWidget {
  final String userId;
  const ProfileDialog({super.key, required this.userId});

  @override
  State<ProfileDialog> createState() => _ProfileDialogState();
}

class _ProfileDialogState extends State<ProfileDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _passwordFormKey = GlobalKey<FormState>();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController middleNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController contactNumberController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController identificationController =
      TextEditingController();
  final TextEditingController currentPasswordController =
      TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController profilePicLinkController =
      TextEditingController();
  // Add a counter to force refresh
  int _profilePicRefreshCounter = 0;

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
  // ignore: unused_field
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
    currentPassword =
        context.read<AccountDataController>().currentRegistrar?.password;
    contactNumberController.addListener(_ensurePrefix);
    currentIndex = context.read<SideMenuIndexController>().currentIndexSelected;
    loadProfilePicture();
  }

  Future<void> loadProfilePicture() async {
    if (!mounted) return;

    int retryCount = 0;
    const maxRetries = 3;
    Uint8List? bytes;

    while (retryCount < maxRetries) {
      if (mounted) {
        bytes = await authProvider.getProfilePic(context);
      }
      if (bytes != null) break;

      // If bytes is null, wait and retry
      retryCount++;
      dPrint(
          'loadProfilePicture: No image data on attempt $retryCount. Retrying...');
      await Future.delayed(Duration(milliseconds: 500 * retryCount));
    }

    if (mounted && bytes != null) {
      setState(() {
        _image = bytes;
      });
      dPrint('loadProfilePicture: Successfully loaded profile picture');
    } else if (mounted) {
      dPrint(
          'loadProfilePicture: Failed to load profile picture after $retryCount attempts');
    }
  }

  getImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      return file;
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

        Provider.of<AccountDataController>(context, listen: false)
            .updateRegistrarLocal(updatedFields);
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
    final providerData =
        Provider.of<AccountDataController>(context, listen: false)
            .currentRegistrar;

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
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        width: 500,
        constraints:
            const BoxConstraints(maxWidth: 600, minWidth: 320, maxHeight: 700),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.person,
                                color: Provider.of<ThemeProvider>(context,
                                            listen: false)
                                        .currentColors['content'] ??
                                    ThemeColors.content(context),
                                size: 28),
                            const SizedBox(width: 8),
                            Text(
                              'Profile',
                              style: TextStyle(
                                color: Provider.of<ThemeProvider>(context,
                                            listen: false)
                                        .currentColors['content'] ??
                                    ThemeColors.content(context),
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.black54),
                          onPressed: () => Navigator.of(context).pop(),
                          tooltip: 'Close',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Profile Picture with Edit Icon
                    Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          ProfilePic(
                            size: 120,
                            profileKey: ValueKey(_profilePicRefreshCounter),
                          ),
                          Positioned(
                            bottom: 8,
                            right: 8,
                            child: GestureDetector(
                              onTap: () async {
                                if (isLoading) return;
                                toggleLoading();
                                final file = await getImage();
                                final selectedImageBytes = file?.bytes;
                                final selectedFileName = file?.name;
                                if (selectedImageBytes != null &&
                                    selectedFileName != null) {
                                  try {
                                    final file = PlatformFile(
                                      name: selectedFileName,
                                      bytes: selectedImageBytes,
                                      size: selectedImageBytes.length,
                                      path: null,
                                    );
                                    final result = await authProvider
                                        .changeProfilePic(widget.userId, file);
                                    await loadProfilePicture();
                                    if (result != null) {
                                      if (!context.mounted) return;
                                      DelightfulToast.showError(
                                          context, 'Error', result);
                                    } else {
                                      if (context.mounted) {
                                        setState(() {
                                          _profilePicRefreshCounter++;
                                        });
                                      }
                                    }
                                  } catch (e) {
                                    dPrint('error $e');
                                  }
                                }
                                toggleLoading();
                              },
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Provider.of<ThemeProvider>(context,
                                              listen: false)
                                          .currentColors['content'] ??
                                      ThemeColors.content(context),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.1),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                child: isLoading
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white),
                                      )
                                    : const Icon(Icons.edit,
                                        color: Colors.white, size: 18),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Profile Info Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color:
                            (Provider.of<ThemeProvider>(context, listen: false)
                                        .currentColors['content'] ??
                                    ThemeColors.content(context))
                                .withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: (Provider.of<ThemeProvider>(context,
                                            listen: false)
                                        .currentColors['content'] ??
                                    ThemeColors.content(context))
                                .withValues(alpha: 0.08)),
                      ),
                      child: _buildProfileForm(context),
                    ),
                    const SizedBox(height: 24),
                    // Change Password Section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color:
                            (Provider.of<ThemeProvider>(context, listen: false)
                                        .currentColors['content'] ??
                                    ThemeColors.content(context))
                                .withValues(alpha: 0.03),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: (Provider.of<ThemeProvider>(context,
                                            listen: false)
                                        .currentColors['content'] ??
                                    ThemeColors.content(context))
                                .withValues(alpha: 0.08)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.lock,
                                  color: Provider.of<ThemeProvider>(context,
                                              listen: false)
                                          .currentColors['content'] ??
                                      ThemeColors.content(context),
                                  size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Change Password',
                                style: TextStyle(
                                  color: Provider.of<ThemeProvider>(context,
                                              listen: false)
                                          .currentColors['content'] ??
                                      ThemeColors.content(context),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          accountChangePassword(context, currentIndex),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          _buildTextField('First Name', firstNameController, toSaveFirstName,
              (value) {
            setState(() => toSaveFirstName = value != firstName);
          }),
          const SizedBox(height: 8),
          _buildTextField('Middle Name', middleNameController, toSaveMiddleName,
              (value) {
            setState(() => toSaveMiddleName = value != middleName);
          }),
          const SizedBox(height: 8),
          _buildTextField('Last Name', lastNameController, toSaveLastName,
              (value) {
            setState(() => toSaveLastName = value != lastName);
          }),
          const SizedBox(height: 8),
          _buildTextField(
              'Contact Number', contactNumberController, toSaveContact,
              (value) {
            setState(() => toSaveContact = value != contactNumber);
          }),
          const SizedBox(height: 8),
          _buildTextField('Email', emailController, toSaveEmail, (value) {
            setState(() => toSaveEmail = value != email);
          }),
          const SizedBox(height: 8),
          _buildTextField('ID #', identificationController, false, null,
              enabled: false),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[200],
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    // Call your update logic here
                    await handleFieldUpdate(context, {
                      'firstName': firstNameController.text.trim(),
                      'middleName': middleNameController.text.trim(),
                      'lastName': lastNameController.text.trim(),
                      'contact': contactNumberController.text.trim(),
                      'email': emailController.text.trim(),
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Provider.of<ThemeProvider>(context, listen: false)
                              .currentColors['content'] ??
                          ThemeColors.content(context),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Save'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      bool toSave, ValueChanged<String>? onChanged,
      {bool enabled = true}) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: enabled ? Colors.white : Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        suffixIcon:
            toSave ? const Icon(Icons.check, color: Colors.green) : null,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
      onChanged: onChanged,
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
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
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
                  validator: (value) => value == null || value.isEmpty
                      ? 'First name is required.'
                      : null,
                  enabled:
                      firstNameController.text == 'Main Admin' ? false : true,
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
                      if (!context.mounted) return;
                      setState(() {
                        toSaveFirstName = false;
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
                IconButton(
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
            ],
          ),
          const SizedBox(height: 5),
          const Text(
            'Last Name',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
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
                  validator: (value) => value == null || value.isEmpty
                      ? 'Last name is required.'
                      : null,
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
                IconButton(
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
                IconButton(
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
            ],
          ),
          const SizedBox(height: 5),
          const Text(
            'Email',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
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
                  const InputDecoration(
                      labelStyle: TextStyle(color: Colors.black),
                      filled: true,
                      fillColor: Colors.white),
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
                IconButton(
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
            ],
          ),
          const SizedBox(height: 5),
          const Text(
            'ID #',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
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
                  context
                      .read<SideMenuIndexController>()
                      .updatePageIndex(currentIndex);
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
          Text(
            'Current Password',
            style: TextStyle(
              color: Provider.of<ThemeProvider>(context, listen: false)
                      .currentColors['content'] ??
                  ThemeColors.content(context),
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
          Text(
            'New Password',
            style: TextStyle(
              color: Provider.of<ThemeProvider>(context, listen: false)
                      .currentColors['content'] ??
                  ThemeColors.content(context),
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
          Text(
            'Confirm Password',
            style: TextStyle(
              color: Provider.of<ThemeProvider>(context, listen: false)
                      .currentColors['content'] ??
                  ThemeColors.content(context),
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
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Spacer(),
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
                                await handleFieldUpdate(context, {
                                  'password': newPasswordController.text.trim()
                                });
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
}

class ProfilePage extends StatelessWidget {
  final String userId;
  const ProfilePage({super.key, required this.userId});
  @override
  Widget build(BuildContext context) {
    return ProfileDialog(userId: userId);
  }
}
