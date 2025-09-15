import 'package:flutter/material.dart';
import '../model/student_model.dart';
import '../model/student_grade_model.dart';
import '../model/grade_level_model.dart';
import '../utils/grade_service.dart';
import '../utils/efficient_grade_service.dart';

/// Dialog for entering student grades
class EnterGradesDialog extends StatefulWidget {
  final StudentModel student;
  final String schoolYear;
  final String gradeLevel;

  const EnterGradesDialog({
    super.key,
    required this.student,
    required this.schoolYear,
    required this.gradeLevel,
  });

  @override
  State<EnterGradesDialog> createState() => _EnterGradesDialogState();
}

class _EnterGradesDialogState extends State<EnterGradesDialog> {
  final Map<String, TextEditingController> _controllers = {};
  String _selectedQuarter = GradingPeriod.firstQuarter;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadExistingGrades();
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadExistingGrades() async {
    setState(() => _isLoading = true);

    try {
      final gradesData = await EfficientGradeService.getQuarterGrades(
        studentId: widget.student.id,
        schoolYear: widget.schoolYear,
        quarter: _selectedQuarter,
      );

      if (gradesData != null && gradesData['subjectGrades'] != null) {
        final subjectGrades =
            gradesData['subjectGrades'] as Map<String, dynamic>;

        for (var subject in Subjects.allSubjects) {
          final controller = TextEditingController();

          if (subjectGrades.containsKey(subject.id)) {
            controller.text = subjectGrades[subject.id].toString();
          }

          _controllers[subject.id] = controller;
        }
      } else {
        // Initialize empty controllers for all subjects
        for (var subject in Subjects.allSubjects) {
          _controllers[subject.id] = TextEditingController();
        }
      }
    } catch (e) {
      setState(() => _errorMessage = 'Failed to load existing grades: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveGrades() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final gradesMap = <String, double>{};

      // Convert text values to doubles
      for (var entry in _controllers.entries) {
        final value = entry.value.text.trim();
        if (value.isNotEmpty) {
          final grade = double.tryParse(value);
          if (grade != null) {
            gradesMap[entry.key] = grade;
          }
        }
      }

      // Calculate average grade across subjects
      double totalGrade = 0;
      int count = 0;

      gradesMap.forEach((_, grade) {
        totalGrade += grade;
        count++;
      });

      final averageGrade = count > 0 ? totalGrade / count : 0;

      // Generate report card PDF as base64
      final reportBase64 =
          await EfficientGradeService.generateReportCardPdfBase64(
        studentName: widget.student.fullName,
        lrn: widget.student.lrn,
        gradeLevel: widget.gradeLevel,
        schoolYear: widget.schoolYear,
        birthday: widget.student.dateOfBirth,
        sex: widget.student.gender.toString(),
        age: int.tryParse(widget.student.age.toString()) ?? 0,
        quarter: _selectedQuarter,
        subjectGrades: gradesMap,
        generalAverage: averageGrade.toDouble(),
        remarks: {}, // You may want to pass actual remarks if available
        principalName: 'KIICHE P. NIETES, EdD',
        teacherName: 'Bryline Jane C. Batien',
      );

      // Use the efficient grade service to save grades
      final success = await EfficientGradeService.saveQuarterGrades(
        studentId: widget.student.id,
        studentName: widget.student.fullName,
        gradeLevel: widget.gradeLevel,
        schoolYear: widget.schoolYear,
        quarter: _selectedQuarter,
        subjectGrades: gradesMap,
        reportBase64: reportBase64,
      );

      if (success) {
        Navigator.of(context).pop(true); // Return success
      } else {
        setState(() => _errorMessage = 'Failed to save grades');
      }
    } catch (e) {
      setState(() => _errorMessage = 'Failed to save grades: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Color.fromRGBO(111, 135, 108, 1),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.grade,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Enter Grades',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${widget.student.firstName} ${widget.student.lastName}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: _isLoading
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color.fromRGBO(111, 135, 108, 1),
                            ),
                          ),
                          SizedBox(height: 16),
                          Text('Loading grades...'),
                        ],
                      ),
                    )
                  : Form(
                      key: _formKey,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_errorMessage != null)
                              Container(
                                padding: const EdgeInsets.all(12),
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  border:
                                      Border.all(color: Colors.red.shade200),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.error_outline,
                                        color: Colors.red.shade600, size: 20),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _errorMessage!,
                                        style: TextStyle(
                                            color: Colors.red.shade700),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            // Quarter Selection
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color.fromRGBO(111, 135, 108, 1)
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color.fromRGBO(111, 135, 108, 1)
                                      .withValues(alpha: 0.3),
                                ),
                              ),
                              child: DropdownButtonFormField<String>(
                                value: _selectedQuarter,
                                decoration: const InputDecoration(
                                  labelText: 'Select Quarter',
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                dropdownColor: Colors.white,
                                items: GradingPeriod.quarters.map((quarter) {
                                  return DropdownMenuItem<String>(
                                    value: quarter,
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: const Color.fromRGBO(
                                                111, 135, 108, 1),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          _getQuarterDisplayName(quarter),
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  if (value != null &&
                                      value != _selectedQuarter) {
                                    setState(() {
                                      _selectedQuarter = value;
                                      _loadExistingGrades();
                                    });
                                  }
                                },
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Subject Grades
                            const Text(
                              'Subject Grades',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color.fromRGBO(41, 59, 39, 1),
                              ),
                            ),
                            const SizedBox(height: 16),

                            ...Subjects.allSubjects.map((subject) => Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  child: TextFormField(
                                    controller: _controllers[subject.id],
                                    decoration: InputDecoration(
                                      labelText: subject.displayName,
                                      hintText: 'Enter grade (0-100)',
                                      prefixIcon: Container(
                                        margin: const EdgeInsets.all(8),
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: const Color.fromRGBO(
                                                  111, 135, 108, 1)
                                              .withValues(alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                          Icons.school,
                                          color: const Color.fromRGBO(
                                              111, 135, 108, 1),
                                          size: 20,
                                        ),
                                      ),
                                      suffixText: '%',
                                      suffixStyle: const TextStyle(
                                        color: Color.fromRGBO(111, 135, 108, 1),
                                        fontWeight: FontWeight.bold,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: const Color.fromRGBO(
                                                  111, 135, 108, 1)
                                              .withValues(alpha: 0.3),
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: const Color.fromRGBO(
                                                  111, 135, 108, 1)
                                              .withValues(alpha: 0.3),
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                          color:
                                              Color.fromRGBO(111, 135, 108, 1),
                                          width: 2,
                                        ),
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey.shade50,
                                    ),
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                            decimal: true),
                                    validator: (value) {
                                      if (value != null && value.isNotEmpty) {
                                        final grade = double.tryParse(value);
                                        if (grade == null) {
                                          return 'Please enter a valid number';
                                        }
                                        if (grade < 0 || grade > 100) {
                                          return 'Grade must be between 0 and 100';
                                        }
                                      }
                                      return null;
                                    },
                                    onChanged: (value) {
                                      if (value.isNotEmpty) {
                                        final numValue = double.tryParse(value);
                                        if (numValue != null) {
                                          if (numValue > 100) {
                                            _controllers[subject.id]!.text =
                                                '100';
                                            _controllers[subject.id]!
                                                    .selection =
                                                TextSelection.fromPosition(
                                              TextPosition(
                                                  offset:
                                                      _controllers[subject.id]!
                                                          .text
                                                          .length),
                                            );
                                          } else if (numValue < 0) {
                                            _controllers[subject.id]!.text =
                                                '0';
                                            _controllers[subject.id]!
                                                    .selection =
                                                TextSelection.fromPosition(
                                              TextPosition(
                                                  offset:
                                                      _controllers[subject.id]!
                                                          .text
                                                          .length),
                                            );
                                          }
                                        }
                                      }
                                    },
                                  ),
                                )),
                          ],
                        ),
                      ),
                    ),
            ),

            // Actions
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed:
                        _isLoading ? null : () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _saveGrades,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(111, 135, 108, 1),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 2,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.save, size: 18),
                              SizedBox(width: 8),
                              Text(
                                'Save Grades',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getQuarterDisplayName(String quarter) {
    switch (quarter) {
      case 'Q1':
        return 'First Quarter';
      case 'Q2':
        return 'Second Quarter';
      case 'Q3':
        return 'Third Quarter';
      case 'Q4':
        return 'Fourth Quarter';
      default:
        return quarter;
    }
  }
}

