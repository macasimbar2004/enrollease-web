import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/custom_appbar.dart';
import '../widgets/custom_body.dart';
import '../model/student_model.dart';
import '../model/grade_level_model.dart';
import '../model/student_grade_model.dart';
import '../widgets/responsive_widget.dart';
import '../widgets/student_grade_dialog.dart';
import '../utils/bottom_credits.dart';
import '../utils/theme_colors.dart';
import '../states_management/theme_provider.dart';
import '../utils/grade_service.dart';
import '../utils/efficient_grade_service.dart';
import '../utils/grade_level_utils.dart';
import '../states_management/user_context_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AcademicGradesPage extends StatefulWidget {
  final String? userId;
  final String? userName;
  const AcademicGradesPage({
    super.key,
    this.userId,
    this.userName,
  });

  @override
  State<AcademicGradesPage> createState() => _AcademicGradesPageState();
}

class _AcademicGradesPageState extends State<AcademicGradesPage> {
  String _selectedSchoolYear = SchoolYear.getCurrentSchoolYear();
  GradeLevel _selectedGradeLevel = GradeLevels.kinderI;
  final List<String> _schoolYears = SchoolYear.getRecentSchoolYears(5);
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  // To handle students data and search - use broadcast stream to support multiple listeners
  late final StreamController<List<StudentModel>> _studentsController;
  final List<StudentModel> _allStudents = [];
  String _selectedQuarter = GradingPeriod.firstQuarter;

  @override
  void initState() {
    super.initState();
    // Create a broadcast stream controller to support multiple listeners
    _studentsController = StreamController<List<StudentModel>>.broadcast();
    _searchController.addListener(_onSearchChanged);
    _loadStudents();
  }

  @override
  void didUpdateWidget(AcademicGradesPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // This ensures we update our filters when the widget updates
    _filterStudents(_searchController.text);
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    _searchController.dispose();
    _studentsController.close();
    super.dispose();
  }

  void _onSearchChanged() {
    _filterStudents(_searchController.text);
  }

  void _loadStudents() {
    // Get the current user context to determine grade level access
    final userContext =
        Provider.of<UserContextProvider>(context, listen: false);

    // If user is a teacher, restrict to their assigned grade level
    if (userContext.isTeacher && userContext.userGradeLevel != null) {
      // Standardize the grade level from the database format to our internal format
      final standardizedGradeLevel =
          GradeLevelUtils.standardizeGradeLevel(userContext.userGradeLevel);

      // Find the corresponding GradeLevel object
      _selectedGradeLevel = GradeLevels.allLevels.firstWhere(
        (level) => level.id == standardizedGradeLevel,
        orElse: () => GradeLevels.kinderI,
      );

      // Debug: Print grade level conversion
      print('DEBUG: Teacher grade level conversion:');
      print('  Original from DB: ${userContext.userGradeLevel}');
      print('  Standardized: $standardizedGradeLevel');
      print('  Selected GradeLevel: ${_selectedGradeLevel.displayName}');
    }

    // Load students for the selected grade level
    // Convert to student collection format for the GradeService
    final studentGradeFormat =
        GradeLevelUtils.getStudentCollectionFormat(_selectedGradeLevel.id);
    print('DEBUG: Loading students with grade format: $studentGradeFormat');

    GradeService.getStudentsByGrade(studentGradeFormat).listen((students) {
      setState(() {
        _allStudents.clear();
        _allStudents.addAll(students);
      });
      _filterStudents(_searchController.text);
    });
  }

  void _filterStudents(String query) {
    if (_allStudents.isEmpty) return;

    if (query.trim().isEmpty) {
      _studentsController.add(_allStudents);
      return;
    }

    final filteredList = _allStudents.where((student) {
      final name = '${student.firstName} ${student.lastName}'.toLowerCase();
      final id = student.studentId.toLowerCase();
      return name.contains(query.toLowerCase()) ||
          id.contains(query.toLowerCase());
    }).toList();

    _studentsController.add(filteredList);
  }

  void _onGradeLevelChanged(GradeLevel? newLevel) {
    if (newLevel != null) {
      setState(() {
        _selectedGradeLevel = newLevel;
      });
      _loadStudents();
    }
  }

