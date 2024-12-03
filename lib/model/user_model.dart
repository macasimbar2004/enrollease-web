class UserModel {
  final String userName;
  final String email;
  final String contactNumber;
  final String uid;
  // final Gender? gender;
  final String role;
  final String profilePicLink;
  final bool isActive;

  UserModel({
    required this.profilePicLink,
    // required this.gender,
    required this.userName,
    required this.email,
    required this.contactNumber,
    required this.uid,
    required this.role,
    required this.isActive,
  });

  // A method to convert data from a map (useful for Firestore)
  factory UserModel.fromMap(Map<String, dynamic> data) {
    // Gender? gender;
    // switch (data['gender']) {
    //   case 'male':
    //     gender = Gender.male;
    //     break;
    //   case 'female':
    //     gender = Gender.female;
    //     break;
    // }
    return UserModel(
      profilePicLink: data['profilePic'] ?? '',
      userName: data['userName'] ?? '',
      // gender: gender,
      role: data['role'] ?? '',
      email: data['email'] ?? '',
      contactNumber: data['contactNumber'] ?? '',
      uid: data['uid'] ?? '',
      isActive: data['isActive'] ?? '',
    );
  }

  // A method to convert the user object back to a map
  Map<String, dynamic> toMap() {
    return {
      'userName': userName,
      'role': role,
      'email': email,
      'contactNumber': contactNumber,
      'uid': uid,
      'profilePicLink': profilePicLink,
      'isActive': isActive,
    };
  }
}
