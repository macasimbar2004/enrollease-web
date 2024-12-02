class FetchingRegistrarModel {
  String id;
  String lastName;
  String firstName;
  String middleName;
  String dateOfBirth;
  String age;
  String contact;
  String placeOfBirth;
  String address;
  String email;
  String remarks;
  String? nameExtension;
  String password;
  String jobLevel;

  FetchingRegistrarModel({
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
    required this.nameExtension,
    required this.password,
    required this.jobLevel,
  });

  // Convert the model to a map (for SharedPreferences or local storage)
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
      'currentUserDivision': address,
      'currentEmail': email,
      'remarks': remarks,
      'nameExtension': nameExtension, // Ensure nullable fields are handled
      'currentPassword': password,
      'userRole': jobLevel, // Ensure nullable fields are handled
    };
  }
}
