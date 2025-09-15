import 'package:flutter/material.dart';

/// Role-Based Access Control Service
/// Defines which roles can access which pages and features
class RBACService {
  // Role definitions
  static const String superAdmin = 'Super Admin';
  static const String registrarOfficer = 'Registrar Officer';
  static const String financeOfficer = 'Finance Officer';
  static const String userManager = 'User Manager';
  static const String communicationsOfficer = 'Communications Officer';
  static const String attendanceOfficer = 'Attendance Officer';
  static const String teacher = 'Teacher';

  // Page access permissions
  static const Map<String, List<String>> _pagePermissions = {
    'Dashboard': [
      superAdmin,
      registrarOfficer,
      financeOfficer,
      userManager,
      communicationsOfficer,
      attendanceOfficer,
      teacher
    ],
    'Admin Panel': [superAdmin], // Only Super Admin can access admin panel
    'Faculty & Staff': [
      superAdmin
    ], // Only Super Admin can manage faculty/staff
    'Enrollments': [superAdmin, registrarOfficer, teacher],
    'Statement of Account': [superAdmin, financeOfficer],
    'Students': [superAdmin, registrarOfficer, teacher, attendanceOfficer],
    'Academic Grades': [superAdmin, teacher],
    'Users': [superAdmin, userManager],
    'Announcements': [superAdmin, communicationsOfficer],
    'Student Logs': [superAdmin, attendanceOfficer],
    // Admin View Pages - Read-only access for Super Admin
    'Admin Dashboard': [superAdmin],
    'Admin Students View': [superAdmin],
    'Admin Enrollments View': [superAdmin],
    'Admin Grades View': [superAdmin],
    'Admin Users View': [superAdmin],
    'Admin Announcements View': [superAdmin],
    'Admin Logs View': [superAdmin],
  };

  /// Check if a user with given roles can access a specific page
  static bool canAccessPage(String pageName, List<String> userRoles) {
    if (userRoles.isEmpty) return false;

    final allowedRoles = _pagePermissions[pageName];
    if (allowedRoles == null) return false;

    // Check if user has any of the required roles
    return userRoles.any((role) => allowedRoles.contains(role));
  }

  /// Get all accessible pages for a user with given roles
  static List<String> getAccessiblePages(List<String> userRoles) {
    if (userRoles.isEmpty) return [];

    return _pagePermissions.keys
        .where((pageName) => canAccessPage(pageName, userRoles))
        .toList();
  }

  /// Get the role display name for UI
  static String getRoleDisplayName(String role) {
    switch (role) {
      case superAdmin:
        return 'Super Admin';
      case registrarOfficer:
        return 'Registrar Officer';
      case financeOfficer:
        return 'Finance Officer';
      case userManager:
        return 'User Manager';
      case communicationsOfficer:
        return 'Communications Officer';
      case attendanceOfficer:
        return 'Attendance Officer';
      case teacher:
        return 'Teacher';
      default:
        return role;
    }
  }

  /// Get role description for UI
  static String getRoleDescription(String role) {
    switch (role) {
      case superAdmin:
        return 'Full system access including admin panel and user management';
      case registrarOfficer:
        return 'Manages student enrollments and academic records';
      case financeOfficer:
        return 'Handles financial accounts and payment processing';
      case userManager:
        return 'Manages faculty and staff accounts';
      case communicationsOfficer:
        return 'Creates and manages announcements';
      case attendanceOfficer:
        return 'Monitors student attendance and logs';
      case teacher:
        return 'Teaches specific grade levels and manages grades';
      default:
        return 'No description available';
    }
  }

  /// Check if user can perform specific actions
  static bool canPerformAction(String action, List<String> userRoles) {
    switch (action) {
      case 'add_user':
        return userRoles.contains(superAdmin) ||
            userRoles.contains(userManager);
      case 'edit_user':
        return userRoles.contains(superAdmin) ||
            userRoles.contains(userManager);
      case 'delete_user':
        return userRoles.contains(superAdmin) ||
            userRoles.contains(userManager);
      case 'manage_enrollments':
        return userRoles.contains(superAdmin) ||
            userRoles.contains(registrarOfficer);
      case 'process_payments':
        return userRoles.contains(superAdmin) ||
            userRoles.contains(financeOfficer);
      case 'create_announcements':
        return userRoles.contains(superAdmin) ||
            userRoles.contains(communicationsOfficer);
      case 'view_student_logs':
        return userRoles.contains(superAdmin) ||
            userRoles.contains(attendanceOfficer);
      case 'manage_grades':
        return userRoles.contains(superAdmin) || userRoles.contains(teacher);
      case 'manage_school_year':
        return userRoles.contains(superAdmin);
      case 'auto_promote_students':
        return userRoles.contains(superAdmin);
      default:
        return false;
    }
  }

  /// Check if user is Super Admin
  static bool isSuperAdmin(List<String> userRoles) {
    return userRoles.contains(superAdmin);
  }

  /// Check if a page is an admin view page
  static bool isAdminViewPage(String pageName) {
    return pageName.startsWith('Admin ') && pageName.endsWith(' View') ||
        pageName == 'Admin Dashboard';
  }

  /// Get the corresponding admin view page name for a regular page
  static String? getAdminViewPageName(String regularPageName) {
    switch (regularPageName) {
      case 'Dashboard':
        return 'Admin Dashboard';
      case 'Students':
        return 'Admin Students View';
      case 'Enrollments':
        return 'Admin Enrollments View';
      case 'Academic Grades':
        return 'Admin Grades View';
      case 'Users':
        return 'Admin Users View';
      case 'Announcements':
        return 'Admin Announcements View';
      case 'Student Logs':
        return 'Admin Logs View';
      default:
        return null;
    }
  }
}
