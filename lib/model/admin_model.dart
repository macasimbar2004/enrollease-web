class AdminModel {
  final String id;
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
  final String profilePicLink;
  final String? profilePicData;
  final String name; // Computed field
  final String userType;
  final List<String> roles;
  final String status;
  final String? gradeLevel;
  final DateTime? schoolYearEndDate;
  final bool autoPromotionEnabled;

  AdminModel({
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
    this.nameExtension,
    required this.password,
    required this.profilePicLink,
    this.profilePicData,
    required this.name,
    required this.userType,
    required this.roles,
    required this.status,
    this.gradeLevel,
    this.schoolYearEndDate,
    this.autoPromotionEnabled = true,
  });

  // Computed name getter
  String get fullName {
    String fullName = '$lastName, $firstName';
    if (middleName.isNotEmpty) {
      fullName += ' $middleName';
    }
    if (nameExtension != null && nameExtension!.isNotEmpty) {
      fullName += ' $nameExtension';
    }
    return fullName;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'lastName': lastName,
      'firstName': firstName,
      'middleName': middleName,
      'dateOfBirth': dateOfBirth,
      'age': age,
      'contact': contact,
      'placeOfBirth': placeOfBirth,
      'address': address,
      'email': email,
      'remarks': remarks,
      'nameExtension': nameExtension,
      'password': password,
      'profilePicLink': profilePicLink,
      'profilePicData': profilePicData,
      'name': name,
      'userType': userType,
      'roles': roles,
      'status': status,
      'gradeLevel': gradeLevel,
      'schoolYearEndDate': schoolYearEndDate?.millisecondsSinceEpoch,
      'autoPromotionEnabled': autoPromotionEnabled,
    };
  }

  factory AdminModel.fromMap(Map<String, dynamic> map) {
    return AdminModel(
      id: map['id'] ?? '',
      lastName: map['lastName'] ?? '',
      firstName: map['firstName'] ?? '',
      middleName: map['middleName'] ?? '',
      dateOfBirth: map['dateOfBirth'] ?? '',
      age: map['age'] ?? '',
      contact: map['contact'] ?? '',
      placeOfBirth: map['placeOfBirth'] ?? '',
      address: map['address'] ?? '',
      email: map['email'] ?? '',
      remarks: map['remarks'] ?? '',
      nameExtension: map['nameExtension'],
      password: map['password'] ?? '',
      profilePicLink: map['profilePicLink'] ?? '',
      profilePicData: map['profilePicData'],
      name: map['name'] ?? '',
      userType: map['userType'] ?? 'Admin',
      roles: map['roles'] != null
          ? List<String>.from(map['roles'])
          : ['Super Admin'],
      status: map['status'] ?? 'active',
      gradeLevel: map['gradeLevel'],
      schoolYearEndDate: map['schoolYearEndDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['schoolYearEndDate'])
          : null,
      autoPromotionEnabled: map['autoPromotionEnabled'] ?? true,
    );
  }

  AdminModel copyWith({
    String? id,
    String? lastName,
    String? firstName,
    String? middleName,
    String? dateOfBirth,
    String? age,
    String? contact,
    String? placeOfBirth,
    String? address,
    String? email,
    String? remarks,
    String? nameExtension,
    String? password,
    String? profilePicLink,
    String? profilePicData,
    String? name,
    String? userType,
    List<String>? roles,
    String? status,
    String? gradeLevel,
    DateTime? schoolYearEndDate,
    bool? autoPromotionEnabled,
  }) {
    return AdminModel(
      id: id ?? this.id,
      lastName: lastName ?? this.lastName,
      firstName: firstName ?? this.firstName,
      middleName: middleName ?? this.middleName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      age: age ?? this.age,
      contact: contact ?? this.contact,
      placeOfBirth: placeOfBirth ?? this.placeOfBirth,
      address: address ?? this.address,
      email: email ?? this.email,
      remarks: remarks ?? this.remarks,
      nameExtension: nameExtension ?? this.nameExtension,
      password: password ?? this.password,
      profilePicLink: profilePicLink ?? this.profilePicLink,
      profilePicData: profilePicData ?? this.profilePicData,
      name: name ?? this.name,
      userType: userType ?? this.userType,
      roles: roles ?? this.roles,
      status: status ?? this.status,
      gradeLevel: gradeLevel ?? this.gradeLevel,
      schoolYearEndDate: schoolYearEndDate ?? this.schoolYearEndDate,
      autoPromotionEnabled: autoPromotionEnabled ?? this.autoPromotionEnabled,
    );
  }
}
