import 'package:enrollease_web/model/registrar_model.dart';
import 'package:enrollease_web/model/registrar_textformfield.dart';
import 'package:enrollease_web/paginated_table/table/registrars_table.dart';
import 'package:enrollease_web/utils/bottom_credits.dart';
import 'package:enrollease_web/utils/colors.dart';
import 'package:enrollease_web/utils/firebase_auth.dart';
import 'package:enrollease_web/utils/logos.dart';
import 'package:enrollease_web/widgets/custom_loading_dialog.dart';
import 'package:enrollease_web/widgets/custom_toast.dart';
import 'package:enrollease_web/widgets/responsive_widget.dart';
import 'package:enrollease_web/utils/text_validator.dart';
import 'package:enrollease_web/widgets/custom_add_dialog.dart';
import 'package:enrollease_web/widgets/custom_button.dart';
import 'package:enrollease_web/widgets/custom_header.dart';
import 'package:enrollease_web/widgets/custom_textformfields.dart';
import 'package:flutter/material.dart';

class Registrars extends StatefulWidget {
  const Registrars({super.key, this.userId});
  final String? userId;

  @override
  State<Registrars> createState() => _RegistrarsState();
}

class _RegistrarsState extends State<Registrars> {
  late RegistrarFormData formData;

  late RegistrarModel registrar;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  FirebaseAuthProvider firebaseAuthProvider = FirebaseAuthProvider();

  late String idNumber;

