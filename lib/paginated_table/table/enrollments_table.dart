import 'dart:async';

import 'package:enrollease_web/paginated_table/data_source_stream/enrollments_source_stream.dart';
import 'package:enrollease_web/paginated_table/source/enrollments_source.dart';
import 'package:enrollease_web/utils/colors.dart';
import 'package:enrollease_web/widgets/search_textformfields.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

enum TableEnrollmentStatus {
  any,
  pending,
  approved,
  disapproved,
}

extension TableEnrollmentStatusName on TableEnrollmentStatus {
  String formalName() => '${name[0].toUpperCase()}${name.substring(1)}';
}

class EnrollmentsTable extends StatefulWidget {
  final TableEnrollmentStatus eStatus;
  const EnrollmentsTable(this.eStatus, {super.key});

  @override
  State<EnrollmentsTable> createState() => _PendingApprovalsTableState();
}

class _PendingApprovalsTableState extends State<EnrollmentsTable> {
  late ScrollController _horizontalScrollController;
  late StreamController<List<Map<String, dynamic>>> streamController;
  String _searchQuery = '';
  bool loading = false;
  // TableEnrollmentStatus eStatus = TableEnrollmentStatus.any;

  @override
  void initState() {
    super.initState();
    streamController = StreamController<List<Map<String, dynamic>>>.broadcast();
    _horizontalScrollController = ScrollController();
    enrollmentsSourceStream(context, streamController, _searchQuery, widget.eStatus);
  }

  void _onSearchChanged(String query) {
    if (mounted) {
      setState(() {
        _searchQuery = query;
        enrollmentsSourceStream(context, streamController, _searchQuery, widget.eStatus);
      });
    }
  }

  @override
  void didUpdateWidget(covariant EnrollmentsTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.eStatus != widget.eStatus) {
      setState(() {
        enrollmentsSourceStream(context, streamController, _searchQuery, widget.eStatus);
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

  void toggleLoading(bool newState) => setState(() {
        loading = newState;
      });

  Widget buildPaginatedTable() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: streamController.stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: SpinKitFadingCircle(
              color: CustomColors.contentColor,
              size: 100.0,
            ),
          );
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          final data = snapshot.data ?? [];

          //debugPrint('fetched data: $data');

          return Scrollbar(
            controller: _horizontalScrollController,
            thumbVisibility: true,
            trackVisibility: true,
            thickness: 10.0,
            radius: const Radius.circular(8.0),
            child: SingleChildScrollView(
              controller: _horizontalScrollController,
              physics: const ClampingScrollPhysics(), // Enables touch scrolling on mobile
              child: SizedBox(
                height: 600,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    PaginatedDataTable(
                      header: SearchTextformfields(
                        onSearch: _onSearchChanged,
                      ),
                      source: EnrollmentsTableSource(context, data, loading, toggleLoading),
                      showFirstLastButtons: true,
                      rowsPerPage: 5,
                      dataRowMinHeight: 40,
                      dataRowMaxHeight: 75,
                      columns: _buildDataColumns(), // Use helper function to build columns
                    ),
                    if (loading)
                      Container(
                        color: Colors.black.withOpacity(0.6),
                        child: const Center(
                            child: CircularProgressIndicator(
                          color: Colors.white,
                        )),
                      )
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }

  // Helper function to build data columns
  List<DataColumn> _buildDataColumns() {
    const columnLabels = [
      'REGISTRATION #',
      'STUDENT\'S NAME',
      'GRADE LEVEL',
      'STATUS',
      'ACTION',
    ]; // Column labels

    // Map column labels to DataColumn widgets with common styles
    return columnLabels.map((label) {
      return DataColumn(
        label: Text(
          label,
          style: const TextStyle(color: Colors.black, fontSize: 18),
        ),
      );
    }).toList();
  }
}