  void _onQuarterChanged(String? newQuarter) {
    if (newQuarter != null) {
      setState(() {
        _selectedQuarter = newQuarter;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSmallOrMediumScreen = ResponsiveWidget.isMediumScreen(context) ||
        ResponsiveWidget.isLargeScreen(context);

    return Scaffold(
      backgroundColor: Provider.of<ThemeProvider>(context, listen: false)
              .currentColors['background'] ??
          ThemeColors.background(context),
      appBar: CustomAppBar(
        title: 'Academic Grades',
        userId: widget.userId,
        userName: widget.userName,
      ),
      body: CustomBody(
        padding: const EdgeInsets.all(20),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Animate(
                  effects: [
                    FadeEffect(duration: 600.ms),
                    const SlideEffect(begin: Offset(0, 0.2), end: Offset.zero),
                  ],
                  child: _buildHeaderSection(),
                ),
                const SizedBox(height: 30),
                Animate(
                  effects: [
                    FadeEffect(delay: 200.ms, duration: 600.ms),
                    const SlideEffect(begin: Offset(0, 0.2), end: Offset.zero),
                  ],
                  child: _buildGradeReport(),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: isSmallOrMediumScreen
          ? bottomCredits(context)
          : const SizedBox.shrink(),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (Provider.of<ThemeProvider>(context, listen: false)
                              .currentColors['content'] ??
                          ThemeColors.content(context))
                      .withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const FaIcon(
                  FontAwesomeIcons.graduationCap,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Academic Grades Management',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manage and track student academic performance',
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSelectors(),
        ],
      ),
    );
  }

  Widget _buildSelectors() {
    return Consumer<UserContextProvider>(
      builder: (context, userContext, _) {
        return Row(
          children: [
            Expanded(
              flex: 1,
              child: _buildSchoolYearSelector(),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 1,
              child: _buildGradeLevelSelector(userContext),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 1,
              child: _buildQuarterSelector(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSchoolYearSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'School Year',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonFormField<String>(
            value: _selectedSchoolYear,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
            ),
            items: _schoolYears.map((year) {
              return DropdownMenuItem<String>(
                value: year,
                child: Text(
                  year,
                  style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontSize: 14,
                  ),
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedSchoolYear = value;
                });
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGradeLevelSelector(UserContextProvider userContext) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Grade Level',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonFormField<GradeLevel>(
            value: _selectedGradeLevel,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
            ),
            items: GradeLevelUtils.getAllSchoolGradeLevels().map((level) {
              return DropdownMenuItem<GradeLevel>(
                value: level,
                child: Text(
                  level.displayName,
                  style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontSize: 14,
                  ),
                ),
              );
            }).toList(),
            onChanged: userContext.isTeacher ? null : _onGradeLevelChanged,
          ),
        ),
        if (userContext.isTeacher)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Restricted to your assigned grade level',
              style: GoogleFonts.poppins(
                color: Colors.white70,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildQuarterSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quarter',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonFormField<String>(
            value: _selectedQuarter,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
            ),
            items: GradingPeriod.quarters.map((quarter) {
              return DropdownMenuItem<String>(
                value: quarter,
                child: Text(
                  quarter,
                  style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontSize: 14,
                  ),
                ),
              );
            }).toList(),
            onChanged: _onQuarterChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildGradeReport() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const FaIcon(
                  FontAwesomeIcons.table,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Grade Report',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSearchBar(),
          const SizedBox(height: 20),
          _buildGradeTable(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search students...',
          hintStyle: GoogleFonts.poppins(
            color: Colors.grey[600],
            fontSize: 14,
          ),
          prefixIcon: Container(
            padding: const EdgeInsets.all(12),
            child: const FaIcon(
              FontAwesomeIcons.magnifyingGlass,
              color: Colors.grey,
              size: 16,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        style: GoogleFonts.poppins(
          color: Colors.black,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildGradeTable() {
    return StreamBuilder<List<StudentModel>>(
      stream: _studentsController.stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: 400,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Container(
            height: 400,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.red.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading students',
                    style: GoogleFonts.poppins(
                      color: Colors.red.shade400,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        final students = snapshot.data ?? [];

        if (students.isEmpty) {
          return Container(
            height: 400,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.school_outlined,
                    size: 48,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No students found',
                    style: GoogleFonts.poppins(
                      color: Colors.grey.shade400,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No students are enrolled in ${_selectedGradeLevel.displayName}',
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              controller: _horizontalScrollController,
              child: SingleChildScrollView(
                controller: _verticalScrollController,
                child: DataTable(
                  columnSpacing: 12,
                  horizontalMargin: 8,
                  headingRowColor: WidgetStateProperty.all(
                    const Color.fromRGBO(111, 135, 108, 1),
                  ),
                  headingRowHeight: 50,
                  dataRowMinHeight: 50,
                  dataRowMaxHeight: 60,
                  columns: [
                    DataColumn(
                      label: SizedBox(
                        width: 120,
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Icon(
                                Icons.badge,
                                color: Colors.white,
                                size: 14,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'Student ID',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    DataColumn(
                      label: SizedBox(
                        width: 150,
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 14,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'Student Name',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    ...Subjects.allSubjects.map((subject) => DataColumn(
                          label: SizedBox(
                            width: 80,
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  child: const Icon(
                                    Icons.school,
                                    color: Colors.white,
                                    size: 12,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    subject.displayName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontSize: 10,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )),
                    DataColumn(
                      label: SizedBox(
                        width: 90,
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Icon(
                                Icons.analytics,
                                color: Colors.white,
                                size: 14,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'Average',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    DataColumn(
                      label: SizedBox(
                        width: 120,
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Icon(
                                Icons.settings,
                                color: Colors.white,
                                size: 14,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'Actions',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  rows: students.map((student) {
                    return DataRow(
                      color: WidgetStateProperty.resolveWith<Color?>(
                        (Set<WidgetState> states) {
                          if (states.contains(WidgetState.hovered)) {
                            return const Color.fromRGBO(111, 135, 108, 1)
                                .withValues(alpha: 0.1);
                          }
                          return null;
                        },
                      ),
                      cells: [
                        DataCell(
                          Container(
                            width: 120,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color.fromRGBO(111, 135, 108, 1)
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: const Color.fromRGBO(111, 135, 108, 1)
                                    .withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              student.studentId,
                              style: const TextStyle(
                                color: Color.fromRGBO(41, 59, 39, 1),
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        DataCell(
                          Container(
                            width: 150,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 6),
                            child: Text(
                              student.fullName,
                              style: const TextStyle(
                                color: Color.fromRGBO(41, 59, 39, 1),
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        ...Subjects.allSubjects.map((subject) => DataCell(
                              FutureBuilder<Map<String, dynamic>?>(
                                future: EfficientGradeService.getQuarterGrades(
                                  studentId: student.id,
                                  schoolYear: _selectedSchoolYear,
                                  quarter: _selectedQuarter,
                                ),
                                builder: (context, gradeSnapshot) {
                                  if (gradeSnapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    );
                                  }

                                  final subjectGrades =
                                      gradeSnapshot.data?['subjectGrades']
                                          as Map<String, dynamic>?;
                                  final grade =
                                      subjectGrades?[subject.id] as double?;
                                  final gradeStatus =
                                      GradeService.getGradeStatus(grade);

                                  return GestureDetector(
                                    onTap: () => _openGradeDialog(student),
                                    child: Container(
                                      width: 80,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: grade != null
                                            ? gradeStatus['color']
                                                .withValues(alpha: 0.15)
                                            : Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: grade != null
                                              ? gradeStatus['color']
                                              : Colors.grey.shade300,
                                          width: 1,
                                        ),
                                        boxShadow: grade != null
                                            ? [
                                                BoxShadow(
                                                  color: gradeStatus['color']
                                                      .withValues(alpha: 0.2),
                                                  blurRadius: 2,
                                                  offset: const Offset(0, 1),
                                                ),
                                              ]
                                            : null,
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          if (grade != null) ...[
                                            Icon(
                                              grade >= 75
                                                  ? Icons.check_circle
                                                  : Icons.warning,
                                              color: gradeStatus['color'],
                                              size: 12,
                                            ),
                                            const SizedBox(width: 2),
                                          ],
                                          Text(
                                            grade != null
                                                ? grade.toStringAsFixed(1)
                                                : '--',
                                            style: TextStyle(
                                              color: grade != null
                                                  ? gradeStatus['color']
                                                  : Colors.grey.shade600,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 11,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            )),
                        DataCell(
                          FutureBuilder<Map<String, dynamic>?>(
                            future:
                                EfficientGradeService.getAllGradesForStudent(
                              studentId: student.id,
                              schoolYear: _selectedSchoolYear,
                            ),
                            builder: (context, gradesSnapshot) {
                              if (gradesSnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                );
                              }

                              final finalGrade = gradesSnapshot
                                      .data?['finalGrade'] as double? ??
                                  0.0;
                              final gradeStatus =
                                  GradeService.getGradeStatus(finalGrade);

                              return Container(
                                width: 90,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 6),
                                decoration: BoxDecoration(
                                  color: gradeStatus['color']
                                      .withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: gradeStatus['color'],
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: gradeStatus['color']
                                          .withValues(alpha: 0.3),
                                      blurRadius: 3,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      finalGrade >= 75
                                          ? Icons.trending_up
                                          : Icons.trending_down,
                                      color: gradeStatus['color'],
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      finalGrade.toStringAsFixed(1),
                                      style: TextStyle(
                                        color: gradeStatus['color'],
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        DataCell(
                          Container(
                            width: 120,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color.fromRGBO(111, 135, 108, 1)
                                      .withValues(alpha: 0.3),
                                  blurRadius: 2,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: ElevatedButton.icon(
                              onPressed: () => _openGradeDialog(student),
                              icon: const Icon(Icons.edit_note, size: 14),
                              label: const Text('Enter'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromRGBO(111, 135, 108, 1),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 6),
                                textStyle: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                elevation: 0,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _openGradeDialog(StudentModel student) {
    showDialog(
      context: context,
      builder: (context) => EnterGradesDialog(
        student: student,
        schoolYear: _selectedSchoolYear,
        gradeLevel: _selectedGradeLevel.id,
      ),
    ).then((_) {
      // Refresh the data after dialog closes
      setState(() {});
    });
  }
}