  bool isLoading = false;
  bool formLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeIdNumber();
  }

  Future<void> _initializeIdNumber() async {
    if (mounted) {
      setState(() {
        formLoading = true;
      });
    }
    idNumber = await firebaseAuthProvider.generateNewIdentification();
    formData = RegistrarFormData(
      idNumberController: TextEditingController(text: idNumber),
      lastNameController: TextEditingController(),
      firstNameController: TextEditingController(),
      middleNameController: TextEditingController(),
      dateOfBirthController: TextEditingController(),
      ageController: TextEditingController(),
      contactTextController: TextEditingController(text: '+63'),
      placeOfBirthController: TextEditingController(),
      addressController: TextEditingController(),
      emailAddressController: TextEditingController(),
      remarksController: TextEditingController(),
    );
    formData.contactTextController.addListener(_ensurePrefix);

    if (mounted) {
      setState(() {
        formLoading = false;
      });
    }
  }

  void _ensurePrefix() {
    const prefix = '+63';
    if (!formData.contactTextController.text.startsWith(prefix)) {
      formData.contactTextController.text = prefix;
      formData.contactTextController.selection = TextSelection.fromPosition(
        TextPosition(offset: formData.contactTextController.text.length),
      );
    }
  }

  @override
  void dispose() {
    formData.contactTextController.removeListener(_ensurePrefix);
    formData.contactTextController.dispose();
    formData.idNumberController.dispose();
    formData.lastNameController.dispose();
    formData.firstNameController.dispose();
    formData.middleNameController.dispose();
    formData.dateOfBirthController.dispose();
    formData.ageController.dispose();
    formData.placeOfBirthController.dispose();
    formData.addressController.dispose();
    formData.emailAddressController.dispose();
    formData.remarksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSmallOrMediumScreen = ResponsiveWidget.isMediumScreen(context) ||
        ResponsiveWidget.isLargeScreen(context);
    return Scaffold(
      backgroundColor: CustomColors.appBarColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomDrawerHeader(
                headerName: 'registrars',
                userId: widget.userId,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 10),
                  child: SizedBox(
                    width: 200,
                    child: CustomBtn(
                      vertical: 10,
                      colorBg: CustomColors.color1,
                      colorTxt: Colors.white,
                      txtSize: 18,
                      onTap: () async {
                        showLoadingDialog(context, 'Loading');
                        idNumber = await firebaseAuthProvider
                            .generateNewIdentification();

                        if (context.mounted) {
                          Navigator.pop(context);
                          buildForm(context, formKey);
                        }
                      },
                      btnTxt: 'Add Registrar',
                      btnIcon: Icons.add,
                      textStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 18),
                    ),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 10,
                ),
                child: RegistrarsTable(),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar:
          isSmallOrMediumScreen ? bottomCredits() : const SizedBox.shrink(),
    );
  }

  void buildForm(
    BuildContext context,
    GlobalKey<FormState> formKey,
  ) {
    return showDynamicDialog(
        context: context,
        title: '',
        formKey: formKey,
        contentWidgets: [
          const Divider(
            thickness: 1,
            color: Colors.black,
          ),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Please fill up the form correctly !',
              style: TextStyle(color: Colors.lightBlue),
            ),
          ),
          Container(
            decoration: BoxDecoration(
                border: Border.all(width: 1, color: Colors.black)),
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
          Align(
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                ElevatedButton(
                    onPressed: () {}, child: const Text('Choose File')),
                const SizedBox(
                  width: 5,
                ),
                const Text('File name .png')
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          const Align(
              alignment: Alignment.centerLeft,
              child: Text('Identification # (Auto-Generated)')),
          SizedBox(
              width: double.infinity,
              child: MyFormFieldWidget(
                hintText: formData.idNumberController.text,
              )), //formData.idNumberContoller
          //formData.idNumberController
          const SizedBox(
            height: 10,
          ),
          Wrap(
            spacing: 29.0, // Space between each item horizontally
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
                      controller: formData.lastNameController,
                      toShowPrefixIcon: false,
                      validator: (value) =>
                          TextValidator.simpleValidator(value),
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
                      controller: formData.firstNameController,
                      toShowPrefixIcon: false,
                      validator: (value) =>
                          TextValidator.simpleValidator(value),
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
                      controller: formData.middleNameController,
                      toShowPrefixIcon: false,
                      validator: (value) =>
                          TextValidator.simpleValidator(value),
                    ),
                  ),
                ],
              ),
            ],
          ),

          Wrap(
            spacing: 29.0, // Space between each item horizontally
            runSpacing: 16.0, // Space between each line vertically
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Name Extension *'),
                  SizedBox(
                    width: 300,
                    child: Container(
                        decoration: BoxDecoration(
                          border:
                              Border.all(color: Colors.grey), // Border color
                          borderRadius:
                              BorderRadius.circular(5.0), // Border radius
                        ),
                        child: StatefulBuilder(
                          builder:
                              (BuildContext context, StateSetter setState) {
                            return DropdownButton<String>(
                              padding: const EdgeInsets.only(left: 10),
                              value: formData.selectedValue,

                              items: const [
                                DropdownMenuItem(
                                    value: 'Select', child: Text('Select')),
                                DropdownMenuItem(value: 'I', child: Text('I')),
                                DropdownMenuItem(
                                    value: 'II', child: Text('II')),
                                DropdownMenuItem(
                                    value: 'III', child: Text('III')),
                                DropdownMenuItem(
                                    value: 'JR', child: Text('JR')),
                                DropdownMenuItem(
                                    value: 'SR', child: Text('SR')),
                              ],
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    formData.selectedValue = newValue;
                                  });
                                }
                              },
                              underline: const SizedBox
                                  .shrink(), // Removes the underline
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
                      controller: formData.dateOfBirthController,
                      ageController: formData.ageController,
                      hintText: 'mm/dd/yyyy',
                      isDateTime: true,
                      iconDataSuffix: Icons.calendar_month,
                      toShowIcon: true,
                      toShowPrefixIcon: false,
                      validator: (value) =>
                          TextValidator.simpleValidator(value),
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
                      controller: formData.ageController,
                      toShowPassword: false,
                      isDateTime: true,
                      leftPadding: 20,
                      toShowIcon: false,
                      toShowPrefixIcon: false,
                      validator: (value) =>
                          TextValidator.simpleValidator(value),
                    ),
                  )
                ],
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          const Align(
              alignment: Alignment.centerLeft, child: Text('Contact Number *')),
          SizedBox(
            width: double.infinity,
            child: CustomTextFormField(
              toShowIcon: false,
              toShowPassword: false,
              controller: formData.contactTextController,
              maxLength: 13,
              toShowPrefixIcon: false,
              validator: (value) => TextValidator.validateContact(value),
            ),
          ),
          const Align(
              alignment: Alignment.centerLeft, child: Text('Place of Birth *')),
          SizedBox(
            width: double.infinity,
            child: CustomTextFormField(
              maxLength: 50,
              toShowIcon: false,
              toShowPassword: false,
              controller: formData.placeOfBirthController,
              toShowPrefixIcon: false,
              validator: (value) => TextValidator.simpleValidator(value),
            ),
          ),
          const Align(
              alignment: Alignment.centerLeft, child: Text('Address *')),
          SizedBox(
            width: double.infinity,
            child: CustomTextFormField(
              maxLength: 50,
              toShowIcon: false,
              toShowPassword: false,
              controller: formData.addressController,
              toShowPrefixIcon: false,
              validator: (value) => TextValidator.simpleValidator(value),
            ),
          ),
          const Align(
              alignment: Alignment.centerLeft, child: Text('Email Address *')),
          SizedBox(
            width: double.infinity,
            child: CustomTextFormField(
              maxLength: 50,
              toShowIcon: false,
              toShowPassword: false,
              controller: formData.emailAddressController,
              toShowPrefixIcon: false,
              validator: (value) => TextValidator.validateEmail(value),
            ),
          ),

          const Align(
              alignment: Alignment.centerLeft, child: Text('Job Level *')),
          SizedBox(
            width: double.infinity,
            child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey), // Border color
                  borderRadius: BorderRadius.circular(5.0), // Border radius
                ),
                child: StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                    return DropdownButtonFormField<String>(
                      value: formData.selectedJobLevel,
                      items: const [
                        DropdownMenuItem(
                            value: 'Registrar Staff',
                            child: Text('Registrar Staff')),
                        DropdownMenuItem(
                            value: 'Registrar Head',
                            child: Text('Registrar Head')),
                      ],
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            formData.selectedJobLevel = newValue;
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
          const SizedBox(
            height: 10,
          ),
          const Align(
              alignment: Alignment.centerLeft, child: Text('Remarks *')),
          SizedBox(
            width: double.infinity,
            child: CustomTextFormField(
              maxLine: null,
              maxLength: 300,
              toShowIcon: false,
              toShowPassword: false,
              controller: formData.remarksController,
              toShowPrefixIcon: false,
              validator: (value) => TextValidator.simpleValidator(value),
            ),
          ),
        ],
        actionButtons: [
          ElevatedButton(
              onPressed: () async => isLoading ? null : handleSaveMethod(),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text(
                'Create Record',
                style: TextStyle(color: Colors.black),
              )),
          const SizedBox(
            width: 5,
          ),
          ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text(
                'Close',
                style: TextStyle(color: Colors.black),
              ))
        ]);
  }