/// Dialog for viewing student grades report
class ViewGradeReportDialog extends StatelessWidget {
  final StudentModel student;
  final String schoolYear;
  final String gradeLevel;

  const ViewGradeReportDialog({
    super.key,
    required this.student,
    required this.schoolYear,
    required this.gradeLevel,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 8,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade700,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.assessment, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Grade Report - ${student.firstName} ${student.lastName}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _buildReportContent(context),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'School Year: $schoolYear',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Grade Level: ${_getGradeLevelDisplayName()}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Implement printing functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Printing will be implemented soon'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.print),
                    label: const Text('Print Report'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getGradeLevelDisplayName() {
    // Try to find the grade level display name
    final gradeLevel = GradeLevels.getLevelById(this.gradeLevel);
    return gradeLevel?.displayName ?? this.gradeLevel;
  }

  Widget _buildReportContent(BuildContext context) {
    return FutureBuilder<Map<String, Map<String, double>>>(
      future: EfficientGradeService.getAllSubjectGrades(
        studentId: student.id,
        schoolYear: schoolYear,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error loading grades: ${snapshot.error}'),
              ],
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.info_outline, size: 48, color: Colors.blue),
                SizedBox(height: 16),
                Text('No grades available for this student.'),
              ],
            ),
          );
        }

