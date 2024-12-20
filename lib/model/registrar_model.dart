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

  RegistrarModel({
    required this.id,
    required this.lastName,
    required this.profilePicLink,
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
  });

  // Convert RegistrarModel to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'profilePicLink': profilePicLink,
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
    };
  }
}
