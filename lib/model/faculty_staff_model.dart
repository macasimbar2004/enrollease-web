class FacultyStaffModel {
  String id;
  final String lastName;
  final String firstName;
  final String middleName;
  final String dateOfBirth;
  final String age;
  final String contact;
  final String placeOfBirth;
  final String address;
  final String email;
  final String remarks;
  final String? nameExtension;
  final String password;
  final String? jobLevel;
  final String? profilePicLink;
  final String? profilePicData;

  // New RBAC fields from requirements
  final String name; // Full name (firstName + middleName + lastName)
  final String userType; // "Teacher" | "Staff"
  final List<String> roles; // ["Teacher", "Registrar Officer", etc.]
  final String status; // "active" | "disabled"
  final String? gradeLevel; // For teachers: "Grade 1", "Grade 2", etc.

  FacultyStaffModel({
    required this.id,
    required this.lastName,
    required this.firstName,
    required this.middleName,
    required this.dateOfBirth,
    required this.age,
    required this.contact,
    required this.placeOfBirth,
    required this.address,
    required this.email,
    required this.remarks,
    required this.password,
    required this.userType,
    required this.roles,
    required this.status,
    this.nameExtension = 'Select',
    this.jobLevel,
    this.profilePicLink,
    this.profilePicData,
    this.gradeLevel,
  }) : name = '$firstName $middleName $lastName'.trim();

  // Convert FacultyStaffModel to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'userType': userType,
      'roles': roles,
      'status': status,
      'gradeLevel': gradeLevel,
      'profilePicLink': profilePicLink,
      'profilePicData': profilePicData,
      'lastName': lastName,
      'firstName': firstName,
      'middleName': middleName,
      'dateOfBirth': dateOfBirth,
      'age': age,
      'contact': contact,
      'placeOfBirth': placeOfBirth,
      'address': address,
      'remarks': remarks,
      'nameExtension': nameExtension,
      'jobLevel': jobLevel,
      'password': password,
    };
  }

  // Create FacultyStaffModel from Map
  factory FacultyStaffModel.fromMap(String id, Map<String, dynamic> map) {
    return FacultyStaffModel(
      id: id,
      email: map['email'] ?? '',
      userType: map['userType'] ?? 'Staff',
      roles: List<String>.from(map['roles'] ?? ['Staff']),
      status: map['status'] ?? 'active',
      gradeLevel: map['gradeLevel'],
      profilePicLink: map['profilePicLink'],
      profilePicData: map['profilePicData'],
      lastName: map['lastName'] ?? '',
      firstName: map['firstName'] ?? '',
      middleName: map['middleName'] ?? '',
      dateOfBirth: map['dateOfBirth'] ?? '',
      age: map['age'] ?? '',
      contact: map['contact'] ?? '',
      placeOfBirth: map['placeOfBirth'] ?? '',
      address: map['address'] ?? '',
      remarks: map['remarks'] ?? '',
      nameExtension: map['nameExtension'] ?? 'Select',
      jobLevel: map['jobLevel'],
      password: map['password'] ?? '',
    );
  }

  // Convert from old RegistrarModel (for migration)
  factory FacultyStaffModel.fromRegistrarModel(
      String id, Map<String, dynamic> map) {
    return FacultyStaffModel(
      id: id,
      email: map['email'] ?? '',
      userType: 'Staff', // Default for existing registrars
      roles: ['Registrar Officer'], // Default role for existing registrars
      status: 'active', // Default status for existing registrars
      gradeLevel: map['gradeLevel'], // Preserve grade level if exists
      profilePicLink: map['profilePicLink'],
      profilePicData: map['profilePicData'],
      lastName: map['lastName'] ?? '',
      firstName: map['firstName'] ?? '',
      middleName: map['middleName'] ?? '',
      dateOfBirth: map['dateOfBirth'] ?? '',
      age: map['age'] ?? '',
      contact: map['contact'] ?? '',
      placeOfBirth: map['placeOfBirth'] ?? '',
      address: map['address'] ?? '',
      remarks: map['remarks'] ?? '',
      nameExtension: map['nameExtension'] ?? 'Select',
      jobLevel: map['jobLevel'] ?? 'Registrar Staff',
      password: map['password'] ?? '',
    );
  }
}
