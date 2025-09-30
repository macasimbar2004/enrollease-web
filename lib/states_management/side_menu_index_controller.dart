import 'package:enrollease_web/dev.dart';
import 'package:enrollease_web/data/side_menu_data.dart';
import 'package:flutter/foundation.dart';

class SideMenuIndexController extends ChangeNotifier {
  int _selectedIndex = 0;
  int _currentIndexSelected = 0;
  bool _isMenuVisible = false;
  bool _isToggling = false; // Add a new flag
  bool _isButtonDisabled = false; // New flag to disable the button
  Map<String, dynamic> _data = {};

  int get selectedIndex => _selectedIndex;
  int get currentIndexSelected => _currentIndexSelected;
  bool get isMenuVisible => _isMenuVisible;
  bool get isButtonDisabled => _isButtonDisabled; // Getter for button state
  Map<String, dynamic> get data => _data;

  String? _currentRoute;
  String? get currentRoute => _currentRoute;

  void updatePageIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  void setSelectedIndex(int index) {
    dPrint(index);
    _selectedIndex = index;
    notifyListeners();
  }

  void setData(Map<String, dynamic> newData) {
    _data = Map.from(newData);
    notifyListeners();
  }

  void setCurrentSelectedIndex(int index) {
    _currentIndexSelected =
        index; // Update currentIndexSelected when the index is set
    notifyListeners();
  }

  void toggleMenuVisibility() {
    if (_isToggling) return; // Skip if already in toggling state
    _isToggling = true;
    _isButtonDisabled = true; // Disable the button during toggle
    _isMenuVisible = !_isMenuVisible;
    notifyListeners();

    // Reset flags after a short delay (e.g., animation duration)
    Future.delayed(const Duration(milliseconds: 400), () {
      _isToggling = false;
      _isButtonDisabled = false; // Re-enable the button
      notifyListeners();
    });
  }

  // New method to hide the menu (used for navigation)
  void hideMenuOnNavigation() {
    if (_isMenuVisible && !_isToggling) {
      _isToggling = true;
      _isButtonDisabled = true;
      _isMenuVisible = false;
      notifyListeners();

      // Reset flags after animation completes
      Future.delayed(const Duration(milliseconds: 400), () {
        _isToggling = false;
        _isButtonDisabled = false;
        notifyListeners();
      });
    }
  }

  /// Initialize the menu index to the first accessible menu item for the user's roles
  void initializeForUserRoles(List<String> userRoles) {
    if (userRoles.isEmpty) {
      // If no roles, default to index 0 (should not happen in normal flow)
      _selectedIndex = 0;
      notifyListeners();
      return;
    }

    // Get accessible menu items for the user
    final accessibleMenuItems = SideMenuData.getAccessibleMenuItems(userRoles);

    if (accessibleMenuItems.isEmpty) {
      // If no accessible items, default to index 0 (should not happen in normal flow)
      _selectedIndex = 0;
      notifyListeners();
      return;
    }

    // Find the index of the first accessible menu item in the full menu
    final firstAccessibleItem = accessibleMenuItems.first;
    final fullMenuIndex = SideMenuData.menu.indexWhere(
      (item) => item.title == firstAccessibleItem.title,
    );

    if (fullMenuIndex != -1) {
      _selectedIndex = fullMenuIndex;
      dPrint(
          'Initialized menu index to $fullMenuIndex for first accessible item: ${firstAccessibleItem.title}');
    } else {
      // Fallback to index 0 if something goes wrong
      _selectedIndex = 0;
      dPrint(
          'Warning: Could not find menu index for ${firstAccessibleItem.title}, defaulting to 0');
    }

    notifyListeners();
  }
}
