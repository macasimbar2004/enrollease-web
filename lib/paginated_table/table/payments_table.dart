import 'dart:async';

import 'package:enrollease_web/paginated_table/data_source_stream/payments_source_stream.dart';
import 'package:enrollease_web/paginated_table/source/payments_table_source.dart';

import 'package:enrollease_web/utils/theme_colors.dart';
import 'package:enrollease_web/widgets/search_textformfields.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class PaymentsTable extends StatefulWidget {
  final String userId;
  final String balanceAccID;
  const PaymentsTable(
      {required this.userId, required this.balanceAccID, super.key});

  @override
  State<PaymentsTable> createState() => _PaymentsTableState();
}

class _PaymentsTableState extends State<PaymentsTable> {
  late ScrollController _horizontalScrollController;
  late StreamController<List<Map<String, dynamic>>> streamController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    streamController = StreamController<List<Map<String, dynamic>>>.broadcast();
    _horizontalScrollController = ScrollController();
    paymentsStreamDataSource(
        context, streamController, _searchQuery, widget.balanceAccID);
  }

  void _onSearchChanged(String query) {
    if (mounted) {
      setState(() {
        _searchQuery = query;
        paymentsStreamDataSource(
            context, streamController, _searchQuery, widget.balanceAccID);
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
          return Text('Error: ${snapshot.error}');
        } else {
          final data = snapshot.data ?? [];

          //dPrint('fetched data: $data');

          return SingleChildScrollView(
            child: LayoutBuilder(
              builder: (context, constraints) => Scrollbar(
                controller: _horizontalScrollController,
                thumbVisibility: true,
                trackVisibility: true,
                thickness: 10.0,
                radius: const Radius.circular(8.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  controller: _horizontalScrollController,
                  physics:
                      const ClampingScrollPhysics(), // Enables touch scrolling on mobile
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: constraints.maxWidth,
                    ),
                    child: SizedBox(
                      width: 1000,
                      child: data.isEmpty
                          ? const Center(
                              child: Text(
                                'No payments yet',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 20),
                              ),
                            )
                          : PaginatedDataTable(
                              header: SearchTextformfields(
                                onSearch: _onSearchChanged,
                              ),
                              source: PaymentsTableSource(
                                  context, data, widget.userId),
                              showFirstLastButtons: true,
                              rowsPerPage: 5,
                              dataRowMinHeight: 40,
                              dataRowMaxHeight: 86,
                              columns:
                                  _buildDataColumns(), // Use helper function to build columns
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

  // Helper function to build data columns
  List<DataColumn> _buildDataColumns() {
    const columnLabels = [
      'OR',
      'Date',
      'Total Payment',
      'Actions',
    ]; // Column labels

    // Map column labels to DataColumn widgets with common styles
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
