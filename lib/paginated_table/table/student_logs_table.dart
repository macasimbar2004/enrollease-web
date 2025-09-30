import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:enrollease_web/paginated_table/data_source_stream/student_logs_source_stream.dart';
import 'package:enrollease_web/paginated_table/source/student_logs_table_source.dart';

import 'package:enrollease_web/utils/theme_colors.dart';
import 'package:enrollease_web/widgets/search_textformfields.dart';

class StudentLogsTable extends StatefulWidget {
  final String? userId;
  final String? userName;

  const StudentLogsTable({super.key, this.userId, this.userName});

  @override
  State<StudentLogsTable> createState() => _StudentLogsTableState();
}

class _StudentLogsTableState extends State<StudentLogsTable> {
  late ScrollController _horizontalScrollController;
  late StreamController<List<Map<String, dynamic>>> streamController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    streamController = StreamController<List<Map<String, dynamic>>>.broadcast();
    _horizontalScrollController = ScrollController();
    studentLogsStreamSource(context, streamController, _searchQuery);
  }

  void _onSearchChanged(String query) {
    if (mounted) {
      setState(() {
        _searchQuery = query;
        studentLogsStreamSource(context, streamController, _searchQuery);
      });
    }
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    streamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return buildPaginatedTable();
  }

  Widget buildPaginatedTable() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: streamController.stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: SpinKitFadingCircle(
              color: ThemeColors.content(context),
              size: 100.0,
            ),
          );
        } else if (snapshot.hasError) {
          return Text('Error: \\${snapshot.error}');
        } else {
          final data = snapshot.data ?? [];

          return LayoutBuilder(
            builder: (context, constraints) => Scrollbar(
              controller: _horizontalScrollController,
              thumbVisibility: true,
              trackVisibility: true,
              thickness: 10.0,
              radius: const Radius.circular(8.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                controller: _horizontalScrollController,
                physics: const ClampingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: constraints.maxWidth,
                  ),
                  child: SizedBox(
                    width: 1000,
                    height: data.isEmpty ? 100 : null,
                    child: data.isEmpty
                        ? const Center(
                            child: Text(
                              'No student logs found.',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : PaginatedDataTable(
                            header: SearchTextformfields(
                              onSearch: _onSearchChanged,
                            ),
                            source: StudentLogsTableSource(context, data),
                            showFirstLastButtons: true,
                            rowsPerPage: 5,
                            dataRowMinHeight: 40,
                            dataRowMaxHeight: 75,
                            columns: _buildDataColumns(),
                          ),
                  ),
                ),
              ),
            ),
          );
        }
      },
    );
  }

  List<DataColumn> _buildDataColumns() {
    const columnLabels = [
      'Content',
      'Timestamp',
      'Type',
    ];

    return columnLabels.map((label) {
      return DataColumn(
        label: Text(
          label,
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
