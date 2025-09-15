import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  final String id;
  final String title;
  final String content;
  final DateTime? date;
  final DateTime? time;
  final DateTime? timestamp;

  EventModel({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
    required this.time,
    required this.timestamp,
  });

  EventModel copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? date,
    DateTime? time,
    DateTime? timestamp,
  }) {
    return EventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      date: date ?? this.date,
      time: time ?? this.time,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  factory EventModel.fromMap(String id, Map<String, dynamic> data) {
    return EventModel(
      id: data['id'],
      title: data['title'],
      content: data['content'],
      date: data['date'] == null ? null : (data['date'] as Timestamp).toDate(),
      time: data['time'] == null ? null : (data['time'] as Timestamp).toDate(),
      timestamp: data['timestamp'] == null ? null : (data['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'date': date == null ? null : Timestamp.fromDate(date!),
      'time': time == null ? null : Timestamp.fromDate(time!),
      'timestamp': timestamp == null ? null : Timestamp.fromDate(timestamp!),
    };
  }
}
