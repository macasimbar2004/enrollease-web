import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../model/student_model.dart';
import '../utils/grade_level_utils.dart';
import 'dart:convert';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Service class to handle all grade-related operations
class GradeService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetches students for a specific grade level
  /// gradeId should be in student collection format (e.g., "g4", "k1", "k2")
  static Stream<List<StudentModel>> getStudentsByGrade(String gradeId) {
    debugPrint('Fetching students for grade: "$gradeId"');

    // Safer approach that handles different formatting of grade values
    return _firestore.collection('students').snapshots().map((snapshot) {
      debugPrint('Query returned ${snapshot.docs.length} total students');

      // Debug: Print all grades found to see what's in the database
      debugPrint('All grades in database:');
      final allGrades = snapshot.docs.map((doc) {
        final data = doc.data();
        return '${doc.id}: ${data['grade']} (${data['grade'].runtimeType})';
      }).join('\n');
      debugPrint(allGrades);

      // Use flexible matching for grade value
      final matchingDocs = snapshot.docs.where((doc) {
        final data = doc.data();
        final grade = data['grade'];

        if (grade == null) {
          debugPrint('Student ${doc.id} has no grade, skipping');
          return false;
        }

        // Use standardized grade level matching
        final normalizedGrade = grade.toString().trim().toLowerCase();
        final normalizedGradeId = gradeId.trim().toLowerCase();

        // Case 1: Direct equality
        final exactMatch = normalizedGrade == normalizedGradeId;
        if (exactMatch) {
          debugPrint(
              'Direct equality match: "$grade" == "$gradeId" for student ${doc.id}');
          return true;
        }

        // Case 2: Convert student grade to standardized format and compare
        final studentStandardizedGrade =
            GradeLevelUtils.fromStudentCollectionFormat(normalizedGrade);
        final targetStandardizedGrade =
            GradeLevelUtils.fromStudentCollectionFormat(normalizedGradeId);

        if (studentStandardizedGrade == targetStandardizedGrade) {
          debugPrint(
              'Standardized format match: "$grade" -> "$studentStandardizedGrade" matches "$gradeId" -> "$targetStandardizedGrade" for student ${doc.id}');
          return true;
        }

        // Case 3: Handle numeric grades (legacy support)
        if (grade is int) {
          // Convert gradeId to numeric value for comparison
          final numericGradeId = gradeId.replaceAll(RegExp(r'[^0-9]'), '');
          if (numericGradeId.isNotEmpty) {
            final parsedGradeId = int.tryParse(numericGradeId);
            if (parsedGradeId != null && parsedGradeId == grade) {
              debugPrint(
                  'Numeric match: int $grade matches extracted "$numericGradeId" from "$gradeId" for student ${doc.id}');
              return true;
            }
          }
        }

        // Case 4: Fallback - contains match for edge cases
        final containsMatch = normalizedGrade.contains(normalizedGradeId) ||
            normalizedGradeId.contains(normalizedGrade);

        if (containsMatch) {
          debugPrint(
              'Contains match: "$grade" with "$gradeId" for student ${doc.id}');
          return true;
        }

        debugPrint(
            'No match for student ${doc.id} with grade "$grade" against "$gradeId"');
        return false;
      }).toList();

      debugPrint(
          'Found ${matchingDocs.length} students matching grade "$gradeId"');

      if (matchingDocs.isEmpty) {
        return <StudentModel>[];
      }

      try {
        // Client-side filtering for active status
        final activeStudentDocs = matchingDocs.where((doc) {
          final data = doc.data();
          final status = data['status'];

          // If status is missing, consider it active by default
          if (status == null) return true;

          // Flexible status matching (case-insensitive)
          return status.toString().trim().toLowerCase() == 'active';
        }).toList();

        debugPrint('Active students count: ${activeStudentDocs.length}');

        // Sort by lastName client-side
        activeStudentDocs.sort((a, b) {
          final aData = a.data();
          final bData = b.data();
          return (aData['lastName'] ?? '')
              .toString()
              .compareTo((bData['lastName'] ?? '').toString());
        });

        final students = activeStudentDocs.map((doc) {
          final data = doc.data();

          // CRITICAL FIX: Ensure the ID in the data matches the document ID
          final docId = doc.id;
          data['id'] = docId; // Override any existing ID with the document ID

          // Check for name fields
          debugPrint('Student data for $docId:');
          debugPrint('  Raw data: $data');

          // Convert any numeric fields that should be strings
          try {
            // Convert ALL potential numeric fields to strings to avoid type errors
            final fieldsToCheck = [
              'grade',
              'age',
              'lrn',
              'ipOrIcc',
              'cellno',
              'timestamp',
              'parentsUserId',
              'fathersOcc',
              'mothersOcc'
            ];

            for (var field in fieldsToCheck) {
              if (data.containsKey(field)) {
                if (data[field] is int || data[field] is double) {
                  data[field] = data[field].toString();
                  debugPrint(
                      '  Converted numeric $field to string: ${data[field]}');
                } else if (data[field] is bool) {
                  data[field] = data[field] ? 'true' : 'false';
                  debugPrint(
                      '  Converted boolean $field to string: ${data[field]}');
                }
              }
            }

            // Handle any other fields that might be present but not in our predefined list
            final numericFields = data.keys.where((key) =>
                data[key] is int || data[key] is double || data[key] is bool);

            for (var field in numericFields) {
              if (!fieldsToCheck.contains(field)) {
                if (data[field] is int || data[field] is double) {
                  data[field] = data[field].toString();
                  debugPrint(
                      '  Converted additional numeric $field to string: ${data[field]}');
                } else if (data[field] is bool) {
                  data[field] = data[field] ? 'true' : 'false';
                  debugPrint(
                      '  Converted additional boolean $field to string: ${data[field]}');
                }
              }
            }

            return StudentModel.fromMap(data);
          } catch (e) {
            debugPrint('Error converting fields for student $docId: $e');
            debugPrint('Problematic data: ${data.toString()}');

            // Create a minimal valid student with the correct ID
            return StudentModel.fromMap({
              'id': docId,
              'firstName': 'ERROR',
              'lastName': 'Loading Error',
              'grade': data['grade']?.toString() ?? ''
            });
          }
        }).toList();

        return students;
      } catch (e) {
        debugPrint('Error mapping student data: $e');
        return <StudentModel>[];
      }
    });
  }

  /// Fetches a student's grade for a specific quarter
  static Future<Map<String, dynamic>?> getQuarterGrade(String studentId,
      String gradeLevel, String schoolYear, String quarter) async {
    try {
      final docId = '${studentId}_${gradeLevel}_${schoolYear}_$quarter';
      debugPrint('Fetching grade for doc: $docId');

      final doc = await _firestore.collection('grades').doc(docId).get();

      if (!doc.exists) {
        return null;
      }

      return doc.data();
    } catch (e) {
      debugPrint('Error fetching quarter grade: $e');
      return null;
    }
  }

  /// Fetches all grades for a student in a school year
  static Future<List<Map<String, dynamic>>> getAllGrades(
      String studentId, String gradeLevel, String schoolYear) async {
    try {
      final querySnapshot = await _firestore
          .collection('grades')
          .where('studentId', isEqualTo: studentId)
          .where('schoolYear', isEqualTo: schoolYear)
          .where('gradeLevel', isEqualTo: gradeLevel)
          .get();

      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      debugPrint('Error fetching all grades: $e');
      return [];
    }
  }

  /// Calculates the final grade based on quarterly grades
  static double calculateFinalGrade(List<Map<String, dynamic>> grades) {
    if (grades.isEmpty) {
      return 0;
    }

    double sum = 0;
    int count = 0;

    // Process each quarter that has actual data
    for (var grade in grades) {
      if (grade['grade'] != null) {
        // Handle different data types for grade
        final gradeValue = grade['grade'] is num
            ? (grade['grade'] as num).toDouble()
            : double.tryParse(grade['grade'].toString()) ?? 0.0;

        sum += gradeValue;
        count++;
      }
    }

    // Calculate average using only quarters that have data
    double average = count > 0 ? sum / count : 0;

    // Round to 2 decimal places
    return double.parse(average.toStringAsFixed(2));
  }

  /// Returns a color based on the grade value
  static Color getGradeColor(dynamic grade) {
    if (grade == null) return Colors.black;

    final numGrade =
        grade is num ? grade.toDouble() : double.tryParse('$grade') ?? 0.0;

    if (numGrade >= 90) return Colors.green.shade700;
    if (numGrade >= 80) return Colors.blue.shade700;
    if (numGrade >= 75) return Colors.orange.shade700;
    return Colors.red.shade700;
  }

  /// Gets the color and status description for a grade value
  static Map<String, dynamic> getGradeStatus(dynamic grade) {
    if (grade == null) {
      return {'color': Colors.black, 'status': 'Not Available'};
    }

    final numGrade =
        grade is num ? grade.toDouble() : double.tryParse('$grade') ?? 0.0;

    if (numGrade >= 90) {
      return {'color': Colors.green.shade700, 'status': 'Outstanding'};
    }
    if (numGrade >= 85) {
      return {'color': Colors.green.shade500, 'status': 'Very Good'};
    }
    if (numGrade >= 80) {
      return {'color': Colors.blue.shade700, 'status': 'Good'};
    }
    if (numGrade >= 75) {
      return {'color': Colors.orange.shade700, 'status': 'Satisfactory'};
    }
    return {'color': Colors.red.shade700, 'status': 'Needs Improvement'};
  }

  /// Calculates the final grade for each subject across all quarters
  static Future<Map<String, double>> calculateSubjectFinalGrades(
      String studentId, String gradeLevel, String schoolYear) async {
    try {
      final allSubjectGrades =
          await getAllSubjectGrades(studentId, gradeLevel, schoolYear);
      final Map<String, double> finalGrades = {};

      // For each subject
      allSubjectGrades.forEach((subject, quarterGrades) {
        if (quarterGrades.isEmpty) {
          finalGrades[subject] = 0.0;
          return;
        }

        double sum = 0.0;
        int count = 0;

        // Sum grades across all quarters
        quarterGrades.forEach((quarter, grade) {
          sum += grade;
          count++;
        });

        // Calculate average and round to 2 decimal places
        final average = count > 0 ? sum / count : 0.0;
        finalGrades[subject] = double.parse(average.toStringAsFixed(2));
      });

      return finalGrades;
    } catch (e) {
      debugPrint('Error calculating subject final grades: $e');
      return {};
    }
  }

  /// Fetches subject grades for a specific quarter
  static Future<Map<String, double>?> getQuarterSubjectGrades(String studentId,
      String gradeLevel, String schoolYear, String quarter) async {
    try {
      final gradeData =
          await getQuarterGrade(studentId, gradeLevel, schoolYear, quarter);

      if (gradeData == null || !gradeData.containsKey('subjectGrades')) {
        return null;
      }

      final Map<String, dynamic> subjectGradesData = gradeData['subjectGrades'];
      final Map<String, double> subjectGrades = {};

      // Convert to strongly typed map
      subjectGradesData.forEach((subject, grade) {
        if (grade != null) {
          // Handle different data types
          final gradeValue = grade is num
              ? grade.toDouble()
              : double.tryParse(grade.toString()) ?? 0.0;

          subjectGrades[subject] = gradeValue;
        }
      });

      return subjectGrades;
    } catch (e) {
      debugPrint('Error fetching subject grades: $e');
      return null;
    }
  }

  /// Gets all subject grades across all quarters for a student
  static Future<Map<String, Map<String, double>>> getAllSubjectGrades(
      String studentId, String gradeLevel, String schoolYear) async {
    try {
      // Structure: { 'subject': { 'Q1': grade, 'Q2': grade, ... } }
      final Map<String, Map<String, double>> allSubjectGrades = {};

      // Get all grades for the student
      final grades = await getAllGrades(studentId, gradeLevel, schoolYear);
      if (grades.isEmpty) {
        return {};
      }

      // Process each quarter's data
      for (var gradeData in grades) {
        final quarter = gradeData['quarter'] as String?;
        if (quarter == null || !gradeData.containsKey('subjectGrades')) {
          continue;
        }

        final Map<String, dynamic> subjectGradesData =
            gradeData['subjectGrades'];

        // For each subject in this quarter
        subjectGradesData.forEach((subject, grade) {
          if (grade != null) {
            // Handle different data types
            final gradeValue = grade is num
                ? grade.toDouble()
                : double.tryParse(grade.toString()) ?? 0.0;

            // Initialize subject map if doesn't exist
            if (!allSubjectGrades.containsKey(subject)) {
              allSubjectGrades[subject] = {};
            }

            // Add grade for this quarter
            allSubjectGrades[subject]![quarter] = gradeValue;
          }
        });
      }

      return allSubjectGrades;
    } catch (e) {
      debugPrint('Error fetching all subject grades: $e');
      return {};
    }
  }

  Future<String> generateReportCardPdfBase64({
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
                    pw.Text('Grade: $gradeLevel'),
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
