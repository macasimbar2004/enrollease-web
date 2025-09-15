import 'package:enrollease_web/model/grade_level_model.dart';

/// Utility class for handling grade level conversions and standardization
class GradeLevelUtils {
  /// Standardize grade level format - convert any format to the standard ID format
  /// Examples:
  /// - "Grade 4" -> "grade4"
  /// - "g4" -> "grade4"
  /// - "4" -> "grade4"
  /// - "Kinder I" -> "kinderI"
  /// - "Kinder II" -> "kinderII"
  static String standardizeGradeLevel(String? gradeLevel) {
    if (gradeLevel == null || gradeLevel.isEmpty) {
      return 'kinderI'; // Default fallback
    }

    final cleanGrade = gradeLevel.trim().toLowerCase();

    // Handle different input formats
    if (cleanGrade.contains('kinder')) {
      if (cleanGrade.contains('ii') || cleanGrade.contains('2')) {
        return 'kinderII';
      } else {
        return 'kinderI';
      }
    }

    // Extract numeric value for grades 1-7
    final numericMatch = RegExp(r'(\d+)').firstMatch(cleanGrade);
    if (numericMatch != null) {
      final numericValue = int.parse(numericMatch.group(1)!);
      if (numericValue >= 1 && numericValue <= 7) {
        return 'grade$numericValue';
      }
    }

    // Fallback to default
    return 'kinderI';
  }

  /// Convert standard grade level ID to display name
  /// Examples:
  /// - "grade4" -> "Grade 4"
  /// - "kinderI" -> "Kinder I"
  static String getDisplayName(String gradeLevelId) {
    final level = GradeLevels.getLevelById(gradeLevelId);
    return level?.displayName ?? 'Kinder I';
  }

  /// Convert standard grade level ID to student collection format
  /// Examples:
  /// - "grade4" -> "g4"
  /// - "kinderI" -> "k1"
  /// - "kinderII" -> "k2"
  static String getStudentCollectionFormat(String gradeLevelId) {
    switch (gradeLevelId) {
      case 'kinderI':
        return 'k1';
      case 'kinderII':
        return 'k2';
      case 'grade1':
        return 'g1';
      case 'grade2':
        return 'g2';
      case 'grade3':
        return 'g3';
      case 'grade4':
        return 'g4';
      case 'grade5':
        return 'g5';
      case 'grade6':
        return 'g6';
      case 'grade7':
        return 'g7';
      default:
        return 'k1'; // Default fallback
    }
  }

  /// Convert student collection format to standard grade level ID
  /// Examples:
  /// - "g4" -> "grade4"
  /// - "k1" -> "kinderI"
  /// - "k2" -> "kinderII"
  static String fromStudentCollectionFormat(String studentGrade) {
    switch (studentGrade.toLowerCase()) {
      case 'k1':
        return 'kinderI';
      case 'k2':
        return 'kinderII';
      case 'g1':
        return 'grade1';
      case 'g2':
        return 'grade2';
      case 'g3':
        return 'grade3';
      case 'g4':
        return 'grade4';
      case 'g5':
        return 'grade5';
      case 'g6':
        return 'grade6';
      case 'g7':
        return 'grade7';
      default:
        return 'kinderI'; // Default fallback
    }
  }

  /// Get all available grade levels for the school (Nursery to Grade 7)
  static List<GradeLevel> getAllSchoolGradeLevels() {
    return [
      GradeLevels.kinderI,
      GradeLevels.kinderII,
      GradeLevels.grade1,
      GradeLevels.grade2,
      GradeLevels.grade3,
      GradeLevels.grade4,
      GradeLevels.grade5,
      GradeLevels.grade6,
      // Note: Grade 7 is not in the current GradeLevels model, but we'll add it
      const GradeLevel(
        id: 'grade7',
        displayName: 'Grade 7',
        numericValue: 7,
      ),
    ];
  }

  /// Check if a grade level ID is valid
  static bool isValidGradeLevel(String gradeLevelId) {
    return getAllSchoolGradeLevels().any((level) => level.id == gradeLevelId);
  }
}
