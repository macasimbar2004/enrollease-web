import 'package:enrollease_web/data/side_menu_data.dart';
import 'package:enrollease_web/states_management/side_menu_index_controller.dart';
import 'package:enrollease_web/utils/colors.dart';
import 'package:enrollease_web/utils/logos.dart';
import 'package:enrollease_web/widgets/responsive_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SideMenuWidget extends StatelessWidget {
  const SideMenuWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize SideMenuData to get menu items
    final data = SideMenuData();
    // Get the currently selected index from the provider
    final providerState = context.watch<SideMenuIndexController>();

    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.only(top: 15, bottom: 15),
                color: CustomColors.contentColor,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (providerState.isMenuVisible)
                      FittedBox(
                        child: Container(
                          padding: const EdgeInsets.only(top: 10, bottom: 10),
                          height: 130,
                          width: 130,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(70),
                          ),
                          child: Image.asset(
                            CustomLogos.adventistLogo,
                          ),
                        ),
                      ),
                    if (!providerState.isMenuVisible)
                      const SizedBox(
                        width: 40,
                        height: 50,
                      ),
                  ],
                ),
              ),
              if (!ResponsiveWidget.isSmallScreen(context))
                Positioned(
                  bottom: 0,
                  top: 0,
                  right: 0,
                  child: IconButton(
                    onPressed: providerState.isButtonDisabled
                        ? null // Disable the button if true
                        : () => providerState.toggleMenuVisibility(),
                    icon: const Icon(
                      Icons.menu,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: ListView.builder(
                itemBuilder: (context, index) => buildMenuEntry(data, index, providerState.selectedIndex),
                itemCount: data.menu.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Method to build each menu entry with animation
  Widget buildMenuEntry(SideMenuData data, int index, int selectedIndex) {
    // Check if the current entry is selected
    final isSelected = selectedIndex == index;

    return Consumer<SideMenuIndexController>(
      builder: (context, provider, _) => Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(6)),
          color: isSelected ? Colors.grey : Colors.transparent,
        ),
        child: InkWell(
          onTap: () {
            provider.setSelectedIndex(index);
            provider.setCurrentSelectedIndex(index);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            margin: isSelected
                ? const EdgeInsets.only(left: 10.0) // Move right when selected
                : const EdgeInsets.only(left: 0.0), // Default position when not selected
            child: AnimatedScale(
              scale: isSelected ? 1.05 : 1.0, // Slightly scale up when selected
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    // Icon for the menu item
                    Padding(
                      padding: const EdgeInsets.only(right: 20, top: 12, bottom: 12),
                      child: Icon(
                        data.menu[index].icon,
                        color: Colors.black,
                      ),
                    ),
                    // Title of the menu item
                    Text(
                      data.menu[index].title,
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                        overflow: TextOverflow.clip,
                      ),
                      overflow: TextOverflow.clip,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
