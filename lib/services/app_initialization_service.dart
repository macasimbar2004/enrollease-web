import 'package:enrollease_web/states_management/theme_provider.dart';
import 'package:enrollease_web/utils/constant_colors.dart';
import 'package:enrollease_web/utils/identification_generator.dart';
import 'package:enrollease_web/model/theme_config_model.dart';
import 'package:enrollease_web/services/theme_management_service.dart';

/// Service to handle app initialization with constant colors
/// when no Firebase data exists yet
class AppInitializationService {
  /// Initialize the app with constant colors as fallback
  /// This ensures the app works even without Firebase connection
  static Future<void> initializeWithConstantColors(
      ThemeProvider themeProvider) async {
    try {
      // Try to load existing themes from Firebase
      final existingThemes = await ThemeManagementService.getAllThemes();

      if (existingThemes.isNotEmpty) {
        // If themes exist, load the first one (or default if available)
        final defaultTheme = existingThemes.firstWhere(
          (theme) => theme.name == 'Default Theme',
          orElse: () => existingThemes.first,
        );

        await themeProvider.loadTheme(defaultTheme.id);
        return;
      }
    } catch (e) {
      // If Firebase is not available or no themes exist, continue with constant colors
      print(
          'Firebase not available or no themes found, using constant colors: $e');
    }

    // Initialize with constant colors as fallback
    await _initializeConstantColorsTheme(themeProvider);
  }

  /// Create a temporary theme using constant colors
  /// This is used when Firebase is not available
  static Future<void> _initializeConstantColorsTheme(
      ThemeProvider themeProvider) async {
    // Create a temporary theme config with constant colors
    final constantColors = ConstantColors.getAllColorsAsHex();

    // Generate a unique theme ID with SDATheme prefix
    final idGenerator = IdentificationGenerator();
    final constantThemeId = 'SDATheme-${idGenerator.generateNewId()}';

    final tempTheme = ThemeConfigModel(
      id: constantThemeId,
      name: 'Constant Colors Theme',
      description:
          'Fallback theme using constant colors when Firebase is not available',
      createdBy: 'System',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isActive: true,
      colors: CustomColorScheme(
        primaryColor: constantColors['primary']!,
        secondaryColor: constantColors['secondary']!,
        accentColor: constantColors['accent']!,
        backgroundColor: constantColors['background']!,
        surfaceColor: constantColors['surface']!,
        errorColor: constantColors['error']!,
        successColor: constantColors['success']!,
        warningColor: constantColors['warning']!,
        textPrimaryColor: constantColors['textPrimary']!,
        textSecondaryColor: constantColors['textSecondary']!,
        contentColor: constantColors['content']!,
      ),
      logos: LogoConfig(
        adventistLogo: '',
        adventistEducationLogo: '',
        bannerLogo: '',
        favicon: '',
        loginBackground: '',
        defaultProfilePic: '',
      ),
      typography: TypographyConfig(
        primaryFontFamily: 'Poppins',
        secondaryFontFamily: 'Roboto',
        baseFontSize: 16.0,
        headingFontSize: 24.0,
        subheadingFontSize: 18.0,
        bodyFontSize: 14.0,
        captionFontSize: 12.0,
      ),
    );

    // Set the theme provider to use constant colors
    themeProvider.setConstantColorsTheme(tempTheme);
  }

  /// Check if the app is using constant colors (no Firebase connection)
  static bool isUsingConstantColors(ThemeProvider themeProvider) {
    final themeId = themeProvider.currentTheme?.id ?? '';
    return themeId.startsWith('SDATheme-') &&
        themeProvider.currentTheme?.name == 'Constant Colors Theme';
  }

  /// Get the current color scheme (either from Firebase or constant colors)
  static Map<String, String> getCurrentColorScheme(
      ThemeProvider themeProvider) {
    if (isUsingConstantColors(themeProvider)) {
      return ConstantColors.getAllColorsAsHex();
    } else {
      // Convert current theme colors to hex strings
      final colors = themeProvider.currentTheme?.colors;
      if (colors != null) {
        return {
          'primary': colors.primaryColor,
          'secondary': colors.secondaryColor,
          'accent': colors.accentColor,
          'background': colors.backgroundColor,
          'surface': colors.surfaceColor,
          'error': colors.errorColor,
          'success': colors.successColor,
          'warning': colors.warningColor,
          'textPrimary': colors.textPrimaryColor,
          'textSecondary': colors.textSecondaryColor,
          'content': colors.contentColor,
        };
      }
    }
    return ConstantColors.getAllColorsAsHex();
  }
}
