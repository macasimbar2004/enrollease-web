import 'package:enrollease_web/dev.dart';
import 'package:enrollease_web/model/registrar_model.dart';
import 'package:enrollease_web/utils/firebase_auth.dart';
import 'package:enrollease_web/utils/logos.dart';
import 'package:enrollease_web/utils/text_validator.dart';
import 'package:enrollease_web/widgets/custom_loading_dialog.dart';
import 'package:enrollease_web/widgets/custom_textformfields.dart';
import 'package:enrollease_web/widgets/custom_toast.dart';
import 'package:flutter/material.dart';

class RegistrarDialog extends StatefulWidget {
  final String id;
  final bool editMode;
  final RegistrarModel? registrar;
  const RegistrarDialog({super.key, required this.editMode, required this.id, this.registrar});

  @override
  State<RegistrarDialog> createState() => _RegistrarDialogState();
}

class _RegistrarDialogState extends State<RegistrarDialog> {
  FirebaseAuthProvider firebaseAuthProvider = FirebaseAuthProvider();
  final formKey = GlobalKey<FormState>();
  final scrollController = ScrollController();
  late final TextEditingController contactTextController;
  late final TextEditingController idNumberController;
  late final TextEditingController lastNameController;
  late final TextEditingController firstNameController;
  late final TextEditingController middleNameController;
  late final TextEditingController dateOfBirthController;
  late final TextEditingController ageController;
  late final TextEditingController placeOfBirthController;
  late final TextEditingController addressController;
  late final TextEditingController emailController;
  late final TextEditingController remarksController;
  String selectedNameExtension = 'Select';
  String selectedJobLevel = 'Registrar Staff';
  bool formLoading = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.editMode && widget.registrar == null) {
      throw ('Must provide a registrar if in edit mode!!');
    }
    idNumberController = TextEditingController(text: widget.registrar?.id ?? widget.id);
    contactTextController = TextEditingController(text: widget.registrar?.contact ?? '+63');
    lastNameController = TextEditingController(text: widget.registrar?.lastName);
    firstNameController = TextEditingController(text: widget.registrar?.firstName);
    middleNameController = TextEditingController(text: widget.registrar?.middleName);
    dateOfBirthController = TextEditingController(text: widget.registrar?.dateOfBirth);
    ageController = TextEditingController(text: widget.registrar?.age);
    placeOfBirthController = TextEditingController(text: widget.registrar?.placeOfBirth);
    addressController = TextEditingController(text: widget.registrar?.address);
    emailController = TextEditingController(text: widget.registrar?.email);
    remarksController = TextEditingController(text: widget.registrar?.remarks);
    contactTextController.addListener(_ensurePrefix);
  }

  void _ensurePrefix() {
    const prefix = '+63';
    if (!contactTextController.text.startsWith(prefix)) {
      contactTextController.text = prefix;
      contactTextController.selection = TextSelection.fromPosition(
        TextPosition(offset: contactTextController.text.length),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: SizedBox(
        width: 1200,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Scrollbar(
            controller: scrollController,
            child: SingleChildScrollView(
              controller: scrollController,
              child: Form(
                key: formKey,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    children: [
                      Text(
                        widget.editMode ? 'Edit registrar' : 'Create new registrar',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(
                        thickness: 1,
                        color: Colors.black,
                      ),
                      // const Align(
                      //   alignment: Alignment.centerLeft,
                      //   child: Text(
                      //     'Please fill up the form correctly !',
                      //     style: TextStyle(color: Colors.lightBlue),
                      //   ),
                      // ),
                      Container(
                        decoration: BoxDecoration(border: Border.all(width: 1, color: Colors.black)),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ClipRRect(
                            child: Image.asset(
                              CustomLogos.editProfileImage,
                              height: 150,
                              width: 150,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(onPressed: () {}, child: const Text('Choose File')),
                          const SizedBox(
                            width: 5,
                          ),
                          const Text('File name.png')
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Align(alignment: Alignment.centerLeft, child: Text('ID # (Auto-Generated)')),
                      SizedBox(
                          width: double.infinity,
                          child: MyFormFieldWidget(
                            hintText: idNumberController.text,
                          )), //formData.idNumberContoller
                      //formData.idNumberController
                      const SizedBox(
                        height: 10,
                      ),
                      Wrap(
                        spacing: 29.0, // Space between each item horizontally
                        runSpacing: 16.0, // Space between each line vertically
                        alignment: WrapAlignment.center,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Lastname *'),
                              SizedBox(
                                width: 300,
                                child: CustomTextFormField(
                                  maxLength: 50,
                                  toShowIcon: false,
                                  toShowPassword: false,
                                  controller: lastNameController,
                                  toShowPrefixIcon: false,
                                  validator: (value) => TextValidator.simpleValidator(value),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Firstname *'),
                              SizedBox(
                                width: 300,
                                child: CustomTextFormField(
                                  maxLength: 50,
                                  toShowIcon: false,
                                  toShowPassword: false,
                                  controller: firstNameController,
                                  toShowPrefixIcon: false,
                                  validator: (value) => TextValidator.simpleValidator(value),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Middlename *'),
                              SizedBox(
                                width: 300,
                                child: CustomTextFormField(
                                  maxLength: 50,
                                  toShowIcon: false,
                                  hintText: 'N/A if not applicable',
                                  toShowPassword: false,
                                  controller: middleNameController,
                                  toShowPrefixIcon: false,
                                  validator: (value) => TextValidator.simpleValidator(value),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Name Extension *'),
                              SizedBox(
                                width: 300,
                                child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey), // Border color
                                      borderRadius: BorderRadius.circular(5.0), // Border radius
                                    ),
                                    child: StatefulBuilder(
                                      builder: (BuildContext context, StateSetter setState) {
                                        return DropdownButton<String>(
                                          padding: const EdgeInsets.only(left: 10),
                                          value: selectedNameExtension,
                                          items: const [
                                            DropdownMenuItem(value: 'Select', child: Text('Select')),
                                            DropdownMenuItem(value: 'I', child: Text('I')),
                                            DropdownMenuItem(value: 'II', child: Text('II')),
                                            DropdownMenuItem(value: 'III', child: Text('III')),
                                            DropdownMenuItem(value: 'JR', child: Text('JR')),
                                            DropdownMenuItem(value: 'SR', child: Text('SR')),
                                          ],
                                          onChanged: (String? newValue) {
                                            if (newValue != null) {
                                              setState(() {
                                                selectedNameExtension = newValue;
                                              });
                                            }
                                          },
                                          underline: const SizedBox.shrink(), // Removes the underline
                                        );
                                      },
                                    )),
                              )
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Birthdate *'),
                              SizedBox(
                                width: 300,
                                child: CustomTextFormField(
                                  toShowPassword: false,
                                  controller: dateOfBirthController,
                                  ageController: ageController,
                                  hintText: 'mm/dd/yyyy',
                                  isDateTime: true,
                                  iconDataSuffix: Icons.calendar_month,
                                  toShowIcon: true,
                                  toShowPrefixIcon: false,
                                  validator: (value) => TextValidator.simpleValidator(value),
                                ),
                              )
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Age *'),
                              SizedBox(
                                width: 300,
                                child: CustomTextFormField(
                                  controller: ageController,
                                  hintText: '(Auto-detect based on birthdate)',
                                  toShowPassword: false,
                                  isDateTime: true,
                                  leftPadding: 20,
                                  toShowIcon: false,
                                  toShowPrefixIcon: false,
                                  validator: (value) => TextValidator.simpleValidator(value),
                                ),
                              )
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Contact Number *'),
                              SizedBox(
                                width: 300,
                                child: CustomTextFormField(
                                  toShowIcon: false,
                                  toShowPassword: false,
                                  // isPhoneNumber: true,
                                  controller: contactTextController,
                                  maxLength: 13,
                                  toShowPrefixIcon: false,
                                  validator: (value) => TextValidator.validateContact(value),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Place of Birth *'),
                              SizedBox(
                                width: 300,
                                child: CustomTextFormField(
                                  maxLength: 50,
                                  toShowIcon: false,
                                  toShowPassword: false,
                                  controller: placeOfBirthController,
                                  toShowPrefixIcon: false,
                                  validator: (value) => TextValidator.simpleValidator(value),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Address *'),
                              SizedBox(
                                width: 300,
                                child: CustomTextFormField(
                                  maxLength: 50,
                                  toShowIcon: false,
                                  toShowPassword: false,
                                  controller: addressController,
                                  toShowPrefixIcon: false,
                                  validator: (value) => TextValidator.simpleValidator(value),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Email Address *'),
                              SizedBox(
                                width: 300,
                                child: CustomTextFormField(
                                  maxLength: 50,
                                  toShowIcon: false,
                                  toShowPassword: false,
                                  controller: emailController,
                                  toShowPrefixIcon: false,
                                  validator: (value) => TextValidator.validateEmail(value),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Job Level *'),
                              SizedBox(
                                width: 300,
                                child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey), // Border color
                                      borderRadius: BorderRadius.circular(5.0), // Border radius
                                    ),
                                    child: StatefulBuilder(
                                      builder: (BuildContext context, StateSetter setState) {
                                        return DropdownButtonFormField<String>(
                                          value: selectedJobLevel,
                                          items: const [
                                            DropdownMenuItem(value: 'Registrar Staff', child: Text('Registrar Staff')),
                                            DropdownMenuItem(value: 'Registrar Head', child: Text('Registrar Head')),
                                          ],
                                          onChanged: (String? newValue) {
                                            if (newValue != null) {
                                              setState(() {
                                                selectedJobLevel = newValue;
                                              });
                                            }
                                          },
                                          validator: (value) {
                                            // Custom validation: checks if the value is selected (not 'Select')
                                            if (value == 'Select' || value == null) {
                                              return 'Please select a job level';
                                            }
                                            return null; // Return null if validation passes
                                          },
                                        );
                                      },
                                    )),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Remarks *'),
                              SizedBox(
                                width: 1000,
                                child: CustomTextFormField(
                                  maxLine: null,
                                  maxLength: 300,
                                  toShowIcon: false,
                                  toShowPassword: false,
                                  controller: remarksController,
                                  toShowPrefixIcon: false,
                                  validator: (value) => TextValidator.simpleValidator(value),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                              onPressed: () async => isLoading ? null : handleSaveMethod(),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                              child: Text(
                                widget.editMode ? 'Save changes' : 'Create',
                                style: const TextStyle(color: Colors.white),
                              )),
                          const SizedBox(
                            width: 5,
                          ),
                          ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(color: Colors.white),
                              )),
                          const SizedBox(
                            width: 10,
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  //SDA24-000000
  Future<void> handleSaveMethod() async {
    if (formKey.currentState!.validate()) {
      try {
        if (mounted) {
          setState(() {
            isLoading = true;
          });
        }
        showLoadingDialog(context, 'Creating Record...');
        final registrar = RegistrarModel(
          id: idNumberController.text.trim(),
          lastName: lastNameController.text.trim(),
          firstName: firstNameController.text.trim(),
          middleName: middleNameController.text.trim(),
          dateOfBirth: dateOfBirthController.text.trim(),
          age: ageController.text.trim(),
          contact: contactTextController.text.trim(),
          placeOfBirth: placeOfBirthController.text.trim(),
          address: addressController.text.trim(),
          email: emailController.text.trim(),
          remarks: remarksController.text.trim(),
          password: idNumberController.text.trim(),
        );
        await firebaseAuthProvider.saveUserData(registrar);
        // dPrint('Fetched data: ${registrar.toMap()}');
        if (mounted) {
          Navigator.pop(context);
          Navigator.pop(context);
          DelightfulToast.showSuccess(context, 'Sucess', '${widget.editMode ? 'Edit' : 'Create'} record success.');
          setState(() {
            isLoading = false;
            idNumberController.clear();
            lastNameController.clear();
            firstNameController.clear();
            middleNameController.clear();
            dateOfBirthController.clear();
            ageController.clear();
            contactTextController.clear();
            placeOfBirthController.clear();
            addressController.clear();
            emailController.clear();
            remarksController.clear();
            selectedNameExtension = 'Select';
            idNumberController.clear();
          });
        }
      } catch (e) {
        dPrint('Form errors: ${e.toString()}');
        if (mounted) {
          Navigator.pop(context);
          DelightfulToast.showError(context, 'Error', 'Form errors: ${e.toString()}');
          setState(() {
            isLoading = false;
          });
        }
      }
    } else {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }
}
