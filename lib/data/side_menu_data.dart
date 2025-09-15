import 'package:enrollease_web/model/menu_model.dart';
import 'package:flutter/material.dart';

class SideMenuData {
  static const menu = <MenuModel>[
    // Admin View Pages - Read-only access for Super Admin (moved to top)
    MenuModel(
      icon: Icons.admin_panel_settings_outlined,
      title: 'Admin Dashboard',
      requiredRoles: ['Super Admin'],
    ),
    MenuModel(
      icon: Icons.school_outlined,
      title: 'Admin Students View',
      requiredRoles: ['Super Admin'],
    ),
    MenuModel(
      icon: Icons.app_registration_outlined,
      title: 'Admin Enrollments View',
      requiredRoles: ['Super Admin'],
    ),
    MenuModel(
      icon: Icons.grade_outlined,
      title: 'Admin Grades View',
      requiredRoles: ['Super Admin'],
    ),
    MenuModel(
      icon: Icons.people_outline,
      title: 'Admin Users View',
      requiredRoles: ['Super Admin'],
    ),
    MenuModel(
      icon: Icons.announcement_outlined,
      title: 'Admin Announcements View',
      requiredRoles: ['Super Admin'],
    ),
    MenuModel(
      icon: Icons.list_alt_outlined,
      title: 'Admin Logs View',
      requiredRoles: ['Super Admin'],
    ),
    // Regular pages for other roles
    MenuModel(
      icon: Icons.space_dashboard,
      title: 'Dashboard',
      requiredRoles: [
        'Registrar Officer',
        'Finance Officer',
        'User Manager',
        'Communications Officer',
        'Attendance Officer',
        'Teacher'
      ],
    ),
    MenuModel(
      icon: Icons.admin_panel_settings,
      title: 'Admin Panel',
      requiredRoles: ['Super Admin'],
    ),
    MenuModel(
      icon: Icons.account_balance,
      title: 'Faculty & Staff',
      requiredRoles: ['Super Admin'],
    ),
    MenuModel(
      icon: Icons.school,
      title: 'Enrollments',
      requiredRoles: ['Super Admin', 'Registrar Officer'],
    ),
    MenuModel(
      icon: Icons.account_balance_wallet,
      title: 'Statement of Account',
      requiredRoles: ['Super Admin', 'Finance Officer'],
    ),
    MenuModel(
      icon: Icons.school,
      title: 'Students',
      requiredRoles: ['Super Admin', 'Registrar Officer', 'Attendance Officer'],
    ),
    MenuModel(
      icon: Icons.grade,
      title: 'Academic Grades',
      requiredRoles: ['Super Admin', 'Teacher'],
    ),
    MenuModel(
      icon: Icons.people,
      title: 'Users',
      requiredRoles: ['Super Admin', 'User Manager'],
    ),
    MenuModel(
      icon: Icons.announcement,
      title: 'Announcements',
      requiredRoles: ['Super Admin', 'Communications Officer'],
    ),
    MenuModel(
      icon: Icons.list_alt,
      title: 'Student Logs',
      requiredRoles: ['Super Admin', 'Attendance Officer'],
    ),
  ];

  /// Get menu items that are accessible to a user with given roles
  static List<MenuModel> getAccessibleMenuItems(List<String> userRoles) {
    if (userRoles.isEmpty) return [];

    // Debug: Print role checking information
    print(
        'DEBUG: SideMenuData.getAccessibleMenuItems called with roles: $userRoles');

    final accessibleItems = menu.where((item) {
      // Check if user has any of the required roles for this menu item
      final hasAccess =
          item.requiredRoles.any((role) => userRoles.contains(role));
      print(
          'DEBUG: Menu item "${item.title}" - Required roles: ${item.requiredRoles} - Has access: $hasAccess');
      return hasAccess;
    }).toList();

    print('DEBUG: Total accessible menu items: ${accessibleItems.length}');
    print(
        'DEBUG: Accessible items: ${accessibleItems.map((item) => item.title).toList()}');

    return accessibleItems;
  }

  /// Check if a specific menu item is accessible to a user
  static bool isMenuItemAccessible(String menuTitle, List<String> userRoles) {
    if (userRoles.isEmpty) return false;

    final menuItem = menu.firstWhere(
      (item) => item.title == menuTitle,
      orElse: () => MenuModel(icon: Icons.error, title: '', requiredRoles: []),
    );

    if (menuItem.title.isEmpty) return false;

    return menuItem.requiredRoles.any((role) => userRoles.contains(role));
  }
}
