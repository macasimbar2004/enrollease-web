import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../model/student_grade_model.dart';
import '../utils/grade_level_utils.dart';
import '../services/faculty_activity_service.dart';
import '../model/faculty_activity_model.dart';
import 'dart:convert';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Efficient Grade Storage Service
/// Uses a more efficient document structure for storing student grades
class EfficientGradeService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Generate a clean document ID for grade storage
  /// Format: "SDASG{year}-{number}" (e.g., "SDASG25-000001")
  /// This allows us to store all quarters for a student in one document
  static String _generateGradeDocumentId(String studentId, String schoolYear) {
    // Convert student ID to grade ID by replacing "SDAS" with "SDASG"
    // Example: "SDAS25-000000" becomes "SDASG25-000000"
    if (studentId.startsWith('SDAS')) {
      return studentId.replaceFirst('SDAS', 'SDASG');
    }
    // Fallback for other ID formats
    return 'SDASG${studentId}_$schoolYear';
  }

  /// Save grades for a specific quarter
  /// Document structure:
  /// {
  ///   studentId: "STU001",
  ///   studentName: "John Doe",
  ///   gradeLevel: "grade4",
  ///   schoolYear: "2023-2024",
  ///   quarters: {
  ///     "Q1": {
  ///       subjectGrades: { "Math": 85.5, "English": 90.0, ... },
  ///       average: 87.75,
  ///       updatedAt: timestamp
  ///     },
  ///     "Q2": { ... },
  ///     "Q3": { ... },
  ///     "Q4": { ... }
  ///   },
  ///   finalGrade: 88.25,
  ///   createdAt: timestamp,
  ///   updatedAt: timestamp
  /// }
  static Future<bool> saveQuarterGrades({
    required String studentId,
    required String studentName,
    required String gradeLevel,
    required String schoolYear,
    required String quarter,
    required Map<String, double> subjectGrades,
    String? reportBase64,
    String? facultyId,
    String? facultyName,
  }) async {
    try {
      final docId = _generateGradeDocumentId(studentId, schoolYear);
      final now = FieldValue.serverTimestamp();

      // Calculate average for this quarter
      double quarterAverage = 0.0;
      if (subjectGrades.isNotEmpty) {
        final sum = subjectGrades.values.reduce((a, b) => a + b);
        quarterAverage = sum / subjectGrades.length;
      }

      // Prepare quarter data
      final quarterData = {
        'subjectGrades': subjectGrades,
        'average': quarterAverage,
        'updatedAt': now,
      };

      // Add report card if provided
      if (reportBase64 != null) {
        quarterData['reportBase64'] = reportBase64;
      }

      // Update the document with the new quarter data using dot notation
      await _firestore.collection('grades').doc(docId).set({
        'studentId': studentId,
        'studentName': studentName,
        'gradeLevel': gradeLevel,
        'schoolYear': schoolYear,
        'quarters.$quarter': quarterData,
        'updatedAt': now,
      }, SetOptions(merge: true));

      // Calculate and update final grade
      await _updateFinalGrade(docId);

      // Log grade entry activity if faculty info is provided
      if (facultyId != null && facultyName != null) {
        await FacultyActivityService.logActivity(
          facultyId: facultyId,
          facultyName: facultyName,
          activityType: FacultyActivityModel.gradeEntry,
          description: 'Entered grades for $studentName ($quarter)',
          targetId: studentId,
          targetName: studentName,
          metadata: {
            'gradeLevel': gradeLevel,
            'schoolYear': schoolYear,
            'quarter': quarter,
            'subjectCount': subjectGrades.length,
            'average': quarterAverage,
          },
        );
      }

      return true;
    } catch (e) {
      debugPrint('Error saving quarter grades: $e');
      return false;
    }
  }

  /// Update the final grade for a student
  static Future<void> _updateFinalGrade(String docId) async {
    try {
      final doc = await _firestore.collection('grades').doc(docId).get();
      if (!doc.exists) return;

      final data = doc.data()!;

      double totalAverage = 0.0;
      int quarterCount = 0;

      // Calculate average across all quarters using dot notation fields
      final quarters = ['Q1', 'Q2', 'Q3', 'Q4'];
      for (final quarter in quarters) {
        final quarterFieldKey = 'quarters.$quarter';
        final quarterData = data[quarterFieldKey] as Map<String, dynamic>?;

        if (quarterData != null) {
          final average = quarterData['average'] as double? ?? 0.0;
          if (average > 0) {
            totalAverage += average;
            quarterCount++;
          }
        }
      }

      final finalGrade = quarterCount > 0 ? totalAverage / quarterCount : 0.0;

      // Update the final grade
      await _firestore.collection('grades').doc(docId).update({
        'finalGrade': finalGrade,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error updating final grade: $e');
    }
  }

  /// Get grades for a specific quarter
  static Future<Map<String, dynamic>?> getQuarterGrades({
    required String studentId,
    required String schoolYear,
    required String quarter,
  }) async {
    try {
      final docId = _generateGradeDocumentId(studentId, schoolYear);
      final doc = await _firestore.collection('grades').doc(docId).get();

      if (!doc.exists) {
        return null;
      }

      final data = doc.data()!;

      // Look for quarters.Q1, quarters.Q2, etc. (dot notation fields)
      final quarterFieldKey = 'quarters.$quarter';
      final quarterData = data[quarterFieldKey] as Map<String, dynamic>?;

      if (quarterData == null) {
        return null;
      }

      return {
        'studentId': data['studentId'],
        'studentName': data['studentName'],
        'gradeLevel': data['gradeLevel'],
        'schoolYear': data['schoolYear'],
        'quarter': quarter,
        'subjectGrades': quarterData['subjectGrades'] ?? {},
        'average': quarterData['average'] ?? 0.0,
        'reportBase64': quarterData['reportBase64'],
        'updatedAt': quarterData['updatedAt'],
      };
    } catch (e) {
      debugPrint('Error getting quarter grades: $e');
      return null;
    }
  }

  /// Get all grades for a student in a school year
  static Future<Map<String, dynamic>?> getAllGradesForStudent({
    required String studentId,
    required String schoolYear,
  }) async {
    try {
      final docId = _generateGradeDocumentId(studentId, schoolYear);
      final doc = await _firestore.collection('grades').doc(docId).get();

      if (!doc.exists) return null;

      return doc.data();
    } catch (e) {
      debugPrint('Error getting all grades for student: $e');
      return null;
    }
  }

  /// Get all students with grades for a specific grade level and school year
  static Future<List<Map<String, dynamic>>> getStudentsWithGrades({
    required String gradeLevel,
    required String schoolYear,
  }) async {
    try {
      // Convert to standardized format for consistent querying
      final standardizedGradeLevel =
          GradeLevelUtils.standardizeGradeLevel(gradeLevel);

      final querySnapshot = await _firestore
          .collection('grades')
          .where('gradeLevel', isEqualTo: standardizedGradeLevel)
          .where('schoolYear', isEqualTo: schoolYear)
          .get();

      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      debugPrint('Error getting students with grades: $e');
      return [];
    }
  }

  /// Check if a student has passing grades (for auto-promotion)
  static Future<bool> hasPassingGrades({
    required String studentId,
    required String schoolYear,
    double passingGrade = 75.0,
  }) async {
    try {
      final allGrades = await getAllGradesForStudent(
        studentId: studentId,
        schoolYear: schoolYear,
      );

      if (allGrades == null) {
        return false;
      }

      // Check if student has at least 3 quarters of passing grades using dot notation
      int passingQuarters = 0;
      int totalQuarters = 0;

      final quarters = ['Q1', 'Q2', 'Q3', 'Q4'];
      for (final quarter in quarters) {
        final quarterFieldKey = 'quarters.$quarter';
        final quarterData = allGrades[quarterFieldKey] as Map<String, dynamic>?;

        if (quarterData != null) {
          final average = quarterData['average'] as double? ?? 0.0;
          if (average > 0) {
            totalQuarters++;
            if (average >= passingGrade) {
              passingQuarters++;
            }
          }
        }
      }

      // Student needs at least 3 quarters with passing grades
      return passingQuarters >= 3 && totalQuarters >= 3;
    } catch (e) {
      debugPrint('Error checking passing grades: $e');
      return false;
    }
  }

  /// Get final grade for a student (for auto-promotion)
  static Future<double> getFinalGrade({
    required String studentId,
    required String schoolYear,
  }) async {
    try {
      final allGrades = await getAllGradesForStudent(
        studentId: studentId,
        schoolYear: schoolYear,
      );

      if (allGrades == null) return 0.0;

      return (allGrades['finalGrade'] as double?) ?? 0.0;
    } catch (e) {
      debugPrint('Error getting final grade: $e');
      return 0.0;
    }
  }

  /// Get all subject grades across all quarters for a student
  /// Returns a map where each subject has its quarterly grades
  static Future<Map<String, Map<String, double>>> getAllSubjectGrades({
    required String studentId,
    required String schoolYear,
  }) async {
    try {
      final allGrades = await getAllGradesForStudent(
        studentId: studentId,
        schoolYear: schoolYear,
      );

      if (allGrades == null) return {};

      final subjectGrades = <String, Map<String, double>>{};

      // Initialize all subjects
      for (var subject in Subjects.allSubjects) {
        subjectGrades[subject.id] = {};
      }

      // Extract grades from each quarter using dot notation
      final quarters = ['Q1', 'Q2', 'Q3', 'Q4'];
      for (final quarter in quarters) {
        final quarterFieldKey = 'quarters.$quarter';
        final quarterData = allGrades[quarterFieldKey] as Map<String, dynamic>?;

        if (quarterData != null) {
          final quarterSubjectGrades =
              quarterData['subjectGrades'] as Map<String, dynamic>? ?? {};

          quarterSubjectGrades.forEach((subjectId, grade) {
            if (subjectGrades.containsKey(subjectId)) {
              subjectGrades[subjectId]![quarter] = (grade as num).toDouble();
            }
          });
        }
      }

      return subjectGrades;
    } catch (e) {
      debugPrint('Error getting all subject grades: $e');
      return {};
    }
  }

  /// Calculate final grades for each subject across all quarters
  static Future<Map<String, double>> calculateSubjectFinalGrades({
    required String studentId,
    required String schoolYear,
  }) async {
    try {
      final subjectGrades = await getAllSubjectGrades(
        studentId: studentId,
        schoolYear: schoolYear,
      );

      final finalGrades = <String, double>{};

      subjectGrades.forEach((subjectId, quarterGrades) {
        if (quarterGrades.isNotEmpty) {
          final sum = quarterGrades.values.reduce((a, b) => a + b);
          final average = sum / quarterGrades.length;
          finalGrades[subjectId] = average;
        }
      });

      return finalGrades;
    } catch (e) {
      debugPrint('Error calculating subject final grades: $e');
      return {};
    }
  }

  /// Generate report card PDF (same as before but with new data structure)
  static Future<String> generateReportCardPdfBase64({
    required String studentName,
    required String lrn,
    required String gradeLevel,
    required String schoolYear,
    required String birthday,
    required String sex,
    required int age,
    required String quarter,
    required Map<String, double> subjectGrades,
    required double generalAverage,
    required Map<String, String> remarks,
    required String principalName,
    required String teacherName,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              pw.Text('PROGRESS REPORT',
                  style: pw.TextStyle(
                      fontSize: 22, fontWeight: pw.FontWeight.bold),
                  textAlign: pw.TextAlign.center),
              pw.SizedBox(height: 8),
              pw.Align(
                alignment: pw.Alignment.topRight,
                child: pw.Container(
                  padding:
                      const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: pw.BoxDecoration(border: pw.Border.all()),
                  child: pw.Text('SY $schoolYear',
                      style: const pw.TextStyle(fontSize: 12)),
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Container(
                decoration: pw.BoxDecoration(border: pw.Border.all()),
                padding: const pw.EdgeInsets.all(8),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Name: $studentName'),
                    pw.Text('Birthday: $birthday'),
                    pw.Text('Age: $age'),
                    pw.Text('Sex: $sex'),
                    pw.Text(
                        'Grade: ${GradeLevelUtils.getDisplayName(gradeLevel)}'),
                    pw.Text('SY: $schoolYear'),
                    pw.Text('LRN NO.: $lrn'),
                  ],
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text('Report on Learning Progress and Achievement',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(
                    children: [
                      pw.Text('Learning Areas',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text('Quarter',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text('Final',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text('Remarks',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                  ...subjectGrades.entries.map((entry) => pw.TableRow(
                        children: [
                          pw.Text(entry.key),
                          pw.Text(entry.value.toString()),
                          pw.Text(entry.value.toString()),
                          pw.Text(remarks[entry.key] ?? ''),
                        ],
                      )),
                  pw.TableRow(
                    children: [
                      pw.Text('GENERAL AVERAGE:',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text(''),
                      pw.Text(generalAverage.toStringAsFixed(2),
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text(''),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 12),
              pw.Text('Dear Parent:',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text(
                  'This report card shows the ability and progress your child has made in the different learning areas as well as his/her other values. The school welcomes you if you desire to know more about the progress of your child.'),
              pw.SizedBox(height: 24),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    children: [
                      pw.Text(principalName,
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text('School Principal'),
                    ],
                  ),
                  pw.Column(
                    children: [
                      pw.Text(teacherName,
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text('Teacher'),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    final pdfBytes = await pdf.save();
    return base64Encode(pdfBytes);
  }
}
