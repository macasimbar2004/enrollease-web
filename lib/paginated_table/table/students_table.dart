import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../source/students_table_source.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class StudentsTable extends StatefulWidget {
  final String userId;
  final TextEditingController? searchController;

  const StudentsTable({
    super.key,
    required this.userId,
    this.searchController,
  });

  @override
  State<StudentsTable> createState() => _StudentsTableState();
}

class _StudentsTableState extends State<StudentsTable> {
  late final StreamController<List<Map<String, dynamic>>> _controller;
  List<Map<String, dynamic>> _studentsList = [];
  bool _loading = true;
  late final TextEditingController _searchController;
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller = StreamController<List<Map<String, dynamic>>>();
    _searchController =
        widget.searchController ?? TextEditingController();
    _listenToStudentStream();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    _filterStudents(_searchController.text);
  }

  void _filterStudents(String query) {
    if (_studentsList.isEmpty) return;

    if (query.trim().isEmpty) {
      _controller.add(_studentsList);
      return;
    }

    final filteredList = _studentsList.where((student) {
      final String fullName =
          student['fullName']?.toString().toLowerCase() ?? '';
      final String id = student['id']?.toString().toLowerCase() ?? '';
      final String grade = student['grade']?.toString().toLowerCase() ?? '';
      return fullName.contains(query.toLowerCase()) ||
          id.contains(query.toLowerCase()) ||
          grade.contains(query.toLowerCase());
    }).toList();

    _controller.add(filteredList);
  }

  void _listenToStudentStream() {
    FirebaseFirestore.instance.collection('students').snapshots().listen(
        (snapshot) {
      _loading = false;
      _studentsList = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        data['fullName'] =
            '${data['lastName'] ?? ''}, ${data['firstName'] ?? ''} ${data['middleName'] ?? ''}';
        return data;
      }).toList();

      _filterStudents(_searchController.text);
    }, onError: (error) {
      _loading = false;
      _controller.addError(error);
    });
  }

  @override
  void dispose() {
    _controller.close();
    // Only dispose if we created the controller internally
    if (widget.searchController == null) {
      _searchController.dispose();
    }
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Only show search field if no external search controller is provided
        if (widget.searchController == null)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Students',
                prefixIcon: const FaIcon(FontAwesomeIcons.magnifyingGlass),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
        Expanded(
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: _controller.stream,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (_loading) {
                return const Center(child: CircularProgressIndicator());
              }

              final data = snapshot.data ?? [];

              return LayoutBuilder(
                builder: (context, constraints) {
                  return Scrollbar(
                    controller: _horizontalScrollController,
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      controller: _horizontalScrollController,
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth: constraints.maxWidth,
                        ),
                        child: SizedBox(
                          width: 1200,
                          height: constraints.maxHeight,
                          child: Theme(
                            data: Theme.of(context).copyWith(
                              scrollbarTheme: ScrollbarThemeData(
                                thumbVisibility: WidgetStateProperty.all(true),
                              ),
                            ),
                            child: PaginatedDataTable(
                              controller: _verticalScrollController,
                              source: StudentsTableSource(
                                  context, data, _loading, widget.userId),
                              columns: _buildDataColumns(),
                              rowsPerPage:
                                  _calculateRowsPerPage(constraints.maxHeight),
                              showCheckboxColumn: false,
                              showFirstLastButtons: true,
                              horizontalMargin: 20,
                              columnSpacing: 20,
                              headingRowHeight: 40,
                              dataRowMinHeight: 48,
                              dataRowMaxHeight: 60,
                              availableRowsPerPage: const [5, 10, 15, 20],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  int _calculateRowsPerPage(double availableHeight) {
    // Reserve space for header, pagination controls, etc.
    const reservedHeight = 150.0;
    const rowHeight = 60.0; // Use the same as dataRowMaxHeight

    // Calculate how many rows can fit
    final availableHeightForRows = availableHeight - reservedHeight;
    final rows = (availableHeightForRows / rowHeight).floor();

    // Return at least 5 rows, at most 20
    return rows.clamp(5, 20);
  }

  List<DataColumn> _buildDataColumns() {
    const headers = [
      'ID',
      'Name',
      'Gender',
      'Age',
      'Address',
      'Contact No',
      'Grade Level',
      'Actions',
    ];

    return headers.map((header) {
      return DataColumn(
        label: Text(
          header,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }).toList();
  }
}
