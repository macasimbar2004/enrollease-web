import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../model/announcement_model.dart';

class AnnouncementsTable extends StatelessWidget {
  const AnnouncementsTable({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('announcements')
          .orderBy('startDate', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final announcements = snapshot.data?.docs.map((doc) {
              return AnnouncementModel.fromMap(
                  doc.id, doc.data() as Map<String, dynamic>);
            }).toList() ??
            [];

        if (announcements.isEmpty) {
          return const Center(
            child: Text(
              'No announcements found',
              style: TextStyle(fontSize: 18),
            ),
          );
        }

        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: constraints.maxWidth,
                  ),
                  child: DataTable(
                    columnSpacing: 20,
                    horizontalMargin: 20,
                    columns: const [
                      DataColumn(
                        label: Text(
                          'Event Name',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                        numeric: false,
                      ),
                      DataColumn(
                        label: Text(
                          'Event Span',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                        numeric: false,
                      ),
                      DataColumn(
                        label: Text(
                          'Time',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                        numeric: false,
                      ),
                      DataColumn(
                        label: Text(
                          'Participants',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                        numeric: false,
                      ),
                      DataColumn(
                        label: Text(
                          'Venue',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                        numeric: false,
                      ),
                      DataColumn(
                        label: Text(
                          'Status',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                        numeric: false,
                      ),
                      DataColumn(
                        label: Text(
                          'Actions',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                        numeric: false,
                      ),
                    ],
                    rows: announcements.map((announcement) {
                      final now = DateTime.now();
                      final status = _getEventStatus(
                          announcement.startDate, announcement.endDate, now);
                      final statusColor = _getStatusColor(status);

                      return DataRow(
                        cells: [
                          DataCell(
                            Text(
                              announcement.eventName,
                              style: const TextStyle(
                                  overflow: TextOverflow.visible),
                            ),
                          ),
                          DataCell(
                            Text(
                              '${announcement.startDate.day}/${announcement.startDate.month}/${announcement.startDate.year} - ${announcement.endDate.day}/${announcement.endDate.month}/${announcement.endDate.year}',
                              style: const TextStyle(
                                  overflow: TextOverflow.visible),
                            ),
                          ),
                          DataCell(
                            Text(
                              announcement.time,
                              style: const TextStyle(
                                  overflow: TextOverflow.visible),
                            ),
                          ),
                          DataCell(
                            Text(
                              announcement.participants.join(', '),
                              style: const TextStyle(
                                  overflow: TextOverflow.visible),
                            ),
                          ),
                          DataCell(
                            Text(
                              announcement.venue,
                              style: const TextStyle(
                                  overflow: TextOverflow.visible),
                            ),
                          ),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: statusColor),
                              ),
                              child: Text(
                                status,
                                style: TextStyle(
                                  color: statusColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.visibility),
                                  tooltip: 'View Details',
                                  onPressed: () {
                                    _showAnnouncementDetails(
                                        context, announcement);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  tooltip: 'Delete Announcement',
                                  onPressed: () async {
                                    final confirmed = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title:
                                            const Text('Delete Announcement'),
                                        content: Text(
                                            'Are you sure you want to delete "${announcement.eventName}"?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, false),
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, true),
                                            child: const Text('Delete'),
                                          ),
                                        ],
                                      ),
                                    );

                                    if (confirmed == true) {
                                      try {
                                        await FirebaseFirestore.instance
                                            .collection('announcements')
                                            .doc(announcement.id)
                                            .delete();
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  'Announcement deleted successfully'),
                                              backgroundColor: Colors.green,
                                            ),
                                          );
                                        }
                                      } catch (e) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  'Error deleting announcement: $e'),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      }
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  String _getEventStatus(DateTime startDate, DateTime endDate, DateTime now) {
    if (now.isBefore(startDate)) {
      return 'Coming';
    } else if (now.isAfter(endDate)) {
      return 'Ended';
    } else {
      return 'On Going';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Coming':
        return Colors.blue;
      case 'On Going':
        return Colors.green;
      case 'Ended':
        return Colors.grey;
      default:
        return Colors.black;
    }
  }

  void _showAnnouncementDetails(
      BuildContext context, AnnouncementModel announcement) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(announcement.eventName),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Description: ${announcement.description}'),
              const SizedBox(height: 8),
              Text(
                  'Start Date: ${announcement.startDate.day}/${announcement.startDate.month}/${announcement.startDate.year}'),
              const SizedBox(height: 8),
              Text(
                  'End Date: ${announcement.endDate.day}/${announcement.endDate.month}/${announcement.endDate.year}'),
              const SizedBox(height: 8),
              Text('Time: ${announcement.time}'),
              const SizedBox(height: 8),
              Text('Participants: ${announcement.participants.join(', ')}'),
              const SizedBox(height: 8),
              Text('Venue: ${announcement.venue}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
