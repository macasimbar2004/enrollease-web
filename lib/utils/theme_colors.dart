import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:enrollease_web/states_management/theme_provider.dart';
import 'package:enrollease_web/utils/constant_colors.dart';

/// Theme-aware color constants that map to the dynamic theme system
/// This ensures consistency between the live preview and actual implementation
class ThemeColors {
  /// Get the current theme colors from the ThemeProvider
  static Map<String, Color> getCurrentColors(BuildContext context) {
    return Provider.of<ThemeProvider>(context, listen: false).currentColors;
  }

  /// App Bar Colors
  static Color appBarPrimary(BuildContext context) {
    return getCurrentColors(context)['content'] ?? ConstantColors.content;
  }

  static Color appBarSecondary(BuildContext context) {
    return getCurrentColors(context)['content']?.withValues(alpha: 0.9) ??
        ConstantColors.content.withValues(alpha: 0.9);
  }

  /// Primary Action Colors
  static Color primary(BuildContext context) {
    return getCurrentColors(context)['primary'] ?? ConstantColors.primary;
  }

  static Color secondary(BuildContext context) {
    return getCurrentColors(context)['secondary'] ?? ConstantColors.secondary;
  }

  static Color accent(BuildContext context) {
    return getCurrentColors(context)['accent'] ?? ConstantColors.accent;
  }

  /// Background Colors
  static Color background(BuildContext context) {
    return getCurrentColors(context)['background'] ?? ConstantColors.background;
  }

  static Color surface(BuildContext context) {
    return getCurrentColors(context)['surface'] ?? ConstantColors.surface;
  }

  /// Text Colors
  static Color textPrimary(BuildContext context) {
    return getCurrentColors(context)['textPrimary'] ??
        ConstantColors.textPrimary;
  }

  static Color textSecondary(BuildContext context) {
    return getCurrentColors(context)['textSecondary'] ??
        ConstantColors.textSecondary;
  }

  /// Status Colors
  static Color success(BuildContext context) {
    return getCurrentColors(context)['success'] ?? ConstantColors.success;
  }

  static Color error(BuildContext context) {
    return getCurrentColors(context)['error'] ?? ConstantColors.error;
  }

  static Color warning(BuildContext context) {
    return getCurrentColors(context)['warning'] ?? ConstantColors.warning;
  }

  /// Content Colors (for buttons, cards, etc.)
  static Color content(BuildContext context) {
    return getCurrentColors(context)['content'] ?? ConstantColors.content;
  }

  /// Legacy color mappings for backward compatibility
  /// These map to the new theme system
  static Color get appBarColor => ConstantColors.appBarColor; // Maps to content
  static Color get contentColor =>
      ConstantColors.contentColor; // Maps to content
  static Color get bottomNavColor =>
      ConstantColors.bottomNavColor; // Maps to content
  static Color get signInColor => ConstantColors.signInColor; // Maps to content
  static Color get color1 => ConstantColors.color1; // Maps to content
  static Color get primaryColor =>
      ConstantColors.primaryColor; // Maps to primary
}

/// Extension to make it easier to use theme colors in widgets
extension ThemeColorsExtension on BuildContext {
  /// Get the current theme colors
  Map<String, Color> get themeColors => ThemeColors.getCurrentColors(this);

  /// App Bar Colors
  Color get appBarPrimary => ThemeColors.appBarPrimary(this);
  Color get appBarSecondary => ThemeColors.appBarSecondary(this);

  /// Primary Action Colors
  Color get primaryColor => ThemeColors.primary(this);
  Color get secondaryColor => ThemeColors.secondary(this);
  Color get accentColor => ThemeColors.accent(this);

  /// Background Colors
  Color get backgroundColor => ThemeColors.background(this);
  Color get surfaceColor => ThemeColors.surface(this);

  /// Text Colors
  Color get textPrimary => ThemeColors.textPrimary(this);
  Color get textSecondary => ThemeColors.textSecondary(this);

  /// Status Colors
  Color get successColor => ThemeColors.success(this);
  Color get errorColor => ThemeColors.error(this);
  Color get warningColor => ThemeColors.warning(this);

  /// Content Colors
  Color get contentColor => ThemeColors.content(this);
}

/// Color usage documentation for developers
/// 
/// PRIMARY COLORS:
/// - primary: Main brand color for buttons, links, and primary actions
/// - secondary: Secondary brand color for accents and highlights  
/// - accent: Accent color for special elements and callouts
/// 
/// BACKGROUND COLORS:
/// - background: Main page background color
/// - surface: Card and container background color
/// 
/// TEXT COLORS:
/// - textPrimary: Main text color for headings and important content
/// - textSecondary: Secondary text color for descriptions and labels
/// 
/// STATUS COLORS:
/// - success: Success messages and positive indicators
/// - error: Error messages and negative indicators
/// - warning: Warning messages and caution indicators
/// 
/// CONTENT COLORS:
/// - content: App bar, buttons, and interactive elements
/// 
/// USAGE EXAMPLES:
/// ```dart
/// // Using extension methods (recommended)
/// Container(
///   color: context.backgroundColor,
///   child: Text(
///     'Hello',
///     style: TextStyle(color: context.textPrimary),
///   ),
/// )
/// 
/// // Using static methods
/// Container(
///   color: ThemeColors.background(context),
///   child: Text(
///     'Hello', 
///     style: TextStyle(color: ThemeColors.textPrimary(context)),
///   ),
/// )
/// ```
