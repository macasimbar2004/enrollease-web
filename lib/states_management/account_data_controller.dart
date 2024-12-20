import 'package:enrollease_web/dev.dart';
import 'package:enrollease_web/model/fetching_registrar_model.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountDataController extends ChangeNotifier {
  bool _isLoggedIn = false;
  bool _isLoading = false;
  bool _profilePicChanged = false;

  FetchingRegistrarModel? _currentRegistrar;

  FetchingRegistrarModel? get currentRegistrar => _currentRegistrar;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;

  String? _currentRoute;
  String? get currentRoute => _currentRoute;
  bool get profilePicChanged => _profilePicChanged;

  AccountDataController() {
    _loadUserData();
  }

  void toggleProfilePicChanged() {
    _profilePicChanged = !profilePicChanged;
    notifyListeners();
  }

  // Load user data from SharedPreferences
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();

    _currentRoute = prefs.getString('currentRoute');

    _currentRegistrar = FetchingRegistrarModel(
      profilePicLink: prefs.getString('profilePicLink') ?? '',
      id: prefs.getString('userId') ?? '',
      lastName: prefs.getString('lastName') ?? '',
      firstName: prefs.getString('firstName') ?? '',
      middleName: prefs.getString('middleName') ?? '',
      dateOfBirth: prefs.getString('dateOfBirth') ?? '',
      age: prefs.getString('age') ?? '',
      contact: prefs.getString('contact') ?? '',
      placeOfBirth: prefs.getString('placeOfBirth') ?? '',
      address: prefs.getString('currentUserDivision') ?? '',
      email: prefs.getString('currentEmail') ?? '',
      remarks: prefs.getString('remarks') ?? '',
      nameExtension: prefs.getString('nameExtension'),
      password: prefs.getString('currentPassword') ?? '',
      jobLevel: prefs.getString('userRole') ?? '',
    );

    _isLoggedIn = _currentRegistrar!.id.isNotEmpty;
    notifyListeners();
  }

  Future<void> _saveCurrentRoute(String? route) async {
    final prefs = await SharedPreferences.getInstance();
    if (route != null) {
      await prefs.setString('currentRoute', route);
    }
    notifyListeners();
  }

  // Set user data from FetchingRegistrarModel
  Future<void> setRegistrarData({
    FetchingRegistrarModel? registrar,
  }) async {
    if (registrar == null) return;

    final prefs = await SharedPreferences.getInstance();

    // Saving registrar fields into SharedPreferences
    await prefs.setString('userId', registrar.id);
    await prefs.setString('profilePicLink', registrar.profilePicLink);
    await prefs.setString('lastName', registrar.lastName);
    await prefs.setString('firstName', registrar.firstName);
    await prefs.setString('middleName', registrar.middleName);
    await prefs.setString('dateOfBirth', registrar.dateOfBirth);
    await prefs.setString('age', registrar.age);
    await prefs.setString('contact', registrar.contact);
    await prefs.setString('placeOfBirth', registrar.placeOfBirth);
    await prefs.setString('currentUserDivision', registrar.address);
    await prefs.setString('currentEmail', registrar.email);
    await prefs.setString('remarks', registrar.remarks);
    await prefs.setString('nameExtension', registrar.nameExtension ?? ''); // Handle nullable name extension
    await prefs.setString('currentPassword', registrar.password);
    await prefs.setString('userRole', registrar.jobLevel); // Handle nullable jobLevel for role

    // Set the login state based on the registrar's identification (or other unique identifier)
    _isLoggedIn = registrar.id.isNotEmpty;

    // Reload the user data after saving
    await _loadUserData();

    notifyListeners();
  }

  // Dynamically update the registrar fields
  void updateRegistrarLocal(Map<String, dynamic> updatedFields) {
    if (_currentRegistrar != null) {
      final currentData = _currentRegistrar!.toMap();

      // Update only the fields provided in updatedFields
      updatedFields.forEach((key, value) {
        if (currentData.containsKey(key) && value != null) {
          currentData[key] = value;
        }
      });

      // Recreate the model with the updated data, but retain the original values for other fields
      _currentRegistrar = _currentRegistrar?.copyWith(
        id: currentData['userId'],
        lastName: currentData['lastName'],
        firstName: currentData['firstName'],
        middleName: currentData['middleName'],
        dateOfBirth: currentData['dateOfBirth'],
        age: currentData['age'],
        contact: currentData['contact'],
        placeOfBirth: currentData['placeOfBirth'],
        address: currentData['currentUserDivision'],
        email: currentData['currentEmail'],
        remarks: currentData['remarks'],
        nameExtension: currentData['nameExtension'],
        password: currentData['currentPassword'],
        jobLevel: currentData['userRole'],
        profilePicLink: currentData['profilePicLink'],
      );
      setRegistrarData(registrar: _currentRegistrar);
      dPrint('Updated data: ${_currentRegistrar!.toMap()}');
      notifyListeners(); // Notify listeners to refresh UI
    }
  }

  // Save the current route
  Future<void> setCurrentRoute(String? route) async {
    _currentRoute = route;
    await _saveCurrentRoute(route); // Save to local storage
    notifyListeners();
  }

  // Set the login state
  Future<void> setLoggedIn(bool loggedIn) async {
    _isLoggedIn = loggedIn;
    if (!loggedIn) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('userId');
      await prefs.remove('lastName');
      await prefs.remove('firstName');
      await prefs.remove('middleName');
      await prefs.remove('dateOfBirth');
      await prefs.remove('age');
      await prefs.remove('contact');
      await prefs.remove('placeOfBirth');
      await prefs.remove('currentUserDivision');
      await prefs.remove('currentEmail');
      await prefs.remove('remarks');
      await prefs.remove('nameExtension');
      await prefs.remove('currentPassword');
      await prefs.remove('userRole');
      await prefs.remove('profilePicLink');
    }
    notifyListeners();
  }

  // Set loading state
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners(); // Notify listeners so the UI updates
  }

  // Clear the registrar data
  void clearRegistrarData() {
    _currentRegistrar = null;
    _isLoggedIn = false;
    notifyListeners();
  }
}
