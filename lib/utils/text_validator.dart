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
    if (value?.isEmpty ?? true) {
      return 'Contact Number is required.';
    } else if (value!.length == 10 && !value.startsWith('9')) {
      return 'Invalid 10-digit Number.\nMust start with 9.';
    } else if (value.length == 11 && !value.startsWith('09')) {
      return 'Invalid 11-digit Number.\nMust start with 09.';
    } else if (value.length != 10 && value.length != 11) {
      return 'Contact Number must be\nexactly 10 or 11 digits.';
    }
    return null;
  }
}
