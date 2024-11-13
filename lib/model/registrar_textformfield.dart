import 'package:flutter/material.dart';

class RegistrarFormData {
  final TextEditingController idNumberController;
  final TextEditingController lastNameController;
  final TextEditingController firstNameController;
  final TextEditingController middleNameController;
  final TextEditingController dateOfBirthController;
  final TextEditingController ageController;
  final TextEditingController contactTextController;
  final TextEditingController placeOfBirthController;
  final TextEditingController addressController;
  final TextEditingController emailAddressController;
  final TextEditingController remarksController;
  String selectedValue;
  String selectedJobLevel;

  RegistrarFormData({
    required this.idNumberController,
    required this.lastNameController,
    required this.firstNameController,
    required this.middleNameController,
    required this.dateOfBirthController,
    required this.ageController,
    required this.contactTextController,
    required this.placeOfBirthController,
    required this.addressController,
    required this.emailAddressController,
    required this.remarksController,
    this.selectedValue = 'Select',
    this.selectedJobLevel = 'Registrar Staff',
  });
}
