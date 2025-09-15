class TextValidator {
  TextValidator._();
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
    // Check if the length is not exactly 11 digits
    else if (value!.length != 11) {
      // If not 11 characters, return an error message indicating the required length
      return 'Contact Number must be exactly 11 digits.';
    }
    // Check if the value starts with '09' (the standard format for Philippine mobile numbers)
    else if (!value.startsWith('09')) {
      // If it doesn't start with '09', return an error message
      return 'Contact Number must start with 09.';
    }
    // Check if the value contains only digits
    else if (!RegExp(r'^\d{11}$').hasMatch(value)) {
      // If the regular expression doesn't match, return an error message
      return 'Invalid Contact Number. It should contain only digits.';
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
