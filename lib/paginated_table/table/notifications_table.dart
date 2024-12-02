import 'dart:async';

import 'package:enrollease_web/paginated_table/data_source_stream/notifications_source_stream.dart';
import 'package:enrollease_web/paginated_table/source/notiifcations_table_source.dart';
import 'package:enrollease_web/utils/colors.dart';
import 'package:enrollease_web/widgets/search_textformfields.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class NotificationsTable extends StatefulWidget {
  const NotificationsTable({super.key});

  @override
  State<NotificationsTable> createState() => _PupilsTableState();
}

class _PupilsTableState extends State<NotificationsTable> {
  late ScrollController _horizontalScrollController;
  late StreamController<List<Map<String, dynamic>>> streamController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    streamController = StreamController<List<Map<String, dynamic>>>.broadcast();
    _horizontalScrollController = ScrollController();
    notificationsStreamSource(context, streamController, _searchQuery);
  }

  void _onSearchChanged(String query) {
    if (mounted) {
      setState(() {
        _searchQuery = query;
        notificationsStreamSource(context, streamController, _searchQuery);
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
          return const Center(
            child: SpinKitFadingCircle(
              color: CustomColors.bottomNavColor,
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
                    height: data.isEmpty ? 100 : null,
                    child: data.isEmpty
                        ? const Center(
                            child: Text(
                              'No notifications found.',
                              style: TextStyle(color: Colors.white, fontSize: 18),
                            ),
                          )
                        : PaginatedDataTable(
                            header: SearchTextformfields(
                              onSearch: _onSearchChanged,
                            ),
                            source: NotifcationsTableSource(context, data),
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
      'Title',
      'Message',
      'Date',
      // 'Action',
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