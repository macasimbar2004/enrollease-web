import 'dart:async';

import 'package:enrollease_web/paginated_table/data_source_stream/balance_acc_source_stream.dart';
import 'package:enrollease_web/paginated_table/source/balance_acc_table_source.dart';
import 'package:enrollease_web/widgets/search_textformfields.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class BalanceAccountsTable extends StatefulWidget {
  final DateTimeRange range;
  final String userId;
  const BalanceAccountsTable(
      {required this.range, required this.userId, super.key});

  @override
  State<BalanceAccountsTable> createState() => _BalanceAccountsTableState();
}

class _BalanceAccountsTableState extends State<BalanceAccountsTable> {
  late ScrollController _horizontalScrollController;
  late StreamController<List<Map<String, dynamic>>> streamController;
  String _searchQuery = '';
  bool loading = false;

  @override
  void initState() {
    super.initState();
    streamController = StreamController<List<Map<String, dynamic>>>.broadcast();
    _horizontalScrollController = ScrollController();
    balanceAccStreamSource(
      context,
      streamController,
      _searchQuery,
      widget.range,
    );
  }

  @override
  void didUpdateWidget(covariant BalanceAccountsTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.range != widget.range) {
      setState(() {
        balanceAccStreamSource(
          context,
          streamController,
          _searchQuery,
          widget.range,
        );
      });
    }
  }

  void _onSearchChanged(String query) {
    if (mounted) {
      setState(() {
        _searchQuery = query;
        balanceAccStreamSource(
          context,
          streamController,
          _searchQuery,
          widget.range,
        );
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
        if (snapshot.connectionState == ConnectionState.waiting ||
            snapshot.data == null && !snapshot.hasError) {
          return const Center(
            child: SpinKitFadingCircle(
              color: Colors.white,
              size: 100.0,
            ),
          );
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
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
                    width: 1200,
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        dataTableTheme: const DataTableThemeData(
                          columnSpacing: 20,
                          horizontalMargin: 20,
                          headingRowHeight: 56,
                          dataRowMinHeight: 48,
                          dataRowMaxHeight: 75,
                        ),
                      ),
                      child: PaginatedDataTable(
                        header: SearchTextformfields(
                          onSearch: _onSearchChanged,
                        ),
                        source: BalanceAccTableSource(
                          context,
                          data,
                          loading,
                          widget.userId,
                        ),
                        showFirstLastButtons: true,
                        rowsPerPage: 5,
                        columns: _buildDataColumns(),
                      ),
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
      'Account ID',
      'Parent Name',
      'Student Name',
      'Grade Level',
      'Pending Balance',
      'Action',
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