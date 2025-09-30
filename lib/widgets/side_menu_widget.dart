import 'package:enrollease_web/data/side_menu_data.dart';
import 'package:enrollease_web/model/menu_model.dart';
import 'package:enrollease_web/states_management/side_menu_index_controller.dart';
import 'package:enrollease_web/states_management/user_context_provider.dart';

import 'package:enrollease_web/utils/theme_colors.dart';
import 'package:enrollease_web/states_management/theme_provider.dart';
import 'package:enrollease_web/utils/logos.dart';
import 'package:enrollease_web/widgets/dynamic_logo.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SideMenuEntry {
  final String title;
  final IconData icon;
  final String route;

  const SideMenuEntry({
    required this.title,
    required this.icon,
    required this.route,
  });
}

class SideMenuWidget extends StatelessWidget {
  const SideMenuWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final providerState = context.watch<SideMenuIndexController>();
    final userContext = context.watch<UserContextProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final isMenuVisible = providerState.isMenuVisible;

    // Get accessible menu items based on user roles
    final accessibleMenuItems =
        SideMenuData.getAccessibleMenuItems(userContext.userRoles);

    // Debug: Print side menu information
    print('DEBUG: Side Menu Widget:');
    print('  User Roles: ${userContext.userRoles}');
    print('  Accessible Menu Items Count: ${accessibleMenuItems.length}');
    print(
        '  Accessible Menu Items: ${accessibleMenuItems.map((item) => item.title).toList()}');

    return Drawer(
      backgroundColor: Colors.white,
      elevation: 0,
      child: Column(
        children: [
          // Header with dynamic sizing
          LayoutBuilder(
            builder: (context, constraints) {
              final headerHeight = isMenuVisible ? 120.0 : 60.0;
              final logoSize = isMenuVisible ? 80.0 : 40.0;

              return Container(
                padding: EdgeInsets.only(
                  top: headerHeight * 0.2,
                  bottom: headerHeight * 0.2,
                ),
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      themeProvider.currentColors['content'] ??
                          ThemeColors.content(context),
                      (themeProvider.currentColors['content'] ??
                              ThemeColors.content(context))
                          .withValues(alpha: 0.8),
                    ],
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Decorative circles with dynamic sizing
                    Positioned(
                      right: -constraints.maxWidth * 0.1,
                      top: -constraints.maxWidth * 0.1,
                      child: Container(
                        width: constraints.maxWidth * 0.2,
                        height: constraints.maxWidth * 0.2,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                    ),
                    Positioned(
                      left: -constraints.maxWidth * 0.05,
                      bottom: -constraints.maxWidth * 0.05,
                      child: Container(
                        width: constraints.maxWidth * 0.1,
                        height: constraints.maxWidth * 0.1,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                    ),
                    // Logo with dynamic sizing
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: EdgeInsets.all(logoSize * 0.15),
                      height: logoSize,
                      width: logoSize,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(logoSize * 0.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: AdventistLogo(
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          // Menu items with dynamic sizing
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMenuVisible ? constraints.maxWidth * 0.05 : 0,
                  ),
                  child: ListView.builder(
                    itemBuilder: (context, index) => buildMenuEntry(
                        accessibleMenuItems,
                        index,
                        providerState.selectedIndex,
                        constraints,
                        userContext),
                    itemCount: accessibleMenuItems.length,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMenuEntry(
      List<MenuModel> accessibleMenuItems,
      int index,
      int selectedIndex,
      BoxConstraints constraints,
      UserContextProvider userContext) {
    // Map the accessible menu index to the full menu index for proper highlighting
    final fullMenuIndex = SideMenuData.menu.indexWhere(
      (item) => item.title == accessibleMenuItems[index].title,
    );
    final isSelected = fullMenuIndex != -1 && selectedIndex == fullMenuIndex;

    return Consumer<SideMenuIndexController>(
      builder: (context, provider, _) {
        final bool showText = provider.isMenuVisible;
        final iconSize = showText ? 32.0 : 28.0;
        final padding = showText ? constraints.maxWidth * 0.1 : 0.0;
        final themeProvider = context.watch<ThemeProvider>();

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: EdgeInsets.symmetric(vertical: constraints.maxHeight * 0.008),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: isSelected
                ? (themeProvider.currentColors['content'] ??
                        ThemeColors.content(context))
                    .withValues(alpha: 0.1)
                : Colors.transparent,
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: (themeProvider.currentColors['content'] ??
                              ThemeColors.content(context))
                          .withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                // Use the already calculated fullMenuIndex for navigation
                if (fullMenuIndex != -1) {
                  provider.setSelectedIndex(fullMenuIndex);
                  provider.setCurrentSelectedIndex(fullMenuIndex);
                }
                provider.hideMenuOnNavigation();
              },
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(
                  vertical: constraints.maxHeight * 0.02,
                  horizontal: padding,
                ),
                child: !showText
                    ? Center(
                        child: Icon(
                          accessibleMenuItems[index].icon,
                          color: isSelected
                              ? (themeProvider.currentColors['content'] ??
                                  ThemeColors.content(context))
                              : Colors.black54,
                          size: iconSize,
                        ),
                      )
                    : Row(
                        children: [
                          Icon(
                            accessibleMenuItems[index].icon,
                            color: isSelected
                                ? (themeProvider.currentColors['content'] ??
                                    ThemeColors.content(context))
                                : Colors.black54,
                            size: iconSize,
                          ),
                          SizedBox(width: constraints.maxWidth * 0.04),
                          Expanded(
                            child: Text(
                              accessibleMenuItems[index].title,
                              style: TextStyle(
                                fontSize: constraints.maxWidth * 0.045,
                                color: isSelected
                                    ? (themeProvider.currentColors['content'] ??
                                        ThemeColors.content(context))
                                    : Colors.black87,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}
