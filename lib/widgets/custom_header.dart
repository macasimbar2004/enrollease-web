import 'package:enrollease_web/account_screen/menu/account_setting.dart';
import 'package:enrollease_web/states_management/side_menu_drawer_controller.dart';
import 'package:enrollease_web/states_management/side_menu_index_controller.dart';
import 'package:enrollease_web/utils/colors.dart';
import 'package:enrollease_web/widgets/responsive_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomDrawerHeader extends StatefulWidget {
  final String headerName;
  final String? userId;
  final bool? isToHide;

  const CustomDrawerHeader({super.key, required this.headerName, this.userId, this.isToHide = false});

  @override
  CustomDrawerHeaderState createState() => CustomDrawerHeaderState();
}

class CustomDrawerHeaderState extends State<CustomDrawerHeader> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = ResponsiveWidget.isSmallScreen(context);
    final isMediumScreen = ResponsiveWidget.isMediumScreen(context);
    final isLargeScreen = ResponsiveWidget.isLargeScreen(context);

    // Access the provider
    final menuProvider = context.watch<SideMenuIndexController>();

    // Example notification count
    int notificationCount = 5; // Replace this with your dynamic count

    return DrawerHeader(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide.none,
        ),
        color: CustomColors.contentColor,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // if (isSmallScreen || isMediumScreen)
          //   IconButton(
          //     onPressed: () {
          //       context.read<SideMenuDrawerController>().controlMenu();
          //     },
          //     icon: const Icon(
          //       Icons.menu,
          //       color: Colors.white,
          //     ),
          //   ),
          Visibility(
            visible: (isSmallScreen),
            child: IconButton(
              onPressed: menuProvider.isButtonDisabled
                  ? null // Disable the button if true
                  : () => context.read<SideMenuDrawerController>().controlMenu(),
              icon: const Icon(
                Icons.menu,
                color: Colors.white,
              ),
            ),
          ),
          if (isMediumScreen || isLargeScreen)
            Text(
              widget.headerName.toUpperCase(),
              style: const TextStyle(color: Colors.white, fontSize: 30),
            ),
          const Spacer(),
          if (widget.isToHide == null || widget.isToHide == false) const AdminAccountSetting(),
          if (widget.isToHide == null || widget.isToHide == false)
            Stack(
              children: [
                IconButton(
                  onPressed: () {
                    // Handle notification button press
                    menuProvider.setSelectedIndex(0);
                    menuProvider.setCurrentSelectedIndex(0);
                  },
                  icon: const Icon(
                    Icons.notifications,
                    size: 30,
                    color: Colors.white,
                  ),
                ),
                if (notificationCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Center(
                        child: Text(
                          notificationCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
