import 'package:enrollease_web/paginated_table/source/new_users_table_source.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class NewUsersTable extends StatefulWidget {
  const NewUsersTable({super.key});

  @override
  State<NewUsersTable> createState() => _NewUsersTableState();
}

class _NewUsersTableState extends State<NewUsersTable> {
  Map<String, dynamic> threshold = {};
  String redQuantity = '';
  String orangeQuantity = '';
  late ScrollController _horizontalScrollController;
  bool _isLoading = true;
  List<Map<String, dynamic>> _data = [];

  @override
  void initState() {
    super.initState();
    _horizontalScrollController = ScrollController();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _data = [
        {
          'name': 'LEONOR B. ENRIQUEZ',
          'user id': '212212',
          'status': 'ACTIVE',
          'role': 'PARENT'
        },
        {
          'name': 'LISA MONTINOLA',
          'user id': '3524558',
          'status': 'ACTIVE',
          'role': 'GUARDIAN'
        },
        {
          'name': 'RICHARD YAP',
          'user id': '8788945',
          'status': 'ACTIVE',
          'role': 'PARENT'
        },
      ];
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        buildPaginatedTable(),
      ],
    );
  }

  Widget buildPaginatedTable() {
    return _isLoading
        ? const Center(
            child: SpinKitFadingCircle(
              color: Colors.blue,
              size: 34.0,
            ),
          )
        : LayoutBuilder(
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
                    width: 1500,
                    child: PaginatedDataTable(
                      source: NewUsersTableSource(context, _data),
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
          );
  }

  // Helper function to build data columns
  List<DataColumn> _buildDataColumns() {
    const columnLabels = ['NAME', 'USER ID', 'STATUS', 'ROLE']; // Column labels

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