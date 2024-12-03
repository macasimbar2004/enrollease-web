import 'package:enrollease_web/states_management/account_data_controller.dart';
import 'package:enrollease_web/states_management/side_menu_drawer_controller.dart';
import 'package:enrollease_web/states_management/side_menu_index_controller.dart';
import 'package:enrollease_web/utils/colors.dart';
import 'package:enrollease_web/widgets/responsive_widget.dart';
import 'package:enrollease_web/widgets/screen_selector_controller.dart';
import 'package:enrollease_web/widgets/side_menu_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isSmallOrMediumScreen = ResponsiveWidget.isSmallScreen(context) || ResponsiveWidget.isMediumScreen(context);

    final isVisible = context.watch<SideMenuIndexController>().isMenuVisible;

    // final accountProvider =
    //     Provider.of<AccountDataController>(context, listen: false);

    // // Ensure `currentRegistrar` and its field `identification` are not null
    // final currentId =
    //     accountProvider.currentRegistrar?.identification ?? 'Unknown';

    // dPrint('current id: $currentId');

    return Scaffold(
      key: context.read<SideMenuDrawerController>().scaffoldKey,
      drawer: const SideMenuWidget(),
      body: SafeArea(
          child: Row(
        children: [
          if (!ResponsiveWidget.isSmallScreen(context))
            AnimatedContainer(
                width: (!isSmallOrMediumScreen && isVisible)
                    ? 300
                    : (ResponsiveWidget.isMediumScreen(context) && !isVisible)
                        ? 300
                        : 69, // Animate between 300 and 0 width
                color: CustomColors.contentColor,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: const SideMenuWidget()
                // Conditionally render child
                ),
          Expanded(
            child: Consumer<AccountDataController>(
              builder: (context, userData, child) {
                return ScreenSelectorController(
                  userId: userData.currentRegistrar?.id,
                );
              },
            ),
          )
        ],
      )),
    );
  }
}
