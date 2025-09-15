import 'package:enrollease_web/dev.dart';
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
}
