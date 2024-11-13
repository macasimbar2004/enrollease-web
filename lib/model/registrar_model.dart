class RegistrarModel {
  String identification;
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

  RegistrarModel(
      {required this.identification,
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
      this.jobLevel});

  // Convert RegistrarModel to Map
  Map<String, dynamic> toMap() {
    return {
      'identification': identification,
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
      'password': password
    };
  }
}
