import 'dart:convert';
import 'package:enrollease_web/dev.dart';
import 'package:enrollease_web/model/faculty_staff_model.dart';
import 'package:enrollease_web/model/registrar_model.dart';
import 'package:enrollease_web/utils/firebase_auth.dart';
import 'package:enrollease_web/utils/grade_level_utils.dart';
import 'package:enrollease_web/widgets/dynamic_logo.dart';
import 'package:enrollease_web/utils/text_validator.dart';
import 'package:enrollease_web/widgets/custom_loading_dialog.dart';
import 'package:enrollease_web/widgets/custom_textformfields.dart';
import 'package:enrollease_web/widgets/custom_toast.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class RegistrarDialog extends StatefulWidget {
  final String id;
  final bool editMode;
  final RegistrarModel? registrar;
  const RegistrarDialog(
      {super.key, required this.editMode, required this.id, this.registrar});

  @override
  State<RegistrarDialog> createState() => _RegistrarDialogState();
}

class _RegistrarDialogState extends State<RegistrarDialog> {
  FirebaseAuthProvider firebaseAuthProvider = FirebaseAuthProvider();
  final formKey = GlobalKey<FormState>();
  final scrollController = ScrollController();
  late final TextEditingController profilePicLinkController;
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
  late final TextEditingController departmentController;
  late final TextEditingController subjectsController;
  late final TextEditingController advisoryClassController;

  String selectedNameExtension = 'Select';
  String selectedUserType = 'Staff'; // Default to Staff
  String selectedStatus = 'active'; // Default to active
  List<String> selectedRoles = ['Registrar Officer']; // Default role
  String? selectedGradeLevel; // For teachers
  String? selectedDepartment; // For future use

  bool formLoading = false;
  bool isLoading = false;
  Uint8List? selectedImageBytes;
  String? selectedFileName;

  // Future-proof options
  final List<String> availableRoles = [
    'Teacher',
    'Registrar Officer',
    'User Manager',
    'Communications Officer',
    'Attendance Officer',
    'Finance Officer',
  ];

  final List<String> gradeLevels = [
    'Kinder I',
    'Kinder II',
    'Grade 1',
    'Grade 2',
    'Grade 3',
    'Grade 4',
    'Grade 5',
    'Grade 6',
    'Grade 7',
  ];

  final List<String> departments = [
    'Elementary Department',
    'Junior High School Department',
    'Senior High School Department', // For future expansion
    'Administrative Department',
    'Support Services Department',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.editMode && widget.registrar == null) {
      throw ('Must provide a registrar if in edit mode!!');
    }

    // Initialize controllers with existing data
    profilePicLinkController =
        TextEditingController(text: widget.registrar?.profilePicLink);
    idNumberController =
        TextEditingController(text: widget.registrar?.id ?? widget.id);
    contactTextController =
        TextEditingController(text: widget.registrar?.contact ?? '+63');
    lastNameController =
        TextEditingController(text: widget.registrar?.lastName);
    firstNameController =
        TextEditingController(text: widget.registrar?.firstName);
    middleNameController =
        TextEditingController(text: widget.registrar?.middleName);
    dateOfBirthController =
        TextEditingController(text: widget.registrar?.dateOfBirth);
    ageController = TextEditingController(text: widget.registrar?.age);
    placeOfBirthController =
        TextEditingController(text: widget.registrar?.placeOfBirth);
    addressController = TextEditingController(text: widget.registrar?.address);
    emailController = TextEditingController(text: widget.registrar?.email);
    remarksController = TextEditingController(text: widget.registrar?.remarks);
    departmentController = TextEditingController();
    subjectsController = TextEditingController();
    advisoryClassController = TextEditingController();

    // Initialize RBAC fields with existing data
    if (widget.editMode && widget.registrar != null) {
      // Load user type from existing data
      selectedUserType = widget.registrar!.userType ?? 'Staff';

      // Load roles from existing data
      if (widget.registrar!.roles != null &&
          widget.registrar!.roles!.isNotEmpty) {
        selectedRoles = List<String>.from(widget.registrar!.roles!);
      } else {
        selectedRoles =
            selectedUserType == 'Teacher' ? ['Teacher'] : ['Registrar Officer'];
      }

      // Load status from existing data
      selectedStatus = widget.registrar!.status ?? 'active';

      // Load grade level for teachers
      if (selectedUserType == 'Teacher') {
        // Convert from standardized format to display format
        final dbGradeLevel = widget.registrar!.gradeLevel;
        if (dbGradeLevel != null) {
          selectedGradeLevel = GradeLevelUtils.getDisplayName(dbGradeLevel);
        }
      }
    }

