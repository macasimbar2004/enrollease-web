import 'package:flutter/foundation.dart';

class SideMenuIndexController extends ChangeNotifier {
  int _selectedIndex = 0;
  int _currentIndexSelected = 0;
  bool _isMenuVisible = true;
  bool _isToggling = false; // Add a new flag
  bool _isButtonDisabled = false; // New flag to disable the button

  int get selectedIndex => _selectedIndex;
  int get currentIndexSelected => _currentIndexSelected;
  bool get isMenuVisible => _isMenuVisible;
  bool get isButtonDisabled => _isButtonDisabled; // Getter for button state

  String? _currentRoute;
  String? get currentRoute => _currentRoute;

  void updatePageIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  void setSelectedIndex(int index) {
    _selectedIndex = index;
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
}
