import 'dart:async';

import 'package:enrollease_web/dev.dart';
import 'package:enrollease_web/model/fetching_registrar_model.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountDataController extends ChangeNotifier {
  bool _isLoggedIn = false;
  bool _isLoading = false;

  FetchingRegistrarModel? _currentRegistrar;

  FetchingRegistrarModel? get currentRegistrar => _currentRegistrar;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;

  String? _currentRoute;
  String? get currentRoute => _currentRoute;

  // Session management variables
  DateTime? _lastActivityTime;
  Timer? _sessionTimer;
  static const int sessionTimeoutMinutes = 30; // Session timeout in minutes

  AccountDataController() {
    _loadUserData();
    _startSessionTimer();
  }

  // Start the session timer to check for timeouts
  void _startSessionTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      _checkSessionTimeout();
    });
  }

  // Update last activity time (call this when user interacts with the app)
  void updateLastActivityTime() {
    _lastActivityTime = DateTime.now();
    _saveLastActivityTime();
  }

  // Save last activity time to persistent storage
  Future<void> _saveLastActivityTime() async {
    if (_lastActivityTime != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          'lastActivityTime', _lastActivityTime!.toIso8601String());
    }
  }

  // Load last activity time from persistent storage
  Future<void> _loadLastActivityTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timeString = prefs.getString('lastActivityTime');
    if (timeString != null) {
      _lastActivityTime = DateTime.parse(timeString);
    }
  }

  // Check if session has timed out
  void _checkSessionTimeout() {
    if (!_isLoggedIn || _lastActivityTime == null) return;

    final now = DateTime.now();
    final difference = now.difference(_lastActivityTime!);

    if (difference.inMinutes >= sessionTimeoutMinutes) {
      dPrint(
          'Session timeout: User has been inactive for ${difference.inMinutes} minutes');
      // Log out the user
      setLoggedIn(false);

      // Navigate to login screen if possible
      // Note: We can't directly use navigation here since this is a model,
      // but we'll set a flag to be checked by a listener in the UI
      _isSessionTimedOut = true;
      notifyListeners();
    }
  }

  bool _isSessionTimedOut = false;
  bool get isSessionTimedOut {
    final wasTimedOut = _isSessionTimedOut;
    _isSessionTimedOut = false; // Reset after reading
    return wasTimedOut;
  }

  // Load user data from SharedPreferences
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();

    _currentRoute = prefs.getString('currentRoute');

    _currentRegistrar = FetchingRegistrarModel(
      profilePicData: prefs.getString('profilePicData') ?? '',
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
      // Load RBAC fields
      userType: prefs.getString('userType'),
      roles: prefs.getStringList('userRoles'),
      status: prefs.getString('userStatus'),
      gradeLevel: prefs.getString('userGradeLevel'),
      profilePicLink: prefs.getString('profilePicLink'),
    );

    _isLoggedIn = _currentRegistrar!.id.isNotEmpty;

    // If user is logged in, load and update the last activity time
    if (_isLoggedIn) {
      await _loadLastActivityTime();
      // If there's no last activity time or it's very old, set it to now
      if (_lastActivityTime == null ||
          DateTime.now().difference(_lastActivityTime!).inMinutes >
              sessionTimeoutMinutes) {
        updateLastActivityTime();
      }
    }

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
    await prefs.setString('profilePicData', registrar.profilePicData);
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
    await prefs.setString('nameExtension',
        registrar.nameExtension ?? ''); // Handle nullable name extension
    await prefs.setString('currentPassword', registrar.password);
    await prefs.setString(
        'userRole', registrar.jobLevel); // Handle nullable jobLevel for role

    // Save RBAC fields
    if (registrar.userType != null) {
      await prefs.setString('userType', registrar.userType!);
    }
    if (registrar.roles != null) {
      await prefs.setStringList('userRoles', registrar.roles!);
    }
    if (registrar.status != null) {
      await prefs.setString('userStatus', registrar.status!);
    }
    if (registrar.gradeLevel != null) {
      await prefs.setString('userGradeLevel', registrar.gradeLevel!);
    }
    if (registrar.profilePicLink != null) {
      await prefs.setString('profilePicLink', registrar.profilePicLink!);
    }

    // Set the login state based on the registrar's identification (or other unique identifier)
    _isLoggedIn = registrar.id.isNotEmpty;

    // Update the last activity time since the user just logged in
    updateLastActivityTime();

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
        // Preserve RBAC fields
        userType: _currentRegistrar!.userType,
        roles: _currentRegistrar!.roles,
        status: _currentRegistrar!.status,
        gradeLevel: _currentRegistrar!.gradeLevel,
        profilePicLink: _currentRegistrar!.profilePicLink,
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
    if (loggedIn) {
      // Update activity time when logging in
      updateLastActivityTime();
    } else {
      _lastActivityTime = null;
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('lastActivityTime');
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

      // Clear RBAC fields
      await prefs.remove('userType');
      await prefs.remove('userRoles');
      await prefs.remove('userStatus');
      await prefs.remove('userGradeLevel');
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

  @override
  void dispose() {
    _sessionTimer?.cancel();
    super.dispose();
  }

  // Public method to reload user data
  Future<void> reloadUserData() async {
    await _loadUserData();
  }
}
