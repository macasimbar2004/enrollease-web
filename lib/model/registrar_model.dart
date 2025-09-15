class RegistrarModel {
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
  
  // RBAC fields
  final String? userType;
  final List<String>? roles;
  final String? status;
  final String? gradeLevel;

  RegistrarModel({
    required this.id,
    required this.lastName,
    required this.profilePicLink,
    required this.profilePicData,
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
    this.nameExtension = 'Select',
    this.jobLevel = 'Registrar Staff',
    this.userType,
    this.roles,
    this.status,
    this.gradeLevel,
  });

  // Convert RegistrarModel to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
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
      'email': email,
      'remarks': remarks,
      'nameExtension': nameExtension,
      'jobLevel': jobLevel,
      'password': password,
      'userType': userType,
      'roles': roles,
      'status': status,
      'gradeLevel': gradeLevel,
    };
  }
}
