import 'package:flutter/material.dart';
import 'package:enrollease_web/model/theme_config_model.dart';
import 'package:enrollease_web/services/theme_management_service.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeConfigModel? _currentTheme;
  bool _isLoading = false;
  String? _error;

  ThemeConfigModel? get currentTheme => _currentTheme;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Initialize the theme provider by loading the active theme from Firebase
  Future<void> initialize() async {
    _setLoading(true);
    try {
      _currentTheme = await ThemeManagementService.getActiveTheme();
      if (_currentTheme == null) {
        _error = 'No active theme found';
      } else {
        _error = null;
        print('Theme loaded from Firebase');
      }
    } catch (e) {
      _error = 'Failed to load theme: $e';
      _currentTheme = null;
    } finally {
      _setLoading(false);
    }
  }

  /// Set a constant colors theme (used when Firebase is not available)
  void setConstantColorsTheme(ThemeConfigModel theme) {
    _currentTheme = theme;
    _error = null;
    notifyListeners();
  }

  /// Load and activate a specific theme
  Future<bool> loadTheme(String themeId) async {
    _setLoading(true);
    try {
      final success = await ThemeManagementService.activateTheme(themeId);
      if (success) {
        await initialize(); // Reload the active theme
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Failed to load theme: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Create a new theme
  Future<String?> createTheme({
    required String id,
    required String name,
    required String description,
    required String createdBy,
    required CustomColorScheme colors,
    required LogoConfig logos,
    required TypographyConfig typography,
  }) async {
    _setLoading(true);
    try {
      final themeId = await ThemeManagementService.createTheme(
        id: id,
        name: name,
        description: description,
        createdBy: createdBy,
        colors: colors,
        logos: logos,
        typography: typography,
      );
      return themeId;
    } catch (e) {
      _error = 'Failed to create theme: $e';
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Update the current theme
  Future<bool> updateCurrentTheme({
    String? name,
    String? description,
    CustomColorScheme? colors,
    LogoConfig? logos,
    TypographyConfig? typography,
  }) async {
    if (_currentTheme == null) return false;

    _setLoading(true);
    try {
      final success = await ThemeManagementService.updateTheme(
        themeId: _currentTheme!.id,
        name: name,
        description: description,
        colors: colors,
        logos: logos,
        typography: typography,
      );

      if (success) {
        await initialize(); // Reload the theme
      }
      return success;
    } catch (e) {
      _error = 'Failed to update theme: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Get Flutter Color from hex string
  Color getColorFromHex(String hexColor) {
    try {
      hexColor = hexColor.replaceAll('#', '');
      if (hexColor.length == 6) {
        hexColor = 'FF$hexColor'; // Add alpha if not present
      }
      return Color(int.parse(hexColor, radix: 16));
    } catch (e) {
      return Colors.green; // Default color
    }
  }

  /// Get the current theme's colors as Flutter Colors
  Map<String, Color> get currentColors {
    if (_currentTheme == null) {
      return _getDefaultColors();
    }

    final colorScheme = _currentTheme!.colors;
    return {
      'primary': getColorFromHex(colorScheme.primaryColor),
      'secondary': getColorFromHex(colorScheme.secondaryColor),
      'accent': getColorFromHex(colorScheme.accentColor),
      'background': getColorFromHex(colorScheme.backgroundColor),
      'surface': getColorFromHex(colorScheme.surfaceColor),
      'error': getColorFromHex(colorScheme.errorColor),
      'success': getColorFromHex(colorScheme.successColor),
      'warning': getColorFromHex(colorScheme.warningColor),
      'textPrimary': getColorFromHex(colorScheme.textPrimaryColor),
      'textSecondary': getColorFromHex(colorScheme.textSecondaryColor),
      'content': getColorFromHex(colorScheme.contentColor),
    };
  }

  /// Get default colors when no theme is loaded
  Map<String, Color> _getDefaultColors() {
    return {
      'primary': Colors.green,
      'secondary': Colors.blue,
      'accent': Colors.amber,
      'background': Colors.grey.shade100,
      'surface': Colors.white,
      'error': Colors.red,
      'success': Colors.green,
      'warning': Colors.orange,
      'textPrimary': Colors.black87,
      'textSecondary': Colors.grey.shade600,
      'content': Colors.green.shade400,
    };
  }

  /// Get logo URL for a specific logo type
  String? getLogoUrl(String logoType) {
    if (_currentTheme == null) return null;

    String? fileId;
    switch (logoType) {
      case 'adventist':
        fileId = _currentTheme!.logos.adventistLogo;
        break;
      case 'adventistEducation':
        fileId = _currentTheme!.logos.adventistEducationLogo;
        break;
      case 'banner':
        fileId = _currentTheme!.logos.bannerLogo;
        break;
      case 'favicon':
        fileId = _currentTheme!.logos.favicon;
        break;
      case 'loginBackground':
        fileId = _currentTheme!.logos.loginBackground;
        break;
      case 'defaultProfilePic':
        fileId = _currentTheme!.logos.defaultProfilePic;
        break;
    }

    if (fileId != null && fileId.isNotEmpty) {
      return ThemeManagementService.getLogoUrl(fileId);
    }
    return null;
  }

  /// Get typography configuration
  TypographyConfig get currentTypography {
    return _currentTheme?.typography ??
        TypographyConfig(
          primaryFontFamily: 'Poppins',
          secondaryFontFamily: 'Roboto',
          baseFontSize: 16.0,
          headingFontSize: 24.0,
          subheadingFontSize: 18.0,
          bodyFontSize: 14.0,
          captionFontSize: 12.0,
        );
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Force refresh theme from Firebase
  Future<void> refreshTheme() async {
    _setLoading(true);
    try {
      // Load fresh theme from Firebase
      _currentTheme = await ThemeManagementService.getActiveTheme();
      if (_currentTheme == null) {
        _error = 'No active theme found';
      } else {
        _error = null;
        print('Theme refreshed from Firebase');
      }
    } catch (e) {
      _error = 'Failed to refresh theme: $e';
      _currentTheme = null;
    } finally {
      _setLoading(false);
    }
  }
}
