import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:enrollease_web/paginated_table/data_source_stream/registrars_source_stream.dart';
import 'package:enrollease_web/paginated_table/source/registars_table_source.dart';
import 'package:enrollease_web/utils/colors.dart';
import 'package:enrollease_web/widgets/search_textformfields.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class RegistrarsTable extends StatefulWidget {
  final String? userTypeFilter;
  final List<String>? roleFilters;

  const RegistrarsTable({
    super.key,
    this.userTypeFilter,
    this.roleFilters,
  });

  @override
  State<RegistrarsTable> createState() => _RegistrarsTableState();
}

class ProfileImageWidget extends StatelessWidget {
  final String? profilePicData;
  final double size;

  const ProfileImageWidget({
    super.key,
    required this.profilePicData,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    if (profilePicData == null || profilePicData!.isEmpty) {
      return CircleAvatar(
        radius: size / 2,
        backgroundColor: Colors.grey[300],
        child: Icon(
          Icons.person,
          size: size * 0.6,
          color: Colors.grey[600],
        ),
      );
    }

    return CircleAvatar(
      radius: size / 2,
      backgroundImage: MemoryImage(
        Uint8List.fromList(base64Decode(profilePicData!)),
      ),
    );
  }
}

class _RegistrarsTableState extends State<RegistrarsTable> {
  late ScrollController _horizontalScrollController;
  late StreamController<List<Map<String, dynamic>>> streamController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    streamController = StreamController<List<Map<String, dynamic>>>.broadcast();
    _horizontalScrollController = ScrollController();
    registrarsStreamDataSource(
      context,
      streamController,
      _searchQuery,
      widget.userTypeFilter,
      widget.roleFilters,
    );
  }

  @override
  void didUpdateWidget(RegistrarsTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Refresh data when filters change
    if (oldWidget.userTypeFilter != widget.userTypeFilter ||
        oldWidget.roleFilters != widget.roleFilters) {
      registrarsStreamDataSource(
        context,
        streamController,
        _searchQuery,
        widget.userTypeFilter,
        widget.roleFilters,
      );
    }
  }

  void _onSearchChanged(String query) {
    if (mounted) {
      setState(() {
        _searchQuery = query;
        registrarsStreamDataSource(
          context,
          streamController,
          _searchQuery,
          widget.userTypeFilter,
          widget.roleFilters,
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
                    child: PaginatedDataTable(
                      header: SearchTextformfields(
                        onSearch: _onSearchChanged,
                      ),
                      source:
                          RegistarsTableSource(context, data, _buildDataRows),
                      showFirstLastButtons: true,
                      rowsPerPage: 5,
                      dataRowMinHeight: 40,
                      dataRowMaxHeight: 120,
                      columnSpacing: 16,
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

  // Helper function to build data columns
  List<DataColumn> _buildDataColumns() {
    const columnLabels = [
      'Profile',
      'ID Number',
      'Name',
      'Type',
      'Roles',
      'Status',
      'Actions',
    ];

    return columnLabels.map((label) {
      return DataColumn(
        label: Text(
          label,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }).toList();
  }

  // Add this method to build the data rows
  List<DataRow> _buildDataRows(List<Map<String, dynamic>> data) {
    return data.map((item) {
      return DataRow(
        cells: [
          DataCell(
            ProfileImageWidget(
              profilePicData: item['profilePicData'],
              size: 40,
            ),
          ),
          DataCell(
            Container(
              constraints: const BoxConstraints(maxWidth: 120),
              child: Text(
                item['id'] ?? '',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ),
          DataCell(
            Container(
              constraints: const BoxConstraints(maxWidth: 180),
              child: Text(
                item['fullname'] ?? '',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),
          DataCell(
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: (item['userType'] ?? 'Staff') == 'Teacher'
                    ? Colors.blue.withValues(alpha: 0.2)
                    : Colors.green.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: (item['userType'] ?? 'Staff') == 'Teacher'
                      ? Colors.blue
                      : Colors.green,
                ),
              ),
              child: Text(
                item['userType'] ?? 'Staff',
                style: TextStyle(
                  color: (item['userType'] ?? 'Staff') == 'Teacher'
                      ? Colors.blue.shade700
                      : Colors.green.shade700,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          DataCell(
            Container(
              constraints: const BoxConstraints(maxWidth: 150),
              child: _buildRolesDisplay(
                item['roles'] as List<dynamic>?,
                item['userType'] as String?,
                item['gradeLevel'] as String?,
              ),
            ),
          ),
          DataCell(
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor((item['status'] ?? 'active'))
                    .withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getStatusColor((item['status'] ?? 'active')),
                ),
              ),
              child: Text(
                _getStatusText((item['status'] ?? 'active')),
                style: TextStyle(
                  color: _getStatusColor((item['status'] ?? 'active')),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          DataCell(item['actions']),
        ],
      );
    }).toList();
  }

  // Helper method to get status color
  Color _getStatusColor(String status) {
    switch (status) {
      case 'active':
        return Colors.green.shade700;
      case 'disabled':
        return Colors.orange.shade700;
      default:
        return Colors.green.shade700;
    }
  }

  // Helper method to get status text
  String _getStatusText(String status) {
    switch (status) {
      case 'active':
        return 'Active';
      case 'disabled':
        return 'Disabled';
      default:
        return 'Active';
    }
  }

  // Helper method to build roles display with max 3 roles shown
  Widget _buildRolesDisplay(
      List<dynamic>? roles, String? userType, String? gradeLevel) {
    if (roles == null || roles.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Text(
          'Staff',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
      );
    }

    final rolesList = roles.cast<String>();
    final displayedRoles = rolesList.take(3).toList();
    final remainingCount = rolesList.length - 3;
    final allRolesText = rolesList.join(', ');

    return Tooltip(
      message: allRolesText,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Display first 3 roles as tags
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: displayedRoles
                .map((role) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: role == 'Teacher'
                            ? Colors.green.shade50
                            : Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: role == 'Teacher'
                              ? Colors.green.shade200
                              : Colors.blue.shade200,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        role == 'Teacher' ? gradeLevel! : role,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: role == 'Teacher'
                              ? Colors.green.shade700
                              : Colors.blue.shade700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ))
                .toList(),
          ),
          // Show "+X more" if there are additional roles
          if (remainingCount > 0)
            Container(
              margin: const EdgeInsets.only(top: 2),
              padding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '+$remainingCount more',
                style: TextStyle(
                  fontSize: 8,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