        // Get all subject grades
        final subjectGrades = snapshot.data!;

        return FutureBuilder<Map<String, double>>(
          future: EfficientGradeService.calculateSubjectFinalGrades(
            studentId: student.id,
            schoolYear: schoolYear,
          ),
          builder: (context, finalGradesSnapshot) {
            if (finalGradesSnapshot.connectionState ==
                ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final finalSubjectGrades = finalGradesSnapshot.data ?? {};

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Student Information',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const Divider(),
                          _buildInfoRow('Student ID', student.studentId),
                          _buildInfoRow('Name',
                              '${student.lastName}, ${student.firstName}'),
                          _buildInfoRow('Gender', student.gender),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Grade Summary',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const Divider(),
                          const SizedBox(height: 8),
                          _buildGradesTable(
                              context, subjectGrades, finalSubjectGrades),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildFinalAverageSection(context, finalSubjectGrades),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value.isNotEmpty ? value : 'Not specified'),
          ),
        ],
      ),
    );
  }

  Widget _buildGradesTable(
      BuildContext context,
      Map<String, Map<String, double>> subjectGrades,
      Map<String, double> finalSubjectGrades) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 20,
        headingRowHeight: 48,
        dataRowMaxHeight: 64,
        headingRowColor: WidgetStateProperty.all(Colors.grey.shade200),
        columns: [
          const DataColumn(
            label: Text(
              'Subject',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          ...GradingPeriod.quarters.map(
            (quarter) => DataColumn(
              label: Text(
                _getQuarterDisplayName(quarter),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const DataColumn(
            label: Text(
              'Final',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
        rows: Subjects.allSubjects.map((subject) {
          // Get grades for this subject
          final subjectQuarterGrades = subjectGrades[subject.id] ?? {};
          final finalGrade = finalSubjectGrades[subject.id] ?? 0.0;

          // Build row cells
          return DataRow(
            cells: [
              DataCell(Text(subject.displayName)),
              ...GradingPeriod.quarters.map((quarter) {
                final gradeValue = subjectQuarterGrades[quarter] ?? 0.0;
                final gradeStatus = GradeService.getGradeStatus(gradeValue);

                return DataCell(
                  gradeValue > 0
                      ? Tooltip(
                          message: gradeStatus['status'],
                          child: Text(
                            gradeValue.toStringAsFixed(1),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: gradeStatus['color'],
                            ),
                          ),
                        )
                      : const Text('--'),
                );
              }),
              DataCell(
                finalGrade > 0
                    ? Tooltip(
                        message:
                            GradeService.getGradeStatus(finalGrade)['status'],
                        child: Text(
                          finalGrade.toStringAsFixed(1),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: GradeService.getGradeColor(finalGrade),
                          ),
                        ),
                      )
                    : const Text('--'),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFinalAverageSection(
      BuildContext context, Map<String, double> finalSubjectGrades) {
    if (finalSubjectGrades.isEmpty) {
      return const SizedBox.shrink();
    }

    // Calculate overall average
    double totalSum = 0;
    int count = 0;

    finalSubjectGrades.forEach((subject, grade) {
      if (grade > 0) {
        totalSum += grade;
        count++;
      }
    });

    final overallAverage = count > 0 ? totalSum / count : 0.0;
    final formattedAverage =
        count > 0 ? overallAverage.toStringAsFixed(2) : 'No grades available';
    final gradeStatus = GradeService.getGradeStatus(overallAverage);

    return Card(
      elevation: 4,
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Expanded(
              child: Text(
                'Overall Average:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade200,
                    blurRadius: 2,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    formattedAverage,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: gradeStatus['color'],
                    ),
                  ),
                  if (count > 0)
                    Text(
                      gradeStatus['status'],
                      style: TextStyle(
                        fontSize: 12,
                        color: gradeStatus['color'],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getQuarterDisplayName(String quarter) {
    switch (quarter) {
      case 'Q1':
        return '1st Quarter';
      case 'Q2':
        return '2nd Quarter';
      case 'Q3':
        return '3rd Quarter';
      case 'Q4':
        return '4th Quarter';
      default:
        return quarter;
    }
  }
}
