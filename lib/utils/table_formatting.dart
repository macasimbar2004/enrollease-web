class TableFormatting {
  /// Formats grade level strings to display names
  /// Converts: g5 -> Grade 5, k1 -> Kinder 1, etc.
  static String formatGradeLevel(String? gradeLevel) {
    if (gradeLevel == null || gradeLevel.isEmpty) return '';
    
    String gradeStr = gradeLevel.toLowerCase();
    switch (gradeStr) {
      case 'nursery':
        return 'Nursery';
      case 'k1':
        return 'Kinder 1';
      case 'k2':
        return 'Kinder 2';
      case 'g1':
        return 'Grade 1';
      case 'g2':
        return 'Grade 2';
      case 'g3':
        return 'Grade 3';
      case 'g4':
        return 'Grade 4';
      case 'g5':
        return 'Grade 5';
      case 'g6':
        return 'Grade 6';
      default:
        return gradeLevel; // Return original if no match
    }
  }
  
  /// Formats status strings with proper capitalization
  /// Converts: pending -> Pending, approved -> Approved, etc.
  static String formatStatus(String? status) {
    if (status == null || status.isEmpty) return '';
    
    String statusStr = status.toLowerCase();
    return '${statusStr[0].toUpperCase()}${statusStr.substring(1)}';
  }
  
  /// Formats gender strings with proper capitalization
  /// Converts: male -> Male, female -> Female, etc.
  static String formatGender(String? gender) {
    if (gender == null || gender.isEmpty) return '';
    
    String genderStr = gender.toLowerCase();
    return '${genderStr[0].toUpperCase()}${genderStr.substring(1)}';
  }
  
  /// Formats civil status strings with proper capitalization
  /// Converts: single -> Single, married -> Married, etc.
  static String formatCivilStatus(String? civilStatus) {
    if (civilStatus == null || civilStatus.isEmpty) return '';
    
    String statusStr = civilStatus.toLowerCase();
    return '${statusStr[0].toUpperCase()}${statusStr.substring(1)}';
  }
  
  /// Formats boolean values to user-friendly strings
  /// Converts: true -> Yes, false -> No
  static String formatBoolean(bool? value, {String trueText = 'Yes', String falseText = 'No'}) {
    if (value == null) return '';
    return value ? trueText : falseText;
  }
  
  /// Formats full name from separate name components
  /// Combines firstName, middleName, lastName with proper spacing
  static String formatFullName({
    String? firstName,
    String? middleName,
    String? lastName,
  }) {
    List<String> nameParts = [];
    
    if (firstName?.isNotEmpty == true) nameParts.add(firstName!);
    if (middleName?.isNotEmpty == true) nameParts.add(middleName!);
    if (lastName?.isNotEmpty == true) nameParts.add(lastName!);
    
    return nameParts.join(' ');
  }
  
  /// Generic formatter for enum-like strings
  /// Converts any string to proper case (first letter capitalized)
  static String formatProperCase(String? text) {
    if (text == null || text.isEmpty) return '';
    
    String cleanText = text.toLowerCase();
    return '${cleanText[0].toUpperCase()}${cleanText.substring(1)}';
  }
  
  /// Formats phone numbers (if needed in the future)
  static String formatPhoneNumber(String? phoneNumber) {
    if (phoneNumber == null || phoneNumber.isEmpty) return '';
    
    // Remove any non-digit characters
    String digitsOnly = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    
    // Format as needed (this is a basic example)
    if (digitsOnly.length == 11 && digitsOnly.startsWith('09')) {
      return '${digitsOnly.substring(0, 4)}-${digitsOnly.substring(4, 7)}-${digitsOnly.substring(7)}';
    }
    
    return phoneNumber; // Return original if doesn't match expected format
  }
}
