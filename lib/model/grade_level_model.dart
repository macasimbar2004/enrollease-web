import 'package:flutter/material.dart';

class GradeLevel {
  final String id;
  final String displayName;
  final int numericValue;

  const GradeLevel({
    required this.id,
    required this.displayName,
    required this.numericValue,
  });
}

class GradeLevels {
  static const GradeLevel kinderI = GradeLevel(
    id: 'kinderI',
    displayName: 'Kinder I',
    numericValue: -1,
  );

  static const GradeLevel kinderII = GradeLevel(
    id: 'kinderII',
    displayName: 'Kinder II',
    numericValue: 0,
  );

  static const GradeLevel grade1 = GradeLevel(
    id: 'grade1',
    displayName: 'Grade 1',
    numericValue: 1,
  );

  static const GradeLevel grade2 = GradeLevel(
    id: 'grade2',
    displayName: 'Grade 2',
    numericValue: 2,
  );

  static const GradeLevel grade3 = GradeLevel(
    id: 'grade3',
    displayName: 'Grade 3',
    numericValue: 3,
  );

  static const GradeLevel grade4 = GradeLevel(
    id: 'grade4',
    displayName: 'Grade 4',
    numericValue: 4,
  );

  static const GradeLevel grade5 = GradeLevel(
    id: 'grade5',
    displayName: 'Grade 5',
    numericValue: 5,
  );

  static const GradeLevel grade6 = GradeLevel(
    id: 'grade6',
    displayName: 'Grade 6',
    numericValue: 6,
  );

  static const List<GradeLevel> allLevels = [
    kinderI,
    kinderII,
    grade1,
    grade2,
    grade3,
    grade4,
    grade5,
    grade6,
  ];

  /// Returns the grade level object by its id
  static GradeLevel? getLevelById(String id) {
    debugPrint('Looking for grade level with id: "$id"');

    for (var level in allLevels) {
      debugPrint('Comparing with: "${level.id}" (${level.displayName})');
    }

    try {
      final found = allLevels.firstWhere((level) => level.id == id);
      debugPrint('Found grade level: ${found.displayName}');
      return found;
    } catch (e) {
      debugPrint('No grade level found for id: "$id"');
      return null;
    }
  }

  /// Returns a sorted list of grade levels by numeric value
  static List<GradeLevel> getSortedLevels({bool ascending = true}) {
    final sorted = List<GradeLevel>.from(allLevels);
    sorted.sort((a, b) => ascending
        ? a.numericValue.compareTo(b.numericValue)
        : b.numericValue.compareTo(a.numericValue));
    return sorted;
  }
}

class SchoolYear {
  /// Format: "YYYY-YYYY" (e.g., "2023-2024")
  final String yearRange;

  const SchoolYear(this.yearRange);

  /// Get the current school year in format "YYYY-YYYY"
  static String getCurrentSchoolYear() {
    final now = DateTime.now();
    final currentYear = now.year;
    final currentMonth = now.month;

    // If we're in the latter part of the year (June-December),
    // then the school year is currentYear-nextYear
    // Otherwise, it's previousYear-currentYear
    if (currentMonth >= 6) {
      // June onwards
      return '$currentYear-${currentYear + 1}';
    } else {
      return '${currentYear - 1}-$currentYear';
    }
  }

  /// Get a list of recent school years including the current one
  static List<String> getRecentSchoolYears(int count) {
    final currentSchoolYear = getCurrentSchoolYear();
    final years = <String>[currentSchoolYear];

    // Parse the starting year from the current school year
    final currentStartYear = int.parse(currentSchoolYear.split('-').first);

    // Generate previous school years
    for (int i = 1; i < count; i++) {
      final startYear = currentStartYear - i;
      final endYear = startYear + 1;
      years.add('$startYear-$endYear');
    }

    return years;
  }
}
