import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../model/faculty_activity_model.dart';
import 'dart:math';

/// Service for managing faculty and staff activities
class FacultyActivityService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName = 'faculty_activities';

  /// Log a faculty/staff activity
  static Future<bool> logActivity({
    required String facultyId,
    required String facultyName,
    required String activityType,
    required String description,
    Map<String, dynamic>? metadata,
    String? targetId,
    String? targetName,
    String? ipAddress,
    String? userAgent,
  }) async {
    try {
      final activityId = _generateActivityId();
      final activity = FacultyActivityModel(
        id: activityId,
        facultyId: facultyId,
        facultyName: facultyName,
        activityType: activityType,
        description: description,
        metadata: metadata,
        targetId: targetId,
        targetName: targetName,
        timestamp: DateTime.now(),
        ipAddress: ipAddress,
        userAgent: userAgent,
      );

      await _firestore
          .collection(_collectionName)
          .doc(activityId)
          .set(activity.toMap());

      debugPrint('Activity logged: $activityType by $facultyName');
      return true;
    } catch (e) {
      debugPrint('Error logging activity: $e');
      return false;
    }
  }

  /// Get recent activities for a specific faculty member
  static Future<List<FacultyActivityModel>> getFacultyActivities({
    required String facultyId,
    int limit = 50,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('facultyId', isEqualTo: facultyId)
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map((doc) => FacultyActivityModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('Error getting faculty activities: $e');
      return [];
    }
  }

  /// Get all recent activities across all faculty/staff
  static Future<List<FacultyActivityModel>> getAllRecentActivities({
    int limit = 100,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map((doc) => FacultyActivityModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('Error getting all activities: $e');
      return [];
    }
  }

  /// Get activities by type
  static Future<List<FacultyActivityModel>> getActivitiesByType({
    required String activityType,
    int limit = 50,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('activityType', isEqualTo: activityType)
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map((doc) => FacultyActivityModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('Error getting activities by type: $e');
      return [];
    }
  }

  /// Get activity statistics for admin dashboard
  static Future<Map<String, dynamic>> getActivityStatistics({
    int days = 30,
  }) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: days));

      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('timestamp', isGreaterThan: Timestamp.fromDate(cutoffDate))
          .get();

      final activities = querySnapshot.docs
          .map((doc) => FacultyActivityModel.fromMap(doc.data()))
          .toList();

      // Calculate statistics
      final totalActivities = activities.length;
      final uniqueFaculty = activities.map((a) => a.facultyId).toSet().length;

      // Activity type counts
      final activityTypeCounts = <String, int>{};
      for (final activity in activities) {
        activityTypeCounts[activity.activityType] =
            (activityTypeCounts[activity.activityType] ?? 0) + 1;
      }

      // Most active faculty
      final facultyActivityCounts = <String, int>{};
      for (final activity in activities) {
        facultyActivityCounts[activity.facultyId] =
            (facultyActivityCounts[activity.facultyId] ?? 0) + 1;
      }

      final mostActiveFaculty = facultyActivityCounts.entries
          .reduce((a, b) => a.value > b.value ? a : b);

      // Recent activity (last 24 hours)
      final last24Hours = DateTime.now().subtract(const Duration(hours: 24));
      final recentActivities =
          activities.where((a) => a.timestamp.isAfter(last24Hours)).length;

      return {
        'totalActivities': totalActivities,
        'uniqueFaculty': uniqueFaculty,
        'activityTypeCounts': activityTypeCounts,
        'mostActiveFaculty': {
          'id': mostActiveFaculty.key,
          'count': mostActiveFaculty.value,
        },
        'recentActivities': recentActivities,
        'period': days,
      };
    } catch (e) {
      debugPrint('Error getting activity statistics: $e');
      return {
        'totalActivities': 0,
        'uniqueFaculty': 0,
        'activityTypeCounts': <String, int>{},
        'mostActiveFaculty': {'id': '', 'count': 0},
        'recentActivities': 0,
        'period': days,
      };
    }
  }

  /// Get faculty performance metrics
  static Future<Map<String, dynamic>> getFacultyPerformanceMetrics({
    required String facultyId,
    int days = 30,
  }) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: days));

      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('facultyId', isEqualTo: facultyId)
          .where('timestamp', isGreaterThan: Timestamp.fromDate(cutoffDate))
          .get();

      final activities = querySnapshot.docs
          .map((doc) => FacultyActivityModel.fromMap(doc.data()))
          .toList();

      // Calculate metrics
      final totalActivities = activities.length;
      final gradeEntries = activities
          .where((a) => a.activityType == FacultyActivityModel.gradeEntry)
          .length;
      final gradeUpdates = activities
          .where((a) => a.activityType == FacultyActivityModel.gradeUpdate)
          .length;
      final studentViews = activities
          .where((a) => a.activityType == FacultyActivityModel.studentView)
          .length;

      // Daily activity pattern
      final dailyActivity = <int, int>{};
      for (final activity in activities) {
        final dayOfWeek = activity.timestamp.weekday;
        dailyActivity[dayOfWeek] = (dailyActivity[dayOfWeek] ?? 0) + 1;
      }

      // Most active day
      final mostActiveDay =
          dailyActivity.entries.reduce((a, b) => a.value > b.value ? a : b);

      return {
        'totalActivities': totalActivities,
        'gradeEntries': gradeEntries,
        'gradeUpdates': gradeUpdates,
        'studentViews': studentViews,
        'dailyActivity': dailyActivity,
        'mostActiveDay': mostActiveDay.key,
        'period': days,
      };
    } catch (e) {
      debugPrint('Error getting faculty performance metrics: $e');
      return {
        'totalActivities': 0,
        'gradeEntries': 0,
        'gradeUpdates': 0,
        'studentViews': 0,
        'dailyActivity': <int, int>{},
        'mostActiveDay': 1,
        'period': days,
      };
    }
  }

  /// Generate unique activity ID
  static String _generateActivityId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(9999).toString().padLeft(4, '0');
    return 'ACT${timestamp}_$random';
  }

  /// Clean up old activities (for maintenance)
  static Future<bool> cleanupOldActivities({int daysToKeep = 365}) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));

      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('timestamp', isLessThan: Timestamp.fromDate(cutoffDate))
          .get();

      final batch = _firestore.batch();
      for (final doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      debugPrint('Cleaned up ${querySnapshot.docs.length} old activities');
      return true;
    } catch (e) {
      debugPrint('Error cleaning up old activities: $e');
      return false;
    }
  }
}
