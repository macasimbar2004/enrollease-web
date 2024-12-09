import 'package:enrollease_web/account_screen/profile_page.dart';
import 'package:enrollease_web/pages/payments.dart';
import 'package:enrollease_web/pages/statement_of_account.dart';
import 'package:enrollease_web/pages/dashboard.dart';
import 'package:enrollease_web/pages/enrollments.dart';
import 'package:enrollease_web/pages/registrars.dart';
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
            selectedWidget = StatementOfAccount(
              userId: userId,
            );
            break;
          // case 4:
          //   selectedWidget = AcademicCalendar(
          //     userId: userId,
          //   );
          // break;
          case 5:
            selectedWidget = ProfilePage(
              userId: userId!,
            );
            break;
          case 6:
            selectedWidget = PaymentsPage(
              userId: userId!,
            );
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
