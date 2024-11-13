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
    final isSmallOrMediumScreen = ResponsiveWidget.isSmallScreen(context) ||
        ResponsiveWidget.isMediumScreen(context);

    final isVisible = context.watch<SideMenuIndexController>().isMenuVisible;

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
                  : 69, // Animate between 300 and 0 width
              color: CustomColors.contentColor,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: isVisible
                  ? const SideMenuWidget()
                  : const SideMenuWidget2(), // Conditionally render child
            ),
          const Expanded(child: ScreenSelectorController())
        ],
      )),
    );
  }
}
