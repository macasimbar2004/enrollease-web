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
  String profilePicLink;

  FetchingRegistrarModel({
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
    required this.nameExtension,
    required this.password,
    required this.jobLevel,
  });

  FetchingRegistrarModel copyWith({
    final String? id,
    final String? lastName,
    final String? firstName,
    final String? middleName,
    final String? dateOfBirth,
    final String? age,
    final String? contact,
    final String? placeOfBirth,
    final String? address,
    final String? email,
    final String? remarks,
    final String? nameExtension,
    final String? password,
    final String? jobLevel,
    final String? profilePicLink,
  }) {
    return FetchingRegistrarModel(
      id: id ?? this.id,
      lastName: lastName ?? this.lastName,
      firstName: firstName ?? this.firstName,
      middleName: middleName ?? this.middleName,
      profilePicLink: profilePicLink ?? this.profilePicLink,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      age: age ?? this.age,
      contact: contact ?? this.contact,
      placeOfBirth: placeOfBirth ?? this.placeOfBirth,
      address: address ?? this.address,
      email: email ?? this.email,
      remarks: remarks ?? this.remarks,
      nameExtension: nameExtension ?? this.nameExtension,
      password: password ?? this.password,
      jobLevel: jobLevel ?? this.jobLevel,
    );
  }

  // Convert the model to a map (for SharedPreferences or local storage)
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
      'nameExtension': nameExtension, // Ensure nullable fields are handled
      'password': password,
      'jobLevel': jobLevel, // Ensure nullable fields are handled
    };
  }

  factory FetchingRegistrarModel.fromMap(String id, Map<String, dynamic> data) {
    return FetchingRegistrarModel(
      profilePicLink: data['profilePicLink'] ?? '',
      id: id.isEmpty ? data['id'] ?? '' : id,
      lastName: data['lastName'],
      firstName: data['firstName'],
      middleName: data['middleName'],
      dateOfBirth: data['dateOfBirth'],
      age: data['age'],
      contact: data['contact'],
      placeOfBirth: data['placeOfBirth'],
      address: data['address'],
      email: data['email'],
      remarks: data['remarks'],
      nameExtension: data['nameExtension'],
      password: data['password'],
      jobLevel: data['jobLevel'],
    );
  }
}
