import 'package:enrollease_web/states_management/account_data_controller.dart';
import 'package:enrollease_web/states_management/side_menu_drawer_controller.dart';
import 'package:enrollease_web/states_management/side_menu_index_controller.dart';
import 'package:enrollease_web/states_management/user_context_provider.dart';
import 'package:enrollease_web/states_management/theme_provider.dart';
import 'package:enrollease_web/states_management/footer_config_provider.dart';
import 'package:enrollease_web/services/app_initialization_service.dart';

import 'package:enrollease_web/utils/theme_colors.dart';
import 'package:enrollease_web/widgets/responsive_widget.dart';
import 'package:enrollease_web/widgets/screen_selector_controller.dart';
import 'package:enrollease_web/widgets/side_menu_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:enrollease_web/widgets/custom_toast.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  void initState() {
    super.initState();
    // Update the last activity time when this screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Provider.of<AccountDataController>(context, listen: false)
          .updateLastActivityTime();

      // Initialize theme provider with constant colors fallback
      final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
      await AppInitializationService.initializeWithConstantColors(
          themeProvider);

      // Initialize footer config provider
      Provider.of<FooterConfigProvider>(context, listen: false).initialize();

      // Initialize user context
      _initializeUserContext();
    });
  }

  void _initializeUserContext() {
    final accountProvider =
        Provider.of<AccountDataController>(context, listen: false);
    final userContext =
        Provider.of<UserContextProvider>(context, listen: false);
    final menuController =
        Provider.of<SideMenuIndexController>(context, listen: false);

    final currentRegistrar = accountProvider.currentRegistrar;
    if (currentRegistrar != null) {
      // Debug: Print current registrar data
      print('DEBUG: Current registrar data:');
      print('  ID: ${currentRegistrar.id}');
      print(
          '  Name: ${currentRegistrar.firstName} ${currentRegistrar.lastName}');
      print('  User Type: ${currentRegistrar.userType}');
      print('  Roles: ${currentRegistrar.roles}');
      print('  Status: ${currentRegistrar.status}');

      // Check if this is a faculty/staff user or legacy user
      if (currentRegistrar.userType != null && currentRegistrar.roles != null) {
        // New faculty/staff user
        print('DEBUG: Setting up new faculty/staff user');
        userContext.updateFromFacultyStaff(
          id: currentRegistrar.id,
          name: '${currentRegistrar.firstName} ${currentRegistrar.lastName}',
          email: currentRegistrar.email,
          userType: currentRegistrar.userType!,
          roles: currentRegistrar.roles!,
          status: currentRegistrar.status ?? 'active',
          gradeLevel: currentRegistrar.gradeLevel,
          profilePic: currentRegistrar.profilePicLink,
          menuController: menuController,
        );
      } else {
        // Legacy user - convert to new format
        print('DEBUG: Setting up legacy user');
        userContext.updateFromLegacyUser(
          uid: currentRegistrar.id,
          userName:
              '${currentRegistrar.firstName} ${currentRegistrar.lastName}',
          email: currentRegistrar.email,
          role: 'Registrar Officer', // Default role for legacy users
          isActive: true, // Assume active for legacy users
          menuController: menuController,
        );
      }

      // Debug: Print user context after setup
      print('DEBUG: User context after setup:');
      print('  User Type: ${userContext.userType}');
      print('  Roles: ${userContext.userRoles}');
      print('  Accessible Pages: ${userContext.accessiblePages}');
    } else {
      print('DEBUG: No current registrar data found');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isVisible = context.watch<SideMenuIndexController>().isMenuVisible;

    // Listen for session timeout events
    final accountProvider = Provider.of<AccountDataController>(context);
    if (accountProvider.isSessionTimedOut) {
      // Use a post-frame callback to avoid build errors
      WidgetsBinding.instance.addPostFrameCallback((_) {
        DelightfulToast.showInfo(context, 'Session Expired',
            'Your session has expired. Please log in again.');
        context.go('/'); // Navigate back to login
      });
    }

    // Update the activity time when the user interacts with the screen
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => accountProvider.updateLastActivityTime(),
      onPanDown: (_) => accountProvider.updateLastActivityTime(),
      onScaleStart: (_) => accountProvider.updateLastActivityTime(),
      child: Scaffold(
        key: context.read<SideMenuDrawerController>().scaffoldKey,
        drawer: const SideMenuWidget(),
        body: SafeArea(
            child: Row(
          children: [
            if (!ResponsiveWidget.isSmallScreen(context))
              AnimatedContainer(
                  width: isVisible ? 300 : 76,
                  color: Provider.of<ThemeProvider>(context, listen: false)
                          .currentColors['content'] ??
                      ThemeColors.content(context),
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: const SideMenuWidget()),
            Expanded(
              child: Consumer<AccountDataController>(
                builder: (context, userData, child) {
                  final currentRegistrar = userData.currentRegistrar;
                  final userName = currentRegistrar != null
                      ? '${currentRegistrar.firstName} ${currentRegistrar.lastName}'
                      : null;
                  return ScreenSelectorController(
                    userId: currentRegistrar?.id,
                    userName: userName,
                  );
                },
              ),
            )
          ],
        )),
      ),
    );
  }
}
