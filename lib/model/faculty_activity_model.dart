import 'package:cloud_firestore/cloud_firestore.dart';

/// Model for tracking faculty and staff activities
class FacultyActivityModel {
  final String id;
  final String facultyId;
  final String facultyName;
  final String activityType;
  final String description;
  final Map<String, dynamic>? metadata;
  final String? targetId; // ID of the target (student, grade, etc.)
  final String? targetName; // Name of the target for display
  final DateTime timestamp;
  final String? ipAddress;
  final String? userAgent;

  FacultyActivityModel({
    required this.id,
    required this.facultyId,
    required this.facultyName,
    required this.activityType,
    required this.description,
    this.metadata,
    this.targetId,
    this.targetName,
    required this.timestamp,
    this.ipAddress,
    this.userAgent,
  });

  factory FacultyActivityModel.fromMap(Map<String, dynamic> map) {
    return FacultyActivityModel(
      id: map['id'] ?? '',
      facultyId: map['facultyId'] ?? '',
      facultyName: map['facultyName'] ?? '',
      activityType: map['activityType'] ?? '',
      description: map['description'] ?? '',
      metadata: map['metadata'] as Map<String, dynamic>?,
      targetId: map['targetId'],
      targetName: map['targetName'],
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      ipAddress: map['ipAddress'],
      userAgent: map['userAgent'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'facultyId': facultyId,
      'facultyName': facultyName,
      'activityType': activityType,
      'description': description,
      'metadata': metadata,
      'targetId': targetId,
      'targetName': targetName,
      'timestamp': Timestamp.fromDate(timestamp),
      'ipAddress': ipAddress,
      'userAgent': userAgent,
    };
  }

  /// Activity types for faculty/staff
  static const String login = 'login';
  static const String logout = 'logout';
  static const String gradeEntry = 'grade_entry';
  static const String gradeUpdate = 'grade_update';
  static const String studentView = 'student_view';
  static const String enrollmentView = 'enrollment_view';
  static const String profileUpdate = 'profile_update';
  static const String passwordChange = 'password_change';
  static const String reportGeneration = 'report_generation';
  static const String systemAccess = 'system_access';
  static const String dataExport = 'data_export';
  static const String bulkOperation = 'bulk_operation';

  /// Get display name for activity type
  static String getActivityDisplayName(String activityType) {
    switch (activityType) {
      case login:
        return 'System Login';
      case logout:
        return 'System Logout';
      case gradeEntry:
        return 'Grade Entry';
      case gradeUpdate:
        return 'Grade Update';
      case studentView:
        return 'Student View';
      case enrollmentView:
        return 'Enrollment View';
      case profileUpdate:
        return 'Profile Update';
      case passwordChange:
        return 'Password Change';
      case reportGeneration:
        return 'Report Generation';
      case systemAccess:
        return 'System Access';
      case dataExport:
        return 'Data Export';
      case bulkOperation:
        return 'Bulk Operation';
      default:
        return 'Unknown Activity';
    }
  }

  /// Get icon for activity type
  static String getActivityIcon(String activityType) {
    switch (activityType) {
      case login:
        return '🔐';
      case logout:
        return '🚪';
      case gradeEntry:
        return '📝';
      case gradeUpdate:
        return '✏️';
      case studentView:
        return '👤';
      case enrollmentView:
        return '📋';
      case profileUpdate:
        return '👤';
      case passwordChange:
        return '🔑';
      case reportGeneration:
        return '📊';
      case systemAccess:
        return '🖥️';
      case dataExport:
        return '📤';
      case bulkOperation:
        return '⚡';
      default:
        return '❓';
    }
  }

  /// Get color for activity type
  static String getActivityColor(String activityType) {
    switch (activityType) {
      case login:
        return 'green';
      case logout:
        return 'orange';
      case gradeEntry:
        return 'blue';
      case gradeUpdate:
        return 'purple';
      case studentView:
        return 'teal';
      case enrollmentView:
        return 'indigo';
      case profileUpdate:
        return 'pink';
      case passwordChange:
        return 'red';
      case reportGeneration:
        return 'amber';
      case systemAccess:
        return 'cyan';
      case dataExport:
        return 'lime';
      case bulkOperation:
        return 'deepOrange';
      default:
        return 'grey';
    }
  }
}
