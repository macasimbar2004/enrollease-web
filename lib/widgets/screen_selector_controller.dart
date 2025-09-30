import 'package:enrollease_web/account_screen/profile_page.dart';
import 'package:enrollease_web/pages/academic_grades_page.dart';
import 'package:enrollease_web/pages/admin_panel.dart';
import 'package:enrollease_web/pages/admin_dashboard.dart';
import 'package:enrollease_web/pages/admin_students_view.dart';
import 'package:enrollease_web/pages/announcements_page.dart';
import 'package:enrollease_web/pages/statement_of_account.dart';
import 'package:enrollease_web/pages/dashboard.dart';
import 'package:enrollease_web/pages/enrollments.dart';
import 'package:enrollease_web/pages/faculty_staff.dart';
import 'package:enrollease_web/pages/students_page.dart';
import 'package:enrollease_web/pages/users_page.dart';
import 'package:enrollease_web/pages/student_logs_page.dart';
import 'package:enrollease_web/pages/theme_customization_page.dart';
import 'package:enrollease_web/states_management/side_menu_index_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ScreenSelectorController extends StatelessWidget {
  final String? userId;
  final String? userName;

  const ScreenSelectorController({
    super.key,
    this.userId,
    this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<SideMenuIndexController>(
      builder: (context, menuProvider, child) {
        final selectedIndexScreen = menuProvider.selectedIndex;
        return _getPageForIndex(selectedIndexScreen);
      },
    );
  }

  /// Get the page widget for the given index
  Widget _getPageForIndex(int index) {
    switch (index) {
      // Admin View Pages (indices 0-6)
      case 0:
        return AdminDashboard(
          userId: userId,
          userName: userName,
        );
      case 1:
        return AdminStudentsView(
          userId: userId,
          userName: userName,
        );
      case 2:
        return Enrollments(
          userId: userId,
          userName: userName,
        ); // Admin Enrollments View - using same component for now
      case 3:
        return AcademicGradesPage(
          userId: userId!,
          userName: userName,
        ); // Admin Grades View - using same component for now
      case 4:
        return UsersPage(
          userId: userId,
          userName: userName,
        ); // Admin Users View - using same component for now
      case 5:
        return AnnouncementsPage(
          userId: userId,
          userName: userName,
        ); // Admin Announcements View - using same component for now
      case 6:
        return StudentLogsPage(
          userId: userId,
          userName: userName,
        ); // Admin Logs View - using same component for now
      // Regular pages (indices 7+)
      case 7:
        return Dashboard(
          userId: userId,
          userName: userName,
        );
      case 8:
        return const AdminPanel();
      case 9:
        return ThemeCustomizationPage(
          userId: userId,
          userName: userName,
        );
      case 10:
        return FacultyStaff(
          userId: userId,
          userName: userName,
        );
      case 11:
        return Enrollments(
          userId: userId,
          userName: userName,
        );
      case 12:
        return StatementOfAccount(
          userId: userId,
          userName: userName,
        );
      case 13:
        return StudentsPage(
          userId: userId!,
          userName: userName,
        );
      case 14:
        return AcademicGradesPage(
          userId: userId!,
          userName: userName,
        );
      case 15:
        return UsersPage(
          userId: userId,
          userName: userName,
        );
      case 16:
        return AnnouncementsPage(
          userId: userId,
          userName: userName,
        );
      case 17:
        return StudentLogsPage(
          userId: userId,
          userName: userName,
        );
      case 18:
        return ProfilePage(
          userId: userId!,
        );
      default:
        return Container(
          color: Colors.blue,
        );
    }
  }
}
