import 'package:flutter/material.dart';
import 'package:enrollease_web/utils/rbac_service.dart';

/// User Context Provider
/// Manages current user information and role-based access control
class UserContextProvider extends ChangeNotifier {
  String? _userId;
  String? _userName;
  String? _userEmail;
  String _userType = 'Staff';
  List<String> _userRoles = [];
  String _userStatus = 'active';
  String? _userGradeLevel;
  String? _userProfilePic;

  // Getters
  String? get userId => _userId;
  String? get userName => _userName;
  String? get userEmail => _userEmail;
  String get userType => _userType;
  List<String> get userRoles => _userRoles;
  String get userStatus => _userStatus;
  String? get userGradeLevel => _userGradeLevel;
  String? get userProfilePic => _userProfilePic;

  /// Check if user can access a specific page
  bool canAccessPage(String pageName) {
    return RBACService.canAccessPage(pageName, _userRoles);
  }

  /// Get all accessible pages for current user
  List<String> get accessiblePages {
    return RBACService.getAccessiblePages(_userRoles);
  }

  /// Check if user can perform a specific action
  bool canPerformAction(String action) {
    return RBACService.canPerformAction(action, _userRoles);
  }

  /// Check if user has a specific role
  bool hasRole(String role) {
    return _userRoles.contains(role);
  }

  /// Check if user has any of the specified roles
  bool hasAnyRole(List<String> roles) {
    return _userRoles.any((role) => roles.contains(role));
  }

  /// Check if user is a teacher
  bool get isTeacher => _userType == 'Teacher';

  /// Check if user is staff
  bool get isStaff => _userType == 'Staff';

  /// Check if user is active
  bool get isActive => _userStatus == 'active';

  /// Update user context from faculty/staff data
  void updateFromFacultyStaff({
    required String id,
    required String name,
    required String email,
    required String userType,
    required List<String> roles,
    required String status,
    String? gradeLevel,
    String? profilePic,
  }) {
    _userId = id;
    _userName = name;
    _userEmail = email;
    _userType = userType;
    _userRoles = roles;
    _userStatus = status;
    _userGradeLevel = gradeLevel;
    _userProfilePic = profilePic;
    notifyListeners();
  }

  /// Update user context from legacy user data
  void updateFromLegacyUser({
    required String uid,
    required String userName,
    required String email,
    required String role,
    required bool isActive,
  }) {
    _userId = uid;
    _userName = userName;
    _userEmail = email;
    _userType = 'Staff'; // Default for legacy users
    _userRoles = [role]; // Convert single role to list
    _userStatus = isActive ? 'active' : 'disabled';
    _userGradeLevel = null;
    _userProfilePic = null;
    notifyListeners();
  }

  /// Clear user context (logout)
  void clearUserContext() {
    _userId = null;
    _userName = null;
    _userEmail = null;
    _userType = 'Staff';
    _userRoles = [];
    _userStatus = 'active';
    _userGradeLevel = null;
    _userProfilePic = null;
    notifyListeners();
  }

  /// Get user's primary role for display
  String get primaryRole {
    if (_userRoles.isEmpty) return 'No Role';
    if (_userRoles.contains('Teacher')) return 'Teacher';
    return _userRoles.first;
  }

  /// Get formatted roles string for display
  String get formattedRoles {
    if (_userRoles.isEmpty) return 'No Roles';
    if (_userRoles.length == 1) return _userRoles.first;
    return '${_userRoles.take(2).join(', ')}${_userRoles.length > 2 ? ' +${_userRoles.length - 2} more' : ''}';
  }
}
