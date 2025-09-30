import 'package:flutter/material.dart';

/// Constant colors used as fallbacks when no theme data is available
/// or when the app is first initialized without Firebase data.
///
/// These colors represent the original EnrollEase color scheme and will be used
/// as defaults until the dynamic theme system is properly initialized.
class ConstantColors {
  // Private constructor to prevent instantiation
  ConstantColors._();

  // ============================================================================
  // PRIMARY BRAND COLORS
  // ============================================================================

  /// Primary brand color - Main green used throughout the app
  /// Used for: Primary buttons, app bars, main branding elements
  static const Color primary = Color(0xFF2E7D32); // Dark Green

  /// Secondary brand color - Blue accent
  /// Used for: Secondary actions, highlights, accents
  static const Color secondary = Color(0xFF1976D2); // Blue

  /// Accent color - Amber/yellow for special elements
  /// Used for: Warnings, special highlights, callouts
  static const Color accent = Color(0xFFFFC107); // Amber

  // ============================================================================
  // BACKGROUND COLORS
  // ============================================================================

  /// Main page background color - Olive green
  /// Used for: Scaffold backgrounds, main page areas
  static const Color background = Color(0xFF6F876C); // Olive Green

  /// Surface color - White for cards and containers
  /// Used for: Cards, dialogs, elevated surfaces
  static const Color surface = Color(0xFFFFFFFF); // White

  /// Content color - Dark olive for consistency
  /// Used for: App bars, interactive elements, content areas
  static const Color content = Color(0xFF2B3D29); // Dark Olive

  // ============================================================================
  // STATUS COLORS
  // ============================================================================

  /// Error color - Red for errors and negative states
  /// Used for: Error messages, delete actions, validation errors
  static const Color error = Color(0xFFD32F2F); // Red

  /// Success color - Green for positive states
  /// Used for: Success messages, confirmations, positive actions
  static const Color success = Color(0xFF388E3C); // Green

  /// Warning color - Orange for caution states
  /// Used for: Warning messages, caution indicators
  static const Color warning = Color(0xFFF57C00); // Orange

  // ============================================================================
  // TEXT COLORS
  // ============================================================================

  /// Primary text color - Dark gray/black
  /// Used for: Headings, important text, primary content
  static const Color textPrimary = Color(0xFF212121); // Dark Gray

  /// Secondary text color - Medium gray
  /// Used for: Descriptions, labels, secondary content
  static const Color textSecondary = Color(0xFF757575); // Medium Gray

  // ============================================================================
  // LEGACY COLOR MAPPINGS (for backward compatibility)
  // ============================================================================

  /// Legacy mapping for old CustomColors.appBarColor
  /// @deprecated Use ConstantColors.content instead
  static const Color appBarColor = content;

  /// Legacy mapping for old CustomColors.signInColor
  /// @deprecated Use ConstantColors.background instead
  static const Color signInColor = background;

  /// Legacy mapping for old CustomColors.contentColor
  /// @deprecated Use ConstantColors.content instead
  static const Color contentColor = content;

  /// Legacy mapping for old CustomColors.primaryColor
  /// @deprecated Use ConstantColors.primary instead
  static const Color primaryColor = primary;

  /// Legacy mapping for old CustomColors.bottomNavColor
  /// @deprecated Use ConstantColors.content instead
  static const Color bottomNavColor = content;

  /// Legacy mapping for old CustomColors.color1
  /// @deprecated Use ConstantColors.content instead
  static const Color color1 = content;

  // ============================================================================
  // UTILITY METHODS
  // ============================================================================

  /// Get all constant colors as a map
  /// Useful for initializing theme systems or debugging
  static Map<String, Color> getAllColors() {
    return {
      'primary': primary,
      'secondary': secondary,
      'accent': accent,
      'background': background,
      'surface': surface,
      'content': content,
      'error': error,
      'success': success,
      'warning': warning,
      'textPrimary': textPrimary,
      'textSecondary': textSecondary,
    };
  }

  /// Get constant colors as hex strings
  /// Useful for theme creation and Firebase storage
  static Map<String, String> getAllColorsAsHex() {
    return {
      'primary': '#2E7D32',
      'secondary': '#1976D2',
      'accent': '#FFC107',
      'background': '#6F876C',
      'surface': '#FFFFFF',
      'content': '#2B3D29',
      'error': '#D32F2F',
      'success': '#388E3C',
      'warning': '#F57C00',
      'textPrimary': '#212121',
      'textSecondary': '#757575',
    };
  }

  /// Create a default color scheme for new themes
  /// Returns the standard EnrollEase color palette
  static Map<String, String> getDefaultColorScheme() {
    return getAllColorsAsHex();
  }
}

/// Extension methods for easy access to constant colors
extension ConstantColorsExtension on BuildContext {
  /// Get constant primary color
  Color get constantPrimary => ConstantColors.primary;

  /// Get constant secondary color
  Color get constantSecondary => ConstantColors.secondary;

  /// Get constant accent color
  Color get constantAccent => ConstantColors.accent;

  /// Get constant background color
  Color get constantBackground => ConstantColors.background;

  /// Get constant surface color
  Color get constantSurface => ConstantColors.surface;

  /// Get constant content color
  Color get constantContent => ConstantColors.content;

  /// Get constant error color
  Color get constantError => ConstantColors.error;

  /// Get constant success color
  Color get constantSuccess => ConstantColors.success;

  /// Get constant warning color
  Color get constantWarning => ConstantColors.warning;

  /// Get constant primary text color
  Color get constantTextPrimary => ConstantColors.textPrimary;

  /// Get constant secondary text color
  Color get constantTextSecondary => ConstantColors.textSecondary;
}
