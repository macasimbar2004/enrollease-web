import 'dart:async';

import 'package:enrollease_web/model/statistics_model.dart';
import 'package:enrollease_web/utils/firebase_auth.dart';
import 'package:enrollease_web/utils/logos.dart';
import 'package:flutter/material.dart';

class StatisticsModelDataController extends ChangeNotifier {
  final FirebaseAuthProvider _firebaseAuthProvider = FirebaseAuthProvider();

  // Stream controller for the statistics data
  final StreamController<List<StatisticsModel>> _statsStreamController =
      StreamController<List<StatisticsModel>>.broadcast();

  List<StatisticsModel> data = const [
    StatisticsModel(
        imageAssets: CustomLogos.newUsers, title: 'Total Users', count: '0'),
    StatisticsModel(
        imageAssets: CustomLogos.pendingapproval,
        title: 'Pending Approvals',
        count: '0'),
    StatisticsModel(
        imageAssets: CustomLogos.totalEnrollment,
        title: 'Total Enrolled',
        count: '250'),
  ];

  Stream<List<StatisticsModel>> get statsStream =>
      _statsStreamController.stream;

  StatisticsModelDataController() {
    _initializeStream();
  }

  void _initializeStream() {
    // Subscribe to the real-time stream of total users count
    _firebaseAuthProvider.getTotalUsersStream().listen((totalUsers) {
      _updateStatistics('Total Users', totalUsers.toString());
    });

    // Subscribe to the real-time stream of total enrollment forms count
    _firebaseAuthProvider.getEnrollmentFormsStream().listen((enrollmentForms) {
      _updateStatistics('Pending Approvals', enrollmentForms.toString());
    });
  }

  // Update the statistics based on the title condition
  void _updateStatistics(String title, String newCount) {
    data = data.map((item) {
      if (item.title == title) {
        return StatisticsModel(
          imageAssets: item.imageAssets,
          title: item.title,
          count: newCount,
        );
      }
      return item;
    }).toList();

    // Emit the updated data to the stream
    _statsStreamController.add(data);
    notifyListeners();
  }

  @override
  void dispose() {
    _statsStreamController.close();
    super.dispose();
  }
}
