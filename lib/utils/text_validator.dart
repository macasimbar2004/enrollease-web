class TextValidator {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required.';
    } else if (!value.contains('@')) {
      return 'Invalid Email.\nMust contain @.';
    } else if (!value.endsWith('.com')) {
      return 'Invalid Email.\nMust end with .com.';
    }
    return null;
  }

  static String? validateContact(String? value) {
    // Check if the value is empty or null
    if (value?.isEmpty ?? true) {
      // If empty or null, return an error message
      return 'Contact Number is required.';
    }
    // Check if the length is not exactly 13 characters (including '+63')
    else if (value!.length != 13) {
      // If not 13 characters, return an error message indicating the required length
      return 'Contact Number must be exactly 13 digits (including +63).';
    }
    // Check if the value starts with '+63' (the country code for the Philippines)
    else if (!value.startsWith('+63')) {
      // If it doesn't start with '+63', return an error message
      return 'Contact Number must start with +63.';
    }
    // Check if the value matches the pattern for a valid contact number
    // The regular expression ensures it starts with '+63' followed by exactly 10 digits
    else if (!RegExp(r'^\+63\d{10}$').hasMatch(value)) {
      // If the regular expression doesn't match, return an error message
      return 'Invalid Contact Number. It should be in the format +63XXXXXXXXXX.';
    }
    // If all checks pass, return null indicating the contact number is valid
    return null;
  }

  static String? simpleValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    return null;
  }
}
