import 'package:enrollease_web/account_screen/account_settings_dashboard.dart';
import 'package:enrollease_web/onboarding_page/approvals.dart';
import 'package:enrollease_web/onboarding_page/dashboard.dart';
import 'package:enrollease_web/onboarding_page/enrollments.dart';
import 'package:enrollease_web/onboarding_page/important_notes.dart';
import 'package:enrollease_web/onboarding_page/registrars.dart';
import 'package:enrollease_web/onboarding_page/students.dart';
import 'package:enrollease_web/states_management/side_menu_index_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ScreenSelectorController extends StatelessWidget {
  final String? userId;
  const ScreenSelectorController({super.key, this.userId});

  @override
  Widget build(BuildContext context) {
    return Consumer<SideMenuIndexController>(
      builder: (context, provider, child) {
        final selectedIndexScreen = provider.selectedIndex;

        Widget selectedWidget;

        switch (selectedIndexScreen) {
          case 0:
            selectedWidget = Dashboard(
              userId: userId,
            );
            break;

          case 1:
            selectedWidget = Registrars(
              userId: userId,
            );
            break;

          case 2:
            selectedWidget = Enrollments(
              userId: userId,
            );
            break;

          case 3:
            selectedWidget = Approvals(
              userId: userId,
            );
            break;

          case 4:
            selectedWidget = Students(
              userId: userId,
            );
            break;

          case 5:
            selectedWidget = ImportantNotes(
              userId: userId,
            );
            break;

          case 6:
            selectedWidget = AccountSettingsDashboard(
              userId: userId,
            );
            break;

          default:
            selectedWidget = Container(
              color: Colors.red,
            ); // Default to an empty container
        }

        return selectedWidget;
      },
    );
  }
}
