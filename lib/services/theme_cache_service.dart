import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:enrollease_web/model/theme_config_model.dart';

/// Service to handle theme configuration caching
/// This prevents the need to load theme configuration from Firebase every time
class ThemeCacheService {
  static const String _themeCacheKey = 'theme_config_cache';
  static const String _cacheTimestampKey = 'theme_cache_timestamp';
  static const String _activeThemeIdKey = 'active_theme_id';
  static const String _userSessionKey = 'user_session_data';

  // Cache duration: 24 hours
  static const Duration _cacheValidDuration = Duration(hours: 24);

  /// Save theme configuration to cache
  static Future<void> cacheThemeConfig(ThemeConfigModel theme) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Convert theme to JSON-compatible format
      final themeMap = theme.toMap();
      // Convert Timestamps to ISO strings for JSON serialization
      themeMap['createdAt'] = theme.createdAt.toIso8601String();
      themeMap['updatedAt'] = theme.updatedAt.toIso8601String();
      final themeJson = jsonEncode(themeMap);

      // Save theme and timestamp
      await prefs.setString(_themeCacheKey, themeJson);
      await prefs.setString(
          _cacheTimestampKey, DateTime.now().toIso8601String());
      await prefs.setString(_activeThemeIdKey, theme.id);

      print('Theme configuration cached successfully');
    } catch (e) {
      print('Error caching theme configuration: $e');
    }
  }

  /// Get cached theme configuration
  static Future<ThemeConfigModel?> getCachedThemeConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Check if cache exists
      final cachedThemeJson = prefs.getString(_themeCacheKey);
      final cacheTimestamp = prefs.getString(_cacheTimestampKey);

      if (cachedThemeJson == null || cacheTimestamp == null) {
        return null;
      }

      // Check if cache is still valid
      final cacheTime = DateTime.parse(cacheTimestamp);
      final now = DateTime.now();

      if (now.difference(cacheTime) > _cacheValidDuration) {
        print('Theme cache expired, clearing...');
        await clearCache();
        return null;
      }

      // Parse and return cached theme
      final themeMap = jsonDecode(cachedThemeJson) as Map<String, dynamic>;
      final theme = _themeFromCacheMap(themeMap);

      print('Theme configuration loaded from cache');
      return theme;
    } catch (e) {
      print('Error loading cached theme configuration: $e');
      return null;
    }
  }

  /// Check if cache is valid and recent
  static Future<bool> isCacheValid() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheTimestamp = prefs.getString(_cacheTimestampKey);

      if (cacheTimestamp == null) return false;

      final cacheTime = DateTime.parse(cacheTimestamp);
      final now = DateTime.now();

      return now.difference(cacheTime) <= _cacheValidDuration;
    } catch (e) {
      print('Error checking cache validity: $e');
      return false;
    }
  }

  /// Get cached active theme ID
  static Future<String?> getCachedActiveThemeId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_activeThemeIdKey);
    } catch (e) {
      print('Error getting cached active theme ID: $e');
      return null;
    }
  }

  /// Save user session data to prevent login redirect on refresh
  static Future<void> saveUserSession({
    required String userId,
    required String userEmail,
    required String userName,
    required String userRole,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final sessionData = {
        'userId': userId,
        'userEmail': userEmail,
        'userName': userName,
        'userRole': userRole,
        'loginTime': DateTime.now().toIso8601String(),
      };

      await prefs.setString(_userSessionKey, jsonEncode(sessionData));
      print('User session saved to cache');
    } catch (e) {
      print('Error saving user session: $e');
    }
  }

  /// Get cached user session data
  static Future<Map<String, dynamic>?> getCachedUserSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionJson = prefs.getString(_userSessionKey);

      if (sessionJson == null) return null;

      final sessionData = jsonDecode(sessionJson) as Map<String, dynamic>;

      // Check if session is still valid (24 hours)
      final loginTime = DateTime.parse(sessionData['loginTime']);
      final now = DateTime.now();

      if (now.difference(loginTime) > _cacheValidDuration) {
        print('User session expired, clearing...');
        await clearUserSession();
        return null;
      }

      print('User session loaded from cache');
      return sessionData;
    } catch (e) {
      print('Error loading cached user session: $e');
      return null;
    }
  }

  /// Clear theme cache
  static Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_themeCacheKey);
      await prefs.remove(_cacheTimestampKey);
      await prefs.remove(_activeThemeIdKey);
      print('Theme cache cleared');
    } catch (e) {
      print('Error clearing theme cache: $e');
    }
  }

  /// Clear user session
  static Future<void> clearUserSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userSessionKey);
      print('User session cleared');
    } catch (e) {
      print('Error clearing user session: $e');
    }
  }

  /// Clear all cached data
  static Future<void> clearAllCache() async {
    await clearCache();
    await clearUserSession();
  }

  /// Force refresh cache (clear and mark for reload)
  static Future<void> forceRefreshCache() async {
    await clearCache();
    print('Cache marked for refresh');
  }

  /// Helper method to create ThemeConfigModel from cached data
  /// Handles ISO string dates instead of Firestore Timestamps
  static ThemeConfigModel _themeFromCacheMap(Map<String, dynamic> map) {
    return ThemeConfigModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      isActive: map['isActive'] ?? false,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      createdBy: map['createdBy'] ?? '',
      colors: CustomColorScheme.fromMap(map['colors'] ?? {}),
      logos: LogoConfig.fromMap(map['logos'] ?? {}),
      typography: TypographyConfig.fromMap(map['typography'] ?? {}),
    );
  }
}
