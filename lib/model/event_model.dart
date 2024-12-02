import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  final String id;
  final String title;
  final String content;
  final DateTime? date;
  final DateTime? time;
  final DateTime? timestamp;

  EventModel({required this.id, required this.title, required this.content, required this.date, required this.time, required this.timestamp});

  factory EventModel.fromMap(Map<String, dynamic> data) {
    return EventModel(
      id: data['id'],
      title: data['title'],
      content: data['content'],
      date: data['date'] == null ? null : (data['date'] as Timestamp).toDate(),
      time: data['time'] == null ? null : (data['time'] as Timestamp).toDate(),
      timestamp: data['timestamp'] == null ? null : (data['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap(Map<String, dynamic> data) {
    return {
      'id': data['id'],
      'title': data['title'],
      'content': data['content'],
      'date': data['date'] == null ? null : (data['date'] as Timestamp).toDate(),
      'time': data['time'] == null ? null : (data['time'] as Timestamp).toDate(),
      'timestamp': data['timestamp'] == null ? null : (data['timestamp'] as Timestamp).toDate(),
    };
  }
}
