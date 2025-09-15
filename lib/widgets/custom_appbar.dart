import 'package:enrollease_web/data/side_menu_data.dart';
import 'package:enrollease_web/model/menu_model.dart';
import 'package:enrollease_web/states_management/side_menu_drawer_controller.dart';
import 'package:enrollease_web/states_management/side_menu_index_controller.dart';
import 'package:enrollease_web/states_management/user_context_provider.dart';
import 'package:enrollease_web/utils/colors.dart';
import 'package:enrollease_web/utils/logos.dart';
import 'package:enrollease_web/widgets/responsive_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'chat_panel.dart';
import 'package:enrollease_web/services/chat_service.dart';
import 'package:enrollease_web/model/chat_model.dart';
import 'package:enrollease_web/widgets/notification_bell.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../utils/notification_service.dart';
import 'package:enrollease_web/widgets/profile_pic.dart';
import 'package:enrollease_web/account_screen/menu/settings_menu.dart';
import 'package:enrollease_web/account_screen/profile_page.dart';
import 'package:enrollease_web/states_management/account_data_controller.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showNotification;
  final bool showUserAccount;
  final String? userId;
  final String? userName;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showNotification = true,
    this.showUserAccount = true,
    this.userId,
    this.userName,
  });

  @override
  Size get preferredSize => const Size.fromHeight(80);

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = ResponsiveWidget.isSmallScreen(context);
    final isMediumScreen = ResponsiveWidget.isMediumScreen(context);
    final isLargeScreen = ResponsiveWidget.isLargeScreen(context);

    // Access the providers
    final menuProvider = context.watch<SideMenuIndexController>();
    final drawerProvider = context.read<SideMenuDrawerController>();

    return Container(
      height: 80,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            CustomColors.contentColor,
            CustomColors.contentColor.withValues(alpha: 0.9),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
            spreadRadius: 2,
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left side: Menu button and logo
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Menu toggle button for small screen and drawer control
                  if (isSmallScreen)
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: menuProvider.isButtonDisabled
                            ? null
                            : () => drawerProvider.controlMenu(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.1),
                              width: 1,
                            ),
                          ),
                          child: const Icon(
                            Icons.menu,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),

                  // Menu toggle button for medium/large screen and side menu visibility
                  if (!isSmallScreen)
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: menuProvider.isButtonDisabled
                            ? null
                            : () => menuProvider.toggleMenuVisibility(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.1),
                              width: 1,
                            ),
                          ),
                          child: const Icon(
                            Icons.menu,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),

                  // Title with responsive text size
                  if (isMediumScreen || isLargeScreen)
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: Text(
                          title.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.2,
                            shadows: [
                              Shadow(
                                color: Colors.black26,
                                offset: Offset(0, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ),
                ],
              ),

              // Right side: User account and notifications
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Notification bell
                  if (userId != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Tooltip(
                        message: 'Notifications',
                        child: StreamBuilder<int>(
                          stream: NotificationService()
                              .getUnreadNotificationCount(userId!),
                          builder: (context, snapshot) {
                            final unreadCount = snapshot.data ?? 0;
                            return Stack(
                              clipBehavior: Clip.none,
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: CustomColors.contentColor
                                      .withValues(alpha: 0.92),
                                  child: IconButton(
                                    icon: const Icon(
                                      FontAwesomeIcons.bell,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => Dialog(
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16)),
                                          child: SizedBox(
                                            width: 400,
                                            child: NotificationPanel(
                                              userId: userId!,
                                              onClose: () =>
                                                  Navigator.pop(context),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                if (unreadCount > 0)
                                  Positioned(
                                    right: -2,
                                    top: -2,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 1,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black
                                                .withValues(alpha: 0.1),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      constraints: const BoxConstraints(
                                        minWidth: 16,
                                        minHeight: 16,
                                      ),
                                      child: Text(
                                        unreadCount.toString(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  // Chat button
                  if (userId != null && userName != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Tooltip(
                        message: 'Messages',
                        child: Builder(
                          builder: (context) =>
                              StreamBuilder<List<Conversation>>(
                            stream: ChatService().getConversations(userId!),
                            builder: (context, snapshot) {
                              final unreadCount = snapshot.data
                                      ?.where((conv) => conv.hasUnread)
                                      .length ??
                                  0;
                              return Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: CustomColors.contentColor
                                        .withValues(alpha: 0.92),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(20),
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) => ChatPanel(
                                              userId: userId!,
                                              userName: userName!,
                                            ),
                                          );
                                        },
                                        child: const Icon(
                                          FontAwesomeIcons.comments,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (unreadCount > 0)
                                    Positioned(
                                      right: -2,
                                      top: -2,
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 1,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black
                                                  .withValues(alpha: 0.1),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        constraints: const BoxConstraints(
                                          minWidth: 16,
                                          minHeight: 16,
                                        ),
                                        child: Text(
                                          unreadCount.toString(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  // User account button
                  if (showUserAccount)
                    Padding(
                      padding: const EdgeInsets.only(right: 4.0),
                      child: PopupMenuButton<String>(
                        offset: const Offset(0, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        tooltip: 'Account',
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'profile',
                            child: Row(
                              children: [
                                Icon(Icons.person, size: 18),
                                SizedBox(width: 8),
                                Text('Profile'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'logout',
                            child: Row(
                              children: [
                                Icon(Icons.logout, size: 18),
                                SizedBox(width: 8),
                                Text('Logout'),
                              ],
                            ),
                          ),
                        ],
                        onSelected: (value) {
                          if (value == 'profile') {
                            final userId = context
                                .read<AccountDataController>()
                                .currentRegistrar
                                ?.id;
                            if (userId != null && userId.isNotEmpty) {
                              showDialog(
                                context: context,
                                builder: (context) =>
                                    ProfileDialog(userId: userId),
                              );
                            }
                          } else if (value == 'logout') {
                            showDialog(
                              context: context,
                              builder: (context) => const LogoutDialog(),
                            );
                          }
                        },
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            const ProfilePic(size: 40),
                            // Red dot (status)
                            Positioned(
                              right: -2,
                              top: -2,
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: CustomColors.contentColor,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                            // Dropdown arrow
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: CustomColors.contentColor,
                                    width: 1.5,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.arrow_drop_down,
                                  size: 18,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Helper method to build the app drawer with side menu items
class CustomAppDrawer extends StatelessWidget {
  const CustomAppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the currently selected index from the provider
    final providerState = context.watch<SideMenuIndexController>();
    final userContext = context.watch<UserContextProvider>();

    // Calculate appropriate padding based on menu visibility
    final horizontalPadding = providerState.isMenuVisible ? 12.0 : 4.0;

    // Get accessible menu items based on user roles
    final accessibleMenuItems =
        SideMenuData.getAccessibleMenuItems(userContext.userRoles);

    return Drawer(
      backgroundColor: Colors.white,
      elevation: 2,
      child: Column(
        children: [
          // Header with logo
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24),
            width: double.infinity,
            color: CustomColors.contentColor,
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(12),
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Image.asset(
                    CustomLogos.adventistLogo,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Menu items
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: ListView.builder(
                itemBuilder: (context, index) => buildMenuEntry(
                    accessibleMenuItems, index, providerState.selectedIndex),
                itemCount: accessibleMenuItems.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Method to build each menu entry
  Widget buildMenuEntry(
      List<MenuModel> accessibleMenuItems, int index, int selectedIndex) {
    // Check if the current entry is selected
    final isSelected = selectedIndex == index;

    return Consumer<SideMenuIndexController>(
      builder: (context, provider, _) {
        // Only show text when menu is expanded
        final bool showText = provider.isMenuVisible;

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 6.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: isSelected ? Colors.grey.shade200 : Colors.transparent,
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                // Find the actual index in the full menu for proper navigation
                final fullMenuIndex = SideMenuData.menu.indexWhere(
                  (item) => item.title == accessibleMenuItems[index].title,
                );
                if (fullMenuIndex != -1) {
                  provider.setSelectedIndex(fullMenuIndex);
                  provider.setCurrentSelectedIndex(fullMenuIndex);
                }
                // Close drawer on mobile
                if (ResponsiveWidget.isSmallScreen(context)) {
                  Navigator.pop(context);
                }
                // Hide the menu after navigation for larger screens
                provider.hideMenuOnNavigation();
              },
              borderRadius: BorderRadius.circular(12),
              child: showText
                  // Expanded menu layout
                  ? Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10.0,
                        horizontal: 12.0,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Icon
                          Icon(
                            accessibleMenuItems[index].icon,
                            color: isSelected
                                ? CustomColors.contentColor
                                : Colors.black54,
                            size: 20,
                          ),
                          const SizedBox(width: 8),

                          // Text with overflow handling
                          Flexible(
                            child: Text(
                              accessibleMenuItems[index].title,
                              style: TextStyle(
                                fontSize: 15,
                                color: isSelected
                                    ? CustomColors.contentColor
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
                    )
                  // Collapsed menu layout - just the icon centered
                  : Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Center(
                        child: Icon(
                          accessibleMenuItems[index].icon,
                          color: isSelected
                              ? CustomColors.contentColor
                              : Colors.black54,
                          size: 20,
                        ),
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }
}