//SDA24-000000
  Future<void> handleSaveMethod() async {
    registrar = RegistrarModel(
        identification: formData.idNumberController.text.trim(),
        lastName: formData.lastNameController.text.trim(),
        firstName: formData.firstNameController.text.trim(),
        middleName: formData.middleNameController.text.trim() == 'N/A' ||
                formData.middleNameController.text.trim().isEmpty
            ? '' // Use an empty string if it's 'N/A' or empty
            : formData.middleNameController.text.trim(),
        dateOfBirth: formData.dateOfBirthController.text.trim(),
        age: formData.ageController.text.trim(),
        contact: formData.contactTextController.text.trim(),
        placeOfBirth: formData.placeOfBirthController.text.trim(),
        address: formData.addressController.text.trim(),
        email: formData.emailAddressController.text.trim().toLowerCase(),
        remarks: formData.remarksController.text.trim(),
        nameExtension: formData.selectedValue.trim() == 'Select'
            ? null
            : formData.selectedValue.trim(),
        password: formData.idNumberController.text.trim(),
        jobLevel: formData.selectedJobLevel.trim());

    if (formKey.currentState!.validate()) {
      debugPrint("Form is valid");

      try {
        if (mounted) {
          setState(() {
            isLoading = true;
          });
        }
        showLoadingDialog(context, 'Creating Record...');
        await firebaseAuthProvider.saveUserData(registrar);

        debugPrint('Fetched data: ${registrar.toMap()}');

        if (mounted) {
          Navigator.pop(context);
          Navigator.pop(context);
          DelightfulToast.showSuccess(
              context, 'Sucess', 'Create record success.');

          setState(() {
            isLoading = false;

            formData.idNumberController.clear();
            formData.lastNameController.clear();
            formData.firstNameController.clear();
            formData.middleNameController.clear();
            formData.dateOfBirthController.clear();
            formData.ageController.clear();
            formData.contactTextController.clear();
            formData.placeOfBirthController.clear();
            formData.addressController.clear();
            formData.emailAddressController.clear();
            formData.remarksController.clear();
            formData.selectedValue = 'Select';
            formData.idNumberController.clear();
          });
        }
      } catch (e) {
        debugPrint("Form errors: ${e.toString()}");

        if (mounted) {
          Navigator.pop(context);
          DelightfulToast.showError(
              context, 'Error', 'Form errors: ${e.toString()}');
          setState(() {
            isLoading = false;
          });
        }
      }
    } else {
      debugPrint("Form is invalid, show errors.");
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }
}
