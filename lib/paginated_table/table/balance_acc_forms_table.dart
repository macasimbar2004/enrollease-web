import 'dart:async';

import 'package:enrollease_web/paginated_table/data_source_stream/balance_acc_source_stream.dart';
import 'package:enrollease_web/paginated_table/source/balance_acc_table_source.dart';
import 'package:enrollease_web/utils/colors.dart';
import 'package:enrollease_web/widgets/search_textformfields.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class BalanceAccountsTable extends StatefulWidget {
  final DateTimeRange range;
  const BalanceAccountsTable({required this.range, super.key});

  @override
  State<BalanceAccountsTable> createState() => _SOATableState();
}

class _SOATableState extends State<BalanceAccountsTable> {
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
                physics: const ClampingScrollPhysics(), // Enables touch scrolling on mobile
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: constraints.maxWidth,
                  ),
                  child: SizedBox(
                    width: 1000,
                    child: PaginatedDataTable(
                      header: SearchTextformfields(
                        onSearch: _onSearchChanged,
                      ),
                      source: BalanceAccTableSource(context, data, loading),
                      showFirstLastButtons: true,
                      rowsPerPage: 5,
                      dataRowMinHeight: 40,
                      dataRowMaxHeight: 75,
                      columns: _buildDataColumns(), // Use helper function to build columns
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

  // Helper function to build data columns
  List<DataColumn> _buildDataColumns() {
    const columnLabels = [
      'Grade Level #',
      'Parent Name',
      'Pupil Name',
      'Grade Level',
      'Pending balance',
      'Action',
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


// const Center(
//               child: SpinKitFadingCircle(
//                 color: Colors.blue,
//                 size: 34.0,
//               ),
//             )