import 'package:cloud_firestore/cloud_firestore.dart';

class AnnouncementModel {
  final String id;
  final String eventName;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final String time;
  final List<String> participants;
  final String venue;

  AnnouncementModel({
    required this.id,
    required this.eventName,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.time,
    required this.participants,
    required this.venue,
  });

  Map<String, dynamic> toMap() {
    return {
      'eventName': eventName,
      'description': description,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'time': time,
      'participants': participants,
      'venue': venue,
    };
  }

  factory AnnouncementModel.fromMap(String id, Map<String, dynamic> map) {
    return AnnouncementModel(
      id: id,
      eventName: map['eventName'] ?? '',
      description: map['description'] ?? '',
      startDate: (map['startDate'] as Timestamp).toDate(),
      endDate: (map['endDate'] as Timestamp).toDate(),
      time: map['time'] ?? '',
      participants: List<String>.from(map['participants'] ?? []),
      venue: map['venue'] ?? '',
    );
  }
}
