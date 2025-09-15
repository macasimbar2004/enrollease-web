import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class UsersTable extends StatefulWidget {
  final TextEditingController? searchController;

  const UsersTable({
    super.key,
    this.searchController,
  });

  @override
  State<UsersTable> createState() => _UsersTableState();
}

class _UsersTableState extends State<UsersTable> {
  late final StreamController<List<Map<String, dynamic>>> _controller;
  List<Map<String, dynamic>> _usersList = [];
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
    _listenToUsersStream();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    _filterUsers(_searchController.text);
  }

  void _filterUsers(String query) {
    if (_usersList.isEmpty) return;

    if (query.trim().isEmpty) {
      _controller.add(_usersList);
      return;
    }

    final filteredList = _usersList.where((user) {
      final String userName = user['userName']?.toString().toLowerCase() ?? '';
      final String email = user['email']?.toString().toLowerCase() ?? '';
      final String role = user['role']?.toString().toLowerCase() ?? '';
      final String contactNumber =
          user['contactNumber']?.toString().toLowerCase() ?? '';

      return userName.contains(query.toLowerCase()) ||
          email.contains(query.toLowerCase()) ||
          role.contains(query.toLowerCase()) ||
          contactNumber.contains(query.toLowerCase());
    }).toList();

    _controller.add(filteredList);
  }

  void _listenToUsersStream() {
    FirebaseFirestore.instance.collection('users').snapshots().listen(
        (snapshot) {
      _loading = false;
      _usersList = snapshot.docs.map((doc) {
        final data = doc.data();
        // Ensure the uid is set correctly
        data['uid'] = doc.id;
        return data;
      }).toList();

      _filterUsers(_searchController.text);
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
                labelText: 'Search Users',
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

              if (data.isEmpty) {
                return const Center(
                  child: Text(
                    'No users found',
                    style: TextStyle(fontSize: 18),
                  ),
                );
              }

              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Scrollbar(
                  controller: _horizontalScrollController,
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    controller: _horizontalScrollController,
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: 1200,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        child: DataTable(
                          columns: _buildDataColumns(),
                          rows: data.map((user) {
                            return DataRow(
                              cells: [
                                DataCell(Text(user['userName'] ?? '')),
                                DataCell(Text(user['email'] ?? '')),
                                DataCell(Text(user['role'] ?? '')),
                                DataCell(Text(user['contactNumber'] ?? '')),
                                DataCell(Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.visibility),
                                      tooltip: 'View User Details',
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text('User Details'),
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                    'Username: ${user['userName'] ?? ''}'),
                                                const SizedBox(height: 8),
                                                Text(
                                                    'Email: ${user['email'] ?? ''}'),
                                                const SizedBox(height: 8),
                                                Text(
                                                    'Role: ${user['role'] ?? ''}'),
                                                const SizedBox(height: 8),
                                                Text(
                                                    'Contact Number: ${user['contactNumber'] ?? ''}'),
                                              ],
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                child: const Text('Close'),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      tooltip: 'Delete User',
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text('Delete User'),
                                            content: Text(
                                                'Are you sure you want to delete ${user['userName'] ?? 'this user'}?'),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                child: const Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed: () async {
                                                  try {
                                                    await FirebaseFirestore
                                                        .instance
                                                        .collection('users')
                                                        .doc(user['uid'])
                                                        .delete();
                                                    if (context.mounted) {
                                                      Navigator.pop(context);
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        const SnackBar(
                                                          content: Text(
                                                              'User deleted successfully'),
                                                          backgroundColor:
                                                              Colors.green,
                                                        ),
                                                      );
                                                    }
                                                  } catch (e) {
                                                    if (context.mounted) {
                                                      Navigator.pop(context);
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                              'Error deleting user: $e'),
                                                          backgroundColor:
                                                              Colors.red,
                                                        ),
                                                      );
                                                    }
                                                  }
                                                },
                                                child: const Text('Delete'),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                )),
                              ],
                            );
                          }).toList(),
                          columnSpacing: 20,
                          headingRowHeight: 40,
                          dataRowMinHeight: 48,
                          dataRowMaxHeight: 60,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  List<DataColumn> _buildDataColumns() {
    const headers = [
      'Username',
      'Email',
      'Role',
      'Contact Number',
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
