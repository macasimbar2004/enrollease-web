import 'package:flutter/material.dart';
import '../utils/grade_service.dart';

/// A widget that displays a student's grade for a specific quarter
class GradeCellWidget extends StatelessWidget {
  final String studentId;
  final String gradeLevel;
  final String schoolYear;
  final String quarter;

  const GradeCellWidget({
    super.key,
    required this.studentId,
    required this.gradeLevel,
    required this.schoolYear,
    required this.quarter,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: GradeService.getQuarterGrade(
          studentId, gradeLevel, schoolYear, quarter),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        if (snapshot.hasError) {
          return const Text(
            'Error',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.red),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          final data = snapshot.data!;

          // Format the grade to display only 2 decimal places
          String formattedGrade;
          if (data['grade'] != null) {
            // Convert to double and format
            final gradeValue = data['grade'] is num
                ? (data['grade'] as num).toDouble()
                : double.tryParse(data['grade'].toString()) ?? 0.0;

            // Format to 2 decimal places
            formattedGrade = gradeValue.toStringAsFixed(2);
          } else {
            formattedGrade = '';
          }

          return Text(
            formattedGrade.isNotEmpty ? formattedGrade : '--',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: GradeService.getGradeColor(data['grade']),
            ),
            textAlign: TextAlign.center,
          );
        }

        return const Text(
          '--',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        );
      },
    );
  }
}

/// A widget that displays a student's final grade across all quarters
class FinalGradeCellWidget extends StatelessWidget {
  final String studentId;
  final String gradeLevel;
  final String schoolYear;

  const FinalGradeCellWidget({
    super.key,
    required this.studentId,
    required this.gradeLevel,
    required this.schoolYear,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: GradeService.getAllGrades(studentId, gradeLevel, schoolYear),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        if (snapshot.hasError) {
          return const Text(
            'Error',
            style: TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text(
            '--',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          );
        }

        final grades = snapshot.data!;
        final finalGrade = GradeService.calculateFinalGrade(grades);

        return Text(
          finalGrade > 0 ? finalGrade.toStringAsFixed(2) : '--',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: GradeService.getGradeColor(finalGrade),
          ),
          textAlign: TextAlign.center,
        );
      },
    );
  }
}
