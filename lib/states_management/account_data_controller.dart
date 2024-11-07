import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountDataController extends ChangeNotifier {
  bool _isLoggedIn = false;

  String? _currentUserId;
  String? get userId => _currentUserId;

  String? _currentUserDivision;
  String? get currentUserDivision => _currentUserDivision;

  String? _currentUserName;
  String? get currentUserName => _currentUserName;

  String? _currentUserEmail;
  String? get currentEmail => _currentUserEmail;

  String? _currentUserPassword;
  String? get currentPassword => _currentUserPassword;

  String? _currentUserRole;
  String? get userRole => _currentUserRole;

  String? _currentUserContactNumber;
  String? get currentUserContactNumber => _currentUserContactNumber;

  AccountDataController() {
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    _currentUserId = prefs.getString('userId');
    _currentUserRole = prefs.getString('userRole');
    _currentUserName = prefs.getString('currentUserName');
    _currentUserDivision = prefs.getString('currentUserDivision');
    _currentUserEmail = prefs.getString('currentEmail');
    _currentUserPassword = prefs.getString('currentPassword');
    _currentUserContactNumber = prefs.getString('currentUserContactNumber');
    _isLoggedIn = _currentUserId != null && _currentUserRole != null;
    notifyListeners();
  }

  Future<void> _saveUserData({
    String? id,
    String? role,
    String? userName,
    String? userDivision,
    String? userEmail,
    String? userPassword,
    String? userContactNumber,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (id != null) await prefs.setString('userId', id);
    if (role != null) await prefs.setString('userRole', role);
    if (userName != null) await prefs.setString('currentUserName', userName);
    if (userDivision != null) {
      await prefs.setString('currentUserDivision', userDivision);
    }
    if (userEmail != null) await prefs.setString('currentEmail', userEmail);
    if (userPassword != null) {
      await prefs.setString('currentPassword', userPassword);
    }
    if (userContactNumber != null) {
      await prefs.setString('currentUserContactNumber', userContactNumber);
    }
    notifyListeners();
  }

  bool get isLoggedIn => _isLoggedIn;

  Future<void> setUserData({
    String? id,
    String? role,
    String? userName,
    String? userDivision,
    String? userEmail,
    String? userPassword,
    String? userContactNumber,
  }) async {
    _currentUserId = id;
    _currentUserRole = role;
    _currentUserName = userName;
    _currentUserDivision = userDivision;
    _currentUserEmail = userEmail;
    _currentUserPassword = userPassword;
    _currentUserContactNumber = userContactNumber;
    _isLoggedIn = id != null &&
        role != null &&
        userName != null &&
        userDivision != null &&
        userEmail != null &&
        userPassword != null &&
        userContactNumber != null;

    // Save user data and load it immediately after saving
    await _saveUserData(
      id: id,
      role: role,
      userName: userName,
      userDivision: userDivision,
      userEmail: userEmail,
      userPassword: userPassword,
      userContactNumber: userContactNumber,
    );
    await _loadUserData(); // Load user data after saving

    notifyListeners();
  }

  Future<void> setLoggedIn(bool loggedIn) async {
    _isLoggedIn = loggedIn;
    if (!loggedIn) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('userId');
      await prefs.remove('userRole');
      await prefs.remove('currentRoute');
      await prefs.remove('currentUserName');
      await prefs.remove('currentUserDivision');
      await prefs.remove('currentEmail');
      await prefs.remove('currentPassword');
      await prefs.remove('currentUserContactNumber');
    }
    notifyListeners();
  }
}