    // Initialize contact as empty for new records
    if (widget.registrar?.contact == null) {
      contactTextController.text = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Container(
        width: 1400,
        constraints: const BoxConstraints(maxHeight: 800),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.grey.shade50,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            // Modern Header
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.blue.shade600,
                    Colors.blue.shade800,
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  topRight: Radius.circular(20.0),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      widget.editMode ? Icons.edit : Icons.person_add,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.editMode
                              ? 'Faculty & Staff Details'
                              : 'Create New Faculty/Staff Member',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.editMode
                              ? 'View and edit faculty/staff information'
                              : 'Add a new member to the faculty or staff',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content Area
            Expanded(
              child: Scrollbar(
                controller: scrollController,
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Profile Picture Section - Only show in create mode
                        if (!widget.editMode) ...[
                          Center(
                            child: Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            Colors.black.withValues(alpha: 0.1),
                                        blurRadius: 10,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Container(
                                      width: 180,
                                      height: 180,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: selectedImageBytes != null
                                          ? Image.memory(
                                              selectedImageBytes!,
                                              width: 180,
                                              height: 180,
                                              fit: BoxFit.cover,
                                            )
                                          : profilePicLinkController
                                                      .text.isNotEmpty &&
                                                  !profilePicLinkController.text
                                                      .startsWith(
                                                          'Selected:') &&
                                                  !profilePicLinkController.text
                                                      .startsWith('error:')
                                              ? Image.network(
                                                  profilePicLinkController.text,
                                                  width: 180,
                                                  height: 180,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error,
                                                      stackTrace) {
                                                    return const DynamicLogo(
                                                      logoType:
                                                          'defaultProfilePic',
                                                      width: 180,
                                                      height: 180,
                                                      fit: BoxFit.cover,
                                                    );
                                                  },
                                                )
                                              : const DynamicLogo(
                                                  logoType: 'defaultProfilePic',
                                                  width: 180,
                                                  height: 180,
                                                  fit: BoxFit.cover,
                                                ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: () async {
                                        final result =
                                            await FilePicker.platform.pickFiles(
                                          type: FileType.image,
                                          withData: true,
                                        );
                                        if (result != null &&
                                            result.files.isNotEmpty) {
                                          final file = result.files.first;
                                          setState(() {
                                            selectedFileName = file.name;
                                            selectedImageBytes = file.bytes;
                                            profilePicLinkController.text =
                                                'Selected: ${file.name}';
                                          });
                                        } else {
                                          debugPrint('No file selected');
                                        }
                                      },
                                      icon: const Icon(Icons.photo_camera),
                                      label: const Text('Choose Photo'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue.shade600,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Flexible(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade100,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(
                                            color: Colors.grey.shade300,
                                          ),
                                        ),
                                        child: Text(
                                          selectedFileName != null
                                              ? 'Selected: $selectedFileName'
                                              : profilePicLinkController
                                                      .text.isEmpty
                                                  ? 'No photo selected'
                                                  : 'Current photo loaded',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade700,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],

                        // ID Section
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.badge, color: Colors.blue.shade600),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'ID Number',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.blue.shade700,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      idNumberController.text.isEmpty
                                          ? 'Auto-generated'
                                          : idNumberController.text,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue.shade800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Form Fields Section
                        Text(
                          'Personal Information',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        const SizedBox(height: 16),

                        Wrap(
                          spacing: 24.0,
                          runSpacing: 20.0,
                          alignment: WrapAlignment.start,
                          children: [
                            _buildModernFormField(
                              label: 'Last Name *',
                              controller: lastNameController,
                              icon: Icons.person,
                              validator: (value) =>
                                  TextValidator.simpleValidator(value),
                            ),
                            _buildModernFormField(
                              label: 'First Name *',
                              controller: firstNameController,
                              icon: Icons.person_outline,
                              validator: (value) =>
                                  TextValidator.simpleValidator(value),
                            ),
                            _buildModernFormField(
                              label: 'Middle Name',
                              controller: middleNameController,
                              icon: Icons.person_pin,
                              validator: (value) =>
                                  TextValidator.simpleValidator(value),
                            ),
                            _buildModernDropdownField(
                              label: 'Name Extension',
                              value: selectedNameExtension,
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
                                    selectedNameExtension = newValue;
                                  });
                                }
                              },
                              icon: Icons.badge_outlined,
                            ),
                            _buildModernFormField(
                              label: 'Birthdate *',
                              controller: dateOfBirthController,
                              icon: Icons.calendar_today,
                              isDate: true,
                              ageController: ageController,
                              validator: (value) =>
                                  TextValidator.simpleValidator(value),
                            ),
                            _buildModernFormField(
                              label: 'Age *',
                              controller: ageController,
                              icon: Icons.cake,
                              isReadOnly:
                                  true, // Make age read-only since it's auto-calculated
                              validator: (value) =>
                                  TextValidator.simpleValidator(value),
                            ),
                            _buildModernFormField(
                              label: 'Contact Number *',
                              isPhoneNumber: true,
                              controller: contactTextController,
                              icon: Icons.phone,
                              validator: (value) =>
                                  TextValidator.validateContact(value),
                            ),
                            _buildModernFormField(
                              label: 'Place of Birth *',
                              controller: placeOfBirthController,
                              icon: Icons.location_city,
                              validator: (value) =>
                                  TextValidator.simpleValidator(value),
                            ),
                            _buildModernFormField(
                              label: 'Address *',
                              controller: addressController,
                              icon: Icons.home,
                              validator: (value) =>
                                  TextValidator.simpleValidator(value),
                            ),
                            _buildModernFormField(
                              label: 'Email Address *',
                              controller: emailController,
                              icon: Icons.email,
                              validator: (value) =>
                                  TextValidator.validateEmail(value),
                            ),

                            // User Type Selection
                            _buildModernDropdownField(
                              label: 'User Type *',
                              value: selectedUserType,
                              items: const [
                                DropdownMenuItem(
                                    value: 'Teacher', child: Text('Teacher')),
                                DropdownMenuItem(
                                    value: 'Staff', child: Text('Staff')),
                              ],
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    selectedUserType = newValue;
                                    // Reset roles based on user type
                                    if (newValue == 'Teacher') {
                                      selectedRoles = ['Teacher'];
                                      selectedGradeLevel = null;
                                    } else {
                                      selectedRoles = ['Registrar Officer'];
                                      selectedGradeLevel = null;
                                    }
                                  });
                                }
                              },
                              icon: Icons.work,
                            ),

                            // Status Selection
                            _buildModernDropdownField(
                              label: 'Status *',
                              value: selectedStatus,
                              items: const [
                                DropdownMenuItem(
                                    value: 'active', child: Text('Active')),
                                DropdownMenuItem(
                                    value: 'disabled', child: Text('Disabled')),
                              ],
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    selectedStatus = newValue;
                                  });
                                }
                              },
                              icon: Icons.verified_user,
                            ),

                            // Teacher-specific fields (only show if Teacher is selected)
                            if (selectedUserType == 'Teacher') ...[
                              _buildModernDropdownField(
                                label: 'Grade Level *',
                                value: selectedGradeLevel,
                                items: gradeLevels
                                    .map((grade) => DropdownMenuItem(
                                        value: grade, child: Text(grade)))
                                    .toList(),
                                onChanged: (String? newValue) {
                                  if (newValue != null) {
                                    setState(() {
                                      selectedGradeLevel = newValue;
                                    });
                                  }
                                },
                                icon: Icons.school,
                              ),
                            ],

                            // Staff-specific fields (only show if Staff is selected)
                            if (selectedUserType == 'Staff') ...[
                              _buildMultiSelectRolesField(),
                            ],
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Remarks field
                        SizedBox(
                          width: double.infinity,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.note,
                                      size: 16, color: Colors.grey.shade600),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Remarks *',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border:
                                      Border.all(color: Colors.grey.shade300),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: CustomTextFormField(
                                  maxLine: null,
                                  maxLength: 300,
                                  toShowIcon: false,
                                  toShowPassword: false,
                                  controller: remarksController,
                                  toShowPrefixIcon: false,
                                  validator: (value) =>
                                      TextValidator.simpleValidator(value),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Action Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.cancel),
                              label: const Text('Cancel'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey.shade300,
                                foregroundColor: Colors.grey.shade700,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton.icon(
                              onPressed: () async =>
                                  isLoading ? null : handleSaveMethod(),
                              icon: Icon(
                                  widget.editMode ? Icons.save : Icons.add),
                              label: Text(
                                  widget.editMode ? 'Save Changes' : 'Create'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade600,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
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

        String profileImageUrl = '';
        String profileImageData = '';

        // Handle profile picture upload only in create mode
        if (!widget.editMode &&
            selectedImageBytes != null &&
            selectedFileName != null) {
          try {
            // Create a PlatformFile from the selected bytes
            final file = PlatformFile(
              name: selectedFileName!,
              bytes: selectedImageBytes,
              size: selectedImageBytes!.length,
              path: null,
            );

            // Upload the image to Appwrite
            final result = await firebaseAuthProvider.changeProfilePic(
              idNumberController.text.trim(),
              file,
            );

            if (result != null) {
              throw Exception('Failed to upload profile picture: $result');
            }

            // Get the download URL for the uploaded image
            final bytes = await firebaseAuthProvider.getProfilePic(context);
            if (bytes != null) {
              // Convert bytes to base64 for storage
              profileImageUrl = base64Encode(bytes);
              profileImageData = base64Encode(bytes);
            }
          } catch (e) {
            dPrint('Error uploading profile picture: $e');
            if (mounted) {
              Navigator.pop(context); // Close loading dialog
              DelightfulToast.showError(
                  context, 'Error', 'Failed to upload profile picture');
            }
            return;
          }
        } else if (widget.editMode) {
          // In edit mode, preserve existing profile picture data
          profileImageUrl = widget.registrar?.profilePicLink ?? '';
          profileImageData = widget.registrar?.profilePicData ?? '';
        }

        // Standardize the grade level before saving
        String? standardizedGradeLevel;
        if (selectedGradeLevel != null) {
          standardizedGradeLevel =
              GradeLevelUtils.standardizeGradeLevel(selectedGradeLevel);
        }

        final facultyStaff = FacultyStaffModel(
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
          userType: selectedUserType,
          roles: selectedRoles,
          status: selectedStatus,
          gradeLevel: standardizedGradeLevel,
          profilePicData: profileImageData,
          profilePicLink: profileImageUrl,
          jobLevel: selectedUserType == 'Teacher' ? 'Teacher' : 'Staff',
        );
        await firebaseAuthProvider.saveFacultyStaffData(facultyStaff);
        // dPrint('Fetched data: ${registrar.toMap()}');
        if (mounted) {
          Navigator.pop(context);
          Navigator.pop(context);
          DelightfulToast.showSuccess(context, 'Sucess',
              '${widget.editMode ? 'Edit' : 'Create'} record success.');
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
          DelightfulToast.showError(
              context, 'Error', 'Form errors: ${e.toString()}');
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

  // Helper method to build multi-select roles field
  Widget _buildMultiSelectRolesField() {
    return SizedBox(
      width: 320,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.work_outline, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 8),
              Text(
                'Roles *',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select one or more roles:',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: availableRoles
                      .where((role) => role != 'Teacher')
                      .map((role) => FilterChip(
                            label: Text(role),
                            selected: selectedRoles.contains(role),
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  selectedRoles.add(role);
                                } else {
                                  selectedRoles.remove(role);
                                }
                              });
                            },
                            selectedColor: Colors.blue.shade100,
                            checkmarkColor: Colors.blue.shade700,
                            backgroundColor: Colors.grey.shade100,
                            labelStyle: TextStyle(
                              color: selectedRoles.contains(role)
                                  ? Colors.blue.shade700
                                  : Colors.grey.shade700,
                              fontWeight: selectedRoles.contains(role)
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ))
                      .toList(),
                ),
                if (selectedRoles.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Please select at least one role',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red.shade600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build modern dropdown fields
  Widget _buildModernDropdownField({
    required String label,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required Function(String?) onChanged,
    required IconData icon,
  }) {
    return SizedBox(
      width: 320,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: DropdownButtonFormField<String>(
              value: value,
              items: items,
              onChanged: onChanged,
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build modern form fields
  Widget _buildModernFormField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    String? Function(String?)? validator,
    bool isPassword = false,
    bool isDate = false,
    TextEditingController? ageController,
    bool isReadOnly = false, // New parameter for read-only
    bool isPhoneNumber = false, // New parameter for phone number
  }) {
    return SizedBox(
      width: 320,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: CustomTextFormField(
              controller: controller,
              toShowIcon: false,
              toShowPassword: isPassword,
              isDateTime: isDate,
              ageController: ageController,
              toShowPrefixIcon: false,
              validator: validator,
              maxLength: isPhoneNumber ? 11 : 50,
              isReadOnly: isReadOnly, // Apply read-only
              isPhoneNumber: isPhoneNumber, // Apply phone number formatting
            ),
          ),
        ],
      ),
    );
  }
}
