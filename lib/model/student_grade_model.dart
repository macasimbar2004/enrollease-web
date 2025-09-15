class StudentGrade {
  final String id;
  final String studentId;
  final String studentName;
  final String gradeLevel;
  final String schoolYear;
  final Map<String, Map<String, double>> subjectGrades;
  final String? remarks;
  final DateTime createdAt;
  final DateTime updatedAt;

  StudentGrade({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.gradeLevel,
    required this.schoolYear,
    required this.subjectGrades,
    this.remarks,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StudentGrade.fromMap(Map<String, dynamic> map) {
    return StudentGrade(
      id: map['id'] ?? '',
      studentId: map['studentId'] ?? '',
      studentName: map['studentName'] ?? '',
      gradeLevel: map['gradeLevel'] ?? '',
      schoolYear: map['schoolYear'] ?? '',
      subjectGrades: Map<String, Map<String, double>>.from(
        map['subjectGrades']?.map(
              (key, value) => MapEntry(
                key,
                Map<String, double>.from(value),
              ),
            ) ??
            {},
      ),
      remarks: map['remarks'],
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as dynamic).toDate()
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as dynamic).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentId': studentId,
      'studentName': studentName,
      'gradeLevel': gradeLevel,
      'schoolYear': schoolYear,
      'subjectGrades': subjectGrades,
      'remarks': remarks,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  double getSubjectAverage(String subject) {
    if (!subjectGrades.containsKey(subject)) {
      return 0.0;
    }

    final grades = subjectGrades[subject]!;
    if (grades.isEmpty) {
      return 0.0;
    }

    double sum = 0.0;
    grades.forEach((key, value) {
      sum += value;
    });

    return sum / grades.length;
  }

  double getOverallAverage() {
    if (subjectGrades.isEmpty) {
      return 0.0;
    }

    double sum = 0.0;
    int count = 0;

    subjectGrades.forEach((subject, grades) {
      sum += getSubjectAverage(subject);
      count++;
    });

    return count > 0 ? sum / count : 0.0;
  }
}

class GradingPeriod {
  static const String firstQuarter = 'Q1';
  static const String secondQuarter = 'Q2';
  static const String thirdQuarter = 'Q3';
  static const String fourthQuarter = 'Q4';

  static List<String> quarters = [
    firstQuarter,
    secondQuarter,
    thirdQuarter,
    fourthQuarter,
  ];
}

class Subject {
  final String id;
  final String name;
  final String displayName;

  const Subject({
    required this.id,
    required this.name,
    required this.displayName,
  });
}

class Subjects {
  static const math = Subject(
    id: 'math',
    name: 'mathematics',
    displayName: 'Mathematics',
  );

  static const english = Subject(
    id: 'eng',
    name: 'english',
    displayName: 'English',
  );

  static const science = Subject(
    id: 'sci',
    name: 'science',
    displayName: 'Science',
  );

  static const filipino = Subject(
    id: 'fil',
    name: 'filipino',
    displayName: 'Filipino',
  );

  static const aralingPanlipunan = Subject(
    id: 'ap',
    name: 'araling_panlipunan',
    displayName: 'Araling Panlipunan',
  );

  static const mapeh = Subject(
    id: 'mapeh',
    name: 'mapeh',
    displayName: 'MAPEH',
  );

  static const edukasyonSaPagpapakatao = Subject(
    id: 'esp',
    name: 'edukasyon_sa_pagpapakatao',
    displayName: 'Edukasyon sa Pagpapakatao',
  );

  static const List<Subject> allSubjects = [
    math,
    english,
    science,
    filipino,
    aralingPanlipunan,
    mapeh,
    edukasyonSaPagpapakatao,
  ];
}
