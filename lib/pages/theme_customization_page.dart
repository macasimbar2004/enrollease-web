import 'package:enrollease_web/utils/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:enrollease_web/model/theme_config_model.dart';
import 'package:enrollease_web/states_management/theme_provider.dart';
import 'package:enrollease_web/states_management/footer_config_provider.dart';
import 'package:enrollease_web/model/footer_config_model.dart';
import 'package:enrollease_web/services/theme_management_service.dart';
import 'package:enrollease_web/widgets/custom_appbar.dart';
import 'package:enrollease_web/widgets/custom_body.dart';
import 'package:enrollease_web/widgets/custom_toast.dart';
import 'package:enrollease_web/utils/constant_colors.dart';
import 'package:enrollease_web/utils/identification_generator.dart';
import 'package:enrollease_web/services/theme_cache_service.dart';

class ThemeCustomizationPage extends StatefulWidget {
  final String? userId;
  final String? userName;

  const ThemeCustomizationPage({
    super.key,
    this.userId,
    this.userName,
  });

  @override
  State<ThemeCustomizationPage> createState() => _ThemeCustomizationPageState();
}

class _ThemeCustomizationPageState extends State<ThemeCustomizationPage>
    with TickerProviderStateMixin {
  late TabController _tabController;

  // Form controllers
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Color controllers
  final Map<String, TextEditingController> _colorControllers = {};

  // Logo upload states
  final Map<String, Uint8List?> _logoFiles = {};
  final Map<String, String> _logoFileNames = {};

  // Color picker states
  Color _currentPickerColor = Colors.green;
  String? _currentColorField;

  // Footer configuration controllers
  final _appNameController = TextEditingController();
  final _privacyPolicyContentController = TextEditingController();
  final _termsAndConditionsContentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _initializeColorControllers();
    _initializeFooterControllers();

    // Initialize theme provider and create default theme if needed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeThemeProvider();
      _initializeFooterProvider();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh colors when the page becomes visible
    // This ensures the UI shows the current theme colors
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCurrentThemeColors();
    });
  }

  Future<void> _initializeThemeProvider() async {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    await themeProvider.initialize();

    // If no active theme exists, create a default one
    if (themeProvider.currentTheme == null) {
      await _createDefaultTheme(themeProvider);
    }

    // Load current theme colors into the controllers
    _loadCurrentThemeColors();
  }

  Future<void> _createDefaultTheme(ThemeProvider themeProvider) async {
    try {
      // Check if a default theme already exists
      final existingThemes = await ThemeManagementService.getAllThemes();
      final defaultTheme = existingThemes.firstWhere(
        (theme) => theme.name == 'Default Theme',
        orElse: () => throw StateError('No default theme found'),
      );

      // If default theme exists, activate it
      await themeProvider.loadTheme(defaultTheme.id);
      setState(() {}); // Refresh the UI
    } catch (e) {
      // No default theme exists, create one
      final userName = widget.userName ?? 'System';

      // Generate a unique theme ID with SDATheme prefix
      final idGenerator = IdentificationGenerator();
      final defaultThemeId = 'SDATheme-${idGenerator.generateNewId()}';

      final themeId = await themeProvider.createTheme(
        id: defaultThemeId,
        name: 'Default Theme',
        description: 'Default theme configuration for the application',
        createdBy: userName,
        colors: CustomColorScheme(
          primaryColor: ConstantColors.getAllColorsAsHex()['primary']!,
          secondaryColor: ConstantColors.getAllColorsAsHex()['secondary']!,
          accentColor: ConstantColors.getAllColorsAsHex()['accent']!,
          backgroundColor: ConstantColors.getAllColorsAsHex()['background']!,
          surfaceColor: ConstantColors.getAllColorsAsHex()['surface']!,
          errorColor: ConstantColors.getAllColorsAsHex()['error']!,
          successColor: ConstantColors.getAllColorsAsHex()['success']!,
          warningColor: ConstantColors.getAllColorsAsHex()['warning']!,
          textPrimaryColor: ConstantColors.getAllColorsAsHex()['textPrimary']!,
          textSecondaryColor:
              ConstantColors.getAllColorsAsHex()['textSecondary']!,
          contentColor: ConstantColors.getAllColorsAsHex()['content']!,
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

      if (themeId != null) {
        // Activate the default theme
        await themeProvider.loadTheme(themeId);
        setState(() {}); // Refresh the UI
      }
    }
  }

  void _initializeColorControllers() {
    final defaultColors = {
      'primary': '#2E7D32',
      'secondary': '#1976D2',
      'accent': '#FFC107',
      'background': '#4CAF50',
      'surface': '#FFFFFF',
      'error': '#D32F2F',
      'success': '#388E3C',
      'warning': '#F57C00',
      'textPrimary': '#212121',
      'textSecondary': '#757575',
      'content': '#4CAF50',
    };

    for (var entry in defaultColors.entries) {
      _colorControllers[entry.key] = TextEditingController(text: entry.value);
    }
  }

  void _loadCurrentThemeColors({bool forceUpdate = false}) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    if (themeProvider.currentTheme != null) {
      final colors = themeProvider.currentTheme!.colors;

      // Always update controllers to reflect the current theme colors
      // This ensures the UI shows the actual colors being used
      _colorControllers['primary']?.text = colors.primaryColor;
      _colorControllers['secondary']?.text = colors.secondaryColor;
      _colorControllers['accent']?.text = colors.accentColor;
      _colorControllers['background']?.text = colors.backgroundColor;
      _colorControllers['surface']?.text = colors.surfaceColor;
      _colorControllers['error']?.text = colors.errorColor;
      _colorControllers['success']?.text = colors.successColor;
      _colorControllers['warning']?.text = colors.warningColor;
      _colorControllers['textPrimary']?.text = colors.textPrimaryColor;
      _colorControllers['textSecondary']?.text = colors.textSecondaryColor;
      _colorControllers['content']?.text = colors.contentColor;
    }
  }

  void _initializeFooterControllers() {
    // Initialize with default values
    _appNameController.text = 'EnrollEase';
    _privacyPolicyContentController.text = '''## EnrollEase Privacy Policy

Effective Date: December 5, 2024
Last Updated: December 5, 2024

Welcome to EnrollEase! Your privacy is important to us, and we are committed to protecting your personal information. This Privacy Policy explains how we collect, use, and safeguard your information in compliance with the Data Privacy Act of 2012 (Republic Act No. 10173) of the Philippines.

1. Information We Collect
	We collect personal, educational, payment, and system usage data to provide and improve our services.

2. How We Use Your Information
	We use your data for enrollment, payment processing, communication, app improvement, and legal compliance.

3. Data Sharing
	We share data only with schools, service providers, and legal authorities when necessary.

4. Data Security
	Your data is protected using encryption, secure payment gateways, and regular audits.

5. Data Retention
	We keep data only as long as needed for service or legal purposes and delete it securely after.

6. Your Rights
	You can access, correct, object, delete, or request a copy of your data. You may also file complaints with the National Privacy Commission (NPC).

7. Children's Privacy
	Parental or guardian consent is required for users under 18.

8. Policy Updates
	We will notify you of changes through the app or website.

9. Contact Us
	For inquiries, concerns, or data requests, please contact:

Data Protection Officer (DPO):
	ApexVision
	apexvision6@gmail.com
	+639816188964
	Oroquieta City, Misamis Occidental, Philipines

National Privacy Commission:
https://privacy.gov.ph/''';

    _termsAndConditionsContentController.text =
        '''# EnrollEase Terms and Conditions

## 1. Introduction

Welcome to EnrollEase, a web application provided by ApexVision. These Terms and Conditions govern your use of our website located at https://enrollease-4a6cd.web.app/. By accessing or using EnrollEase, you agree to be bound by these terms.

## 2. Eligibility

- You must be at least 18 years old to use this website.
- Users represent and warrant that they have the legal capacity to enter into these terms.

## 3. Website Purpose

EnrollEase is an administrative service platform designed to provide registration and management services for Oroquieta SDA School. The website is intended solely for authorized personnel involved in school administration.

## 4. User Responsibilities

- Users must provide accurate and complete information when using the platform.
- Users are responsible for maintaining the confidentiality of their account credentials.
- Any misuse of the platform or unauthorized access is strictly prohibited.

## 5. Data Privacy and Protection

- We collect and process user data in accordance with our Privacy Policy.
- Personal information is handled with strict confidentiality and used only for administrative purposes.
- Data is processed exclusively within Oroquieta, Misamis Occidental, Philippines.

## 6. Intellectual Property

- All content, design, and functionality of EnrollEase are the exclusive property of ApexVision.
- Users are prohibited from reproducing, distributing, or creating derivative works without explicit written permission.

## 7. Limitations of Service

- EnrollEase is provided "as is" without any warranties.
- We reserve the right to modify, suspend, or discontinue the service at any time.
- No financial transactions are processed through this platform.

## 8. User Conduct

Users agree to:
- Use the platform only for its intended administrative purposes
- Respect the privacy and rights of other users
- Not engage in any activities that might compromise the system's integrity
- Comply with all applicable local and national regulations

## 9. Disclaimer of Liability

ApexVision shall not be liable for:
- Any direct, indirect, or consequential damages arising from platform use
- Loss of data or interruption of services
- Any actions taken by users based on information provided on the platform

## 10. Geographical Limitation

This service is specifically designed for use in Oroquieta, Misamis Occidental, Philippines, and is subject to local jurisdictional laws.

## 11. Contact Information

For any questions or concerns regarding these Terms and Conditions, please contact:
- Email: apexvision.support@gmail.com
- Address: Oroquieta, Misamis Occidental, Philippines

## 12. Modifications to Terms

ApexVision reserves the right to update these Terms and Conditions at any time. Users are encouraged to review the terms periodically.

## 13. Acceptance of Terms

By continuing to use EnrollEase, you acknowledge that you have read, understood, and agree to be bound by these Terms and Conditions.

*Last Updated: December 2024*''';
  }

  Future<void> _initializeFooterProvider() async {
    final footerProvider =
        Provider.of<FooterConfigProvider>(context, listen: false);
    await footerProvider.initialize();

    // Update controllers with current footer config
    if (footerProvider.footerConfig != null) {
      final config = footerProvider.footerConfig!;
      _appNameController.text = config.appName;
      _privacyPolicyContentController.text = config.privacyPolicyContent;
      _termsAndConditionsContentController.text =
          config.termsAndConditionsContent;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    for (var controller in _colorControllers.values) {
      controller.dispose();
    }
    _appNameController.dispose();
    _privacyPolicyContentController.dispose();
    _termsAndConditionsContentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Theme Customization',
        userId: widget.userId,
        userName: widget.userName,
      ),
      body: CustomBody(
        child: Column(
          children: [
            // Enhanced Header with animated gradient background
            Consumer<ThemeProvider>(
              builder: (context, themeProvider, child) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        themeProvider.currentColors['primary']!
                            .withValues(alpha: 0.1),
                        themeProvider.currentColors['secondary']!
                            .withValues(alpha: 0.05),
                        themeProvider.currentColors['accent']!
                            .withValues(alpha: 0.08),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: themeProvider.currentColors['primary']!
                          .withValues(alpha: 0.2),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: themeProvider.currentColors['primary']!
                            .withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Header Title with Icon
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  themeProvider.currentColors['primary']!,
                                  themeProvider.currentColors['primary']!
                                      .withValues(alpha: 0.8),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: themeProvider.currentColors['primary']!
                                      .withValues(alpha: 0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.palette,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Theme Customization',
                                  style: GoogleFonts.poppins(
                                    color: themeProvider
                                        .currentColors['textPrimary'],
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Customize your app\'s appearance and branding',
                                  style: GoogleFonts.poppins(
                                    color: themeProvider
                                        .currentColors['textSecondary'],
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Enhanced Tab bar with glassmorphism effect
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 15,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: TabBar(
                          controller: _tabController,
                          indicator: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                themeProvider.currentColors['primary']!,
                                themeProvider.currentColors['primary']!
                                    .withValues(alpha: 0.8),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: themeProvider.currentColors['primary']!
                                    .withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          indicatorSize: TabBarIndicatorSize.tab,
                          labelColor: Colors.white,
                          unselectedLabelColor:
                              themeProvider.currentColors['textPrimary'],
                          labelStyle: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                          unselectedLabelStyle: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                          tabs: const [
                            Tab(
                                text: 'Colors',
                                icon: Icon(Icons.palette_outlined)),
                            Tab(
                                text: 'Logos',
                                icon: Icon(Icons.image_outlined)),
                            Tab(
                                text: 'Themes',
                                icon: Icon(Icons.style_outlined)),
                            Tab(
                                text: 'Footer',
                                icon: Icon(Icons.text_fields_outlined)),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            // Tab content - Use LayoutBuilder to get available height
            LayoutBuilder(
              builder: (context, constraints) {
                // Calculate available height (screen height - app bar - header - tab bar - margins)
                final availableHeight = MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    kToolbarHeight - // App bar height
                    200; // Header + tab bar + margins

                return SizedBox(
                  height:
                      availableHeight.clamp(400.0, 800.0), // Min 400, Max 800
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildColorsTab(),
                      _buildLogosTab(),
                      _buildThemesTab(),
                      _buildFooterTab(),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeInfo(ThemeConfigModel theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          theme.name,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          theme.description,
          style: GoogleFonts.poppins(color: Colors.white70),
        ),
        const SizedBox(height: 8),
        Text(
          'Created: ${theme.createdAt.toString().split(' ')[0]}',
          style: GoogleFonts.poppins(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildColorsTab() {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.95),
                  themeProvider.currentColors['primary']!
                      .withValues(alpha: 0.02),
                  Colors.white.withValues(alpha: 0.95),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: themeProvider.currentColors['primary']!
                    .withValues(alpha: 0.1),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: themeProvider.currentColors['primary']!
                      .withValues(alpha: 0.1),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Enhanced Header with animated icon
                Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            themeProvider.currentColors['primary']!,
                            themeProvider.currentColors['primary']!
                                .withValues(alpha: 0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: themeProvider.currentColors['primary']!
                                .withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.palette_outlined,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Color Configuration',
                            style: GoogleFonts.poppins(
                              color: themeProvider.currentColors['textPrimary'],
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Customize your application\'s color scheme with live previews',
                            style: GoogleFonts.poppins(
                              color:
                                  themeProvider.currentColors['textSecondary'],
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Live Preview Section
                _buildLivePreviewSection(themeProvider),
                const SizedBox(height: 24),
                // Color categories with live preview
                _buildColorCategory(
                  'Primary Colors',
                  'Main brand colors used throughout the app',
                  [
                    'primary',
                    'secondary',
                    'accent',
                  ],
                  themeProvider,
                ),
                const SizedBox(height: 24),

                _buildColorCategory(
                  'Background Colors',
                  'Page backgrounds and surface colors',
                  [
                    'background',
                    'surface',
                  ],
                  themeProvider,
                ),
                const SizedBox(height: 24),

                _buildColorCategory(
                  'Status Colors',
                  'Success, error, and warning indicators',
                  [
                    'success',
                    'error',
                    'warning',
                  ],
                  themeProvider,
                ),
                const SizedBox(height: 24),

                _buildColorCategory(
                  'Text Colors',
                  'Text and content colors',
                  [
                    'textPrimary',
                    'textSecondary',
                  ],
                  themeProvider,
                ),
                const SizedBox(height: 24),

                _buildColorCategory(
                  'UI Elements',
                  'Interactive elements and content areas',
                  [
                    'content',
                  ],
                  themeProvider,
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        themeProvider.currentColors['primary']!,
                        themeProvider.currentColors['primary']!
                            .withValues(alpha: 0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: themeProvider.currentColors['primary']!
                            .withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Consumer<ThemeProvider>(
                    builder: (context, themeProvider, child) {
                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: themeProvider.isLoading ? null : _updateColors,
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 32, vertical: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (themeProvider.isLoading) ...[
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Updating...',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                ] else ...[
                                  const Icon(
                                    Icons.save_outlined,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Update Colors',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildColorCategory(String title, String description,
      List<String> colorKeys, ThemeProvider themeProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (themeProvider.currentColors['primary'] ?? Colors.blue)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getCategoryIcon(title),
                  color: themeProvider.currentColors['primary'] ?? Colors.blue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        color: Colors.black87,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      description,
                      style: GoogleFonts.poppins(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Color fields for this category
          ...colorKeys.map(
              (colorKey) => _buildIntuitiveColorField(colorKey, themeProvider)),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Primary Colors':
        return Icons.palette;
      case 'Background Colors':
        return Icons.layers;
      case 'Status Colors':
        return Icons.info_outline;
      case 'Text Colors':
        return Icons.text_fields;
      case 'UI Elements':
        return Icons.widgets;
      default:
        return Icons.color_lens;
    }
  }

  Widget _buildLivePreviewSection(ThemeProvider themeProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            themeProvider.currentColors['primary']!.withValues(alpha: 0.05),
            themeProvider.currentColors['secondary']!.withValues(alpha: 0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: themeProvider.currentColors['primary']!.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.visibility,
                color: themeProvider.currentColors['primary'],
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Live Preview',
                style: GoogleFonts.poppins(
                  color: themeProvider.currentColors['textPrimary'],
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'See how your colors look in real UI elements',
            style: GoogleFonts.poppins(
              color: themeProvider.currentColors['textSecondary'],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),

          // Mini UI Preview
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: themeProvider.currentColors['background'],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: themeProvider.currentColors['primary']!
                    .withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                // Mini App Bar
                Container(
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        themeProvider.currentColors['content']!,
                        themeProvider.currentColors['content']!
                            .withValues(alpha: 0.9),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      'App Bar',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Mini Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: themeProvider.currentColors['primary'],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Primary',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: themeProvider.currentColors['secondary'],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Secondary',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: themeProvider.currentColors['accent'],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Accent',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Mini Text Examples
                Text(
                  'Primary Text',
                  style: GoogleFonts.poppins(
                    color: themeProvider.currentColors['textPrimary'],
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Secondary Text',
                  style: GoogleFonts.poppins(
                    color: themeProvider.currentColors['textSecondary'],
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntuitiveColorField(
      String colorName, ThemeProvider themeProvider) {
    final controller = _colorControllers[colorName]!;
    Color currentColor;
    try {
      final hexText = controller.text.replaceAll('#', '');
      if (hexText.isEmpty || hexText.length < 6) {
        currentColor = Colors.grey; // Default color if invalid
      } else {
        currentColor = Color(int.parse('FF$hexText', radix: 16));
      }
    } catch (e) {
      currentColor = Colors.grey; // Default color if parsing fails
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            currentColor.withValues(alpha: 0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: currentColor.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: currentColor.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Color name and description
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getColorDisplayName(colorName),
                      style: GoogleFonts.poppins(
                        color: Colors.black87,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getColorDescription(colorName),
                      style: GoogleFonts.poppins(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Color preview with picker
              GestureDetector(
                onTap: () => _showColorPicker(context, colorName, controller),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        currentColor,
                        currentColor.withValues(alpha: 0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: currentColor.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.palette,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Live preview of where this color is used
          _buildColorUsagePreview(colorName, currentColor, themeProvider),
          const SizedBox(height: 12),

          // Hex input
          Row(
            children: [
              Text(
                'Hex: ',
                style: GoogleFonts.poppins(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Expanded(
                child: TextField(
                  controller: controller,
                  style: GoogleFonts.poppins(
                    color: Colors.black87,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: '#000000',
                    hintStyle: GoogleFonts.poppins(
                      color: Colors.grey.shade400,
                      fontSize: 12,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: themeProvider.currentColors['primary'] ??
                            Colors.blue,
                        width: 2,
                      ),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getColorDisplayName(String colorName) {
    switch (colorName) {
      case 'primary':
        return 'Primary Color';
      case 'secondary':
        return 'Secondary Color';
      case 'accent':
        return 'Accent Color';
      case 'background':
        return 'Background Color';
      case 'surface':
        return 'Surface Color';
      case 'success':
        return 'Success Color';
      case 'error':
        return 'Error Color';
      case 'warning':
        return 'Warning Color';
      case 'textPrimary':
        return 'Primary Text';
      case 'textSecondary':
        return 'Secondary Text';
      case 'appBar':
        return 'App Bar Color';
      case 'content':
        return 'Content Color';
      default:
        return colorName;
    }
  }

  String _getColorDescription(String colorName) {
    switch (colorName) {
      case 'primary':
        return 'Main brand color for buttons, links, and primary actions';
      case 'secondary':
        return 'Secondary brand color for accents and highlights';
      case 'accent':
        return 'Accent color for special elements and callouts';
      case 'background':
        return 'Main page background color';
      case 'surface':
        return 'Card and container background color';
      case 'success':
        return 'Success messages and positive indicators';
      case 'error':
        return 'Error messages and negative indicators';
      case 'warning':
        return 'Warning messages and caution indicators';
      case 'textPrimary':
        return 'Main text color for headings and important content';
      case 'textSecondary':
        return 'Secondary text color for descriptions and labels';
      case 'appBar':
        return 'App bar and header background color';
      case 'content':
        return 'App bar, buttons, and interactive elements';
      default:
        return 'Custom color for application theming';
    }
  }

  Widget _buildColorUsagePreview(
      String colorName, Color color, ThemeProvider themeProvider) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Preview:',
            style: GoogleFonts.poppins(
              color: Colors.grey.shade600,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          _buildUsageExample(colorName, color),
        ],
      ),
    );
  }

  Widget _buildUsageExample(String colorName, Color color) {
    switch (colorName) {
      case 'primary':
        return _buildPrimaryColorPreview(color);
      case 'secondary':
        return _buildSecondaryColorPreview(color);
      case 'accent':
        return _buildAccentColorPreview(color);
      case 'background':
        return _buildBackgroundPreview(color);
      case 'surface':
        return _buildSurfacePreview(color);
      case 'textPrimary':
        return _buildTextPrimaryPreview(color);
      case 'textSecondary':
        return _buildTextSecondaryPreview(color);
      case 'success':
        return _buildSuccessPreview(color);
      case 'error':
        return _buildErrorPreview(color);
      case 'warning':
        return _buildWarningPreview(color);
      case 'content':
        return _buildContentPreview(color);
      default:
        return Container(
          width: double.infinity,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        );
    }
  }

  Widget _buildPrimaryColorPreview(Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Primary Actions:',
            style: GoogleFonts.poppins(
              color: Colors.grey.shade700,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              // Login Button
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  'LOGIN',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Save Button
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Save',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Icon
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(
                  Icons.add,
                  color: color,
                  size: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSecondaryColorPreview(Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Secondary Elements:',
            style: GoogleFonts.poppins(
              color: Colors.grey.shade700,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              // Secondary Button
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: color, width: 1),
                ),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.poppins(
                    color: color,
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Link
              Text(
                'View Details',
                style: GoogleFonts.poppins(
                  color: color,
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.underline,
                ),
              ),
              const SizedBox(width: 8),
              // Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'New',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAccentColorPreview(Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Accent Highlights:',
            style: GoogleFonts.poppins(
              color: Colors.grey.shade700,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              // Star Rating
              Row(
                children: List.generate(
                  3,
                  (index) => Icon(
                    Icons.star,
                    color: color,
                    size: 12,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Notification Dot
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              // Progress Bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: 0.7,
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundPreview(Color color) {
    return Container(
      width: double.infinity,
      height: 40,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Stack(
        children: [
          // Background pattern
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          Positioned(
            bottom: 8,
            right: 8,
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          Center(
            child: Text(
              'Page Background',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSurfacePreview(Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cards & Containers:',
            style: GoogleFonts.poppins(
              color: Colors.grey.shade700,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              // Card 1
              Container(
                width: 50,
                height: 30,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'Card',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Card 2
              Container(
                width: 40,
                height: 25,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: Text(
                    'Box',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 7,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextPrimaryPreview(Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Primary Text:',
            style: GoogleFonts.poppins(
              color: Colors.grey.shade700,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Dashboard Overview',
            style: GoogleFonts.poppins(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Student Management System',
            style: GoogleFonts.poppins(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextSecondaryPreview(Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Secondary Text:',
            style: GoogleFonts.poppins(
              color: Colors.grey.shade700,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Last updated: 2 hours ago',
            style: GoogleFonts.poppins(
              color: color,
              fontSize: 9,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Total students: 1,234',
            style: GoogleFonts.poppins(
              color: color,
              fontSize: 9,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessPreview(Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Success Messages:',
            style: GoogleFonts.poppins(
              color: Colors.grey.shade700,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: color, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: color,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Saved successfully',
                      style: GoogleFonts.poppins(
                        color: color,
                        fontSize: 8,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorPreview(Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Error Messages:',
            style: GoogleFonts.poppins(
              color: Colors.grey.shade700,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: color, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error,
                      color: color,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Please try again',
                      style: GoogleFonts.poppins(
                        color: color,
                        fontSize: 8,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWarningPreview(Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Warning Messages:',
            style: GoogleFonts.poppins(
              color: Colors.grey.shade700,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: color, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.warning,
                      color: color,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Please review',
                      style: GoogleFonts.poppins(
                        color: color,
                        fontSize: 8,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContentPreview(Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'App Bar & Interactive Elements:',
            style: GoogleFonts.poppins(
              color: Colors.grey.shade700,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Column(
            children: [
              // App Bar Preview
              Container(
                height: 30,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withValues(alpha: 0.9)],
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: Text(
                    'App Bar',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  // Content Button
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Submit',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Content Background
                  Container(
                    width: 30,
                    height: 20,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Center(
                      child: Text(
                        'Area',
                        style: GoogleFonts.poppins(
                          color: color,
                          fontSize: 7,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildColorField(String colorName, TextEditingController controller) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final currentColor = _getColorFromHex(controller.text);

        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.grey.shade200,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getColorDisplayName(colorName),
                          style: GoogleFonts.poppins(
                            color: Colors.black87,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Click the color preview to open color picker',
                          style: GoogleFonts.poppins(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Color preview with picker button
                  GestureDetector(
                    onTap: () =>
                        _showColorPicker(context, colorName, controller),
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: currentColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.palette,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Hex value display and edit
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      style: GoogleFonts.poppins(
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Hex Value',
                        labelStyle: GoogleFonts.poppins(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                        hintText: '#000000',
                        hintStyle: GoogleFonts.poppins(
                          color: Colors.grey.shade500,
                          fontSize: 14,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: themeProvider.currentColors['primary']!,
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Quick color picker button
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          themeProvider.currentColors['primary']!,
                          themeProvider.currentColors['primary']!
                              .withValues(alpha: 0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          _showColorPicker(context, colorName, controller),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(
                        Icons.color_lens,
                        color: Colors.white,
                        size: 18,
                      ),
                      label: Text(
                        'Pick Color',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLogosTab() {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.95),
                  themeProvider.currentColors['primary']!
                      .withValues(alpha: 0.02),
                  Colors.white.withValues(alpha: 0.95),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: themeProvider.currentColors['primary']!
                    .withValues(alpha: 0.1),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: themeProvider.currentColors['primary']!
                      .withValues(alpha: 0.1),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Enhanced Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            themeProvider.currentColors['primary']!,
                            themeProvider.currentColors['primary']!
                                .withValues(alpha: 0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: themeProvider.currentColors['primary']!
                                .withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.image_outlined,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Logo Configuration',
                            style: GoogleFonts.poppins(
                              color: themeProvider.currentColors['textPrimary'],
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Upload and manage your application logos and images',
                            style: GoogleFonts.poppins(
                              color:
                                  themeProvider.currentColors['textSecondary'],
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Logo upload fields
                ..._buildLogoUploadFields(),
                const SizedBox(height: 24),

                // Enhanced Update Button
                Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          themeProvider.currentColors['primary']!,
                          themeProvider.currentColors['primary']!
                              .withValues(alpha: 0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: themeProvider.currentColors['primary']!
                              .withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _updateLogos,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 16),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.upload_outlined,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Update Logos',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildLogoUploadFields() {
    final logoTypes = [
      {'key': 'schoolLogo', 'name': 'School Logo'},
      {'key': 'adventistLogo', 'name': 'Adventist Logo'},
      {'key': 'adventistEducationLogo', 'name': 'Adventist Education Logo'},
      {'key': 'bannerLogo', 'name': 'Banner Logo'},
      {'key': 'favicon', 'name': 'Favicon'},
      {'key': 'loginBackground', 'name': 'Login Background'},
      {'key': 'defaultProfilePic', 'name': 'Default Profile Picture'},
    ];

    return logoTypes
        .map((logoType) => _buildLogoUploadField(
              logoType['key']!,
              logoType['name']!,
            ))
        .toList();
  }

  Widget _buildLogoUploadField(String logoKey, String displayName) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final currentLogoUrl = themeProvider.getLogoUrl(logoKey);

        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  themeProvider.currentColors['primary']!
                      .withValues(alpha: 0.02),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _logoFileNames[logoKey] != null
                    ? themeProvider.currentColors['primary']!
                        .withValues(alpha: 0.3)
                    : Colors.grey.shade300,
                width: _logoFileNames[logoKey] != null ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: _logoFileNames[logoKey] != null
                      ? themeProvider.currentColors['primary']!
                          .withValues(alpha: 0.1)
                      : Colors.black.withValues(alpha: 0.05),
                  blurRadius: _logoFileNames[logoKey] != null ? 12 : 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with name and current logo preview
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        displayName,
                        style: GoogleFonts.poppins(
                          color: themeProvider.currentColors['textPrimary']!,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    // Current logo preview
                    if (currentLogoUrl != null && currentLogoUrl.isNotEmpty)
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            currentLogoUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.image_not_supported,
                                color: Colors.grey.shade400,
                                size: 20,
                              );
                            },
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                // File selection info
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _logoFileNames[logoKey] ?? 'No new file selected',
                        style: GoogleFonts.poppins(
                          color: _logoFileNames[logoKey] != null
                              ? themeProvider.currentColors['primary']!
                              : themeProvider.currentColors['textSecondary']!,
                          fontSize: 12,
                          fontWeight: _logoFileNames[logoKey] != null
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            themeProvider.currentColors['primary']!,
                            themeProvider.currentColors['primary']!
                                .withValues(alpha: 0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: themeProvider.currentColors['primary']!
                                .withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _pickLogoFile(logoKey),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.upload_file,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Choose File',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTypographyTab() {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: themeProvider.currentColors['surface']!
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Typography Configuration',
                  style: GoogleFonts.poppins(
                    color: themeProvider.currentColors['textPrimary']!,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Typography settings will be implemented in the next phase.',
                  style: GoogleFonts.poppins(
                      color: themeProvider.currentColors['textSecondary']!),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Helper methods

  Color _getColorFromHex(String hexColor) {
    try {
      hexColor = hexColor.replaceAll('#', '');
      if (hexColor.length == 6) {
        hexColor = 'FF$hexColor';
      }
      return Color(int.parse(hexColor, radix: 16));
    } catch (e) {
      return Colors.green;
    }
  }

  Future<void> _pickLogoFile(String logoKey) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.bytes != null) {
          setState(() {
            _logoFiles[logoKey] = file.bytes;
            _logoFileNames[logoKey] = file.name;
          });
        }
      }
    } catch (e) {
      DelightfulToast.showError(context, 'Error', 'Failed to pick file: $e');
    }
  }

  Future<void> _createNewTheme({required bool fromCurrent}) async {
    if (_nameController.text.isEmpty) {
      DelightfulToast.showError(context, 'Error', 'Please enter a theme name');
      return;
    }

    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    // Generate a unique theme ID with SDATheme prefix
    final idGenerator = IdentificationGenerator();
    final themeId = 'SDATheme-${idGenerator.generateNewId()}';

    // Create color scheme based on user choice
    final colors = fromCurrent
        ? CustomColorScheme(
            // Use current color picker values
            primaryColor: _colorControllers['primary']!.text,
            secondaryColor: _colorControllers['secondary']!.text,
            accentColor: _colorControllers['accent']!.text,
            backgroundColor: _colorControllers['background']!.text,
            surfaceColor: _colorControllers['surface']!.text,
            errorColor: _colorControllers['error']!.text,
            successColor: _colorControllers['success']!.text,
            warningColor: _colorControllers['warning']!.text,
            textPrimaryColor: _colorControllers['textPrimary']!.text,
            textSecondaryColor: _colorControllers['textSecondary']!.text,
            contentColor: _colorControllers['content']!.text,
          )
        : CustomColorScheme(
            // Use default constant colors
            primaryColor: ConstantColors.getAllColorsAsHex()['primary']!,
            secondaryColor: ConstantColors.getAllColorsAsHex()['secondary']!,
            accentColor: ConstantColors.getAllColorsAsHex()['accent']!,
            backgroundColor: ConstantColors.getAllColorsAsHex()['background']!,
            surfaceColor: ConstantColors.getAllColorsAsHex()['surface']!,
            errorColor: ConstantColors.getAllColorsAsHex()['error']!,
            successColor: ConstantColors.getAllColorsAsHex()['success']!,
            warningColor: ConstantColors.getAllColorsAsHex()['warning']!,
            textPrimaryColor:
                ConstantColors.getAllColorsAsHex()['textPrimary']!,
            textSecondaryColor:
                ConstantColors.getAllColorsAsHex()['textSecondary']!,
            contentColor: ConstantColors.getAllColorsAsHex()['content']!,
          );

    // Create logo config based on user choice
    final logos = fromCurrent && themeProvider.currentTheme != null
        ? themeProvider.currentTheme!.logos // Use current theme's logos
        : LogoConfig(
            // Use empty logos for new themes
            adventistLogo: '',
            adventistEducationLogo: '',
            bannerLogo: '',
            favicon: '',
            loginBackground: '',
            defaultProfilePic: '',
          );

    // Create default typography
    final typography = TypographyConfig(
      primaryFontFamily: 'Poppins',
      secondaryFontFamily: 'Roboto',
      baseFontSize: 16.0,
      headingFontSize: 24.0,
      subheadingFontSize: 18.0,
      bodyFontSize: 14.0,
      captionFontSize: 12.0,
    );

    final createdThemeId = await themeProvider.createTheme(
      id: themeId,
      name: _nameController.text,
      description: _descriptionController.text,
      createdBy: widget.userId ?? 'admin',
      colors: colors,
      logos: logos,
      typography: typography,
    );

    if (createdThemeId != null) {
      // Invalidate cache to force refresh on next load
      await ThemeCacheService.forceRefreshCache();

      final source = fromCurrent ? 'current colors' : 'default colors';
      DelightfulToast.showSuccess(
          context, 'Success', 'Theme created successfully from $source!');
      _nameController.clear();
      _descriptionController.clear();
    } else {
      DelightfulToast.showError(context, 'Error', 'Failed to create theme');
    }
  }

  Future<void> _updateColors() async {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    final colors = CustomColorScheme(
      primaryColor: _colorControllers['primary']!.text,
      secondaryColor: _colorControllers['secondary']!.text,
      accentColor: _colorControllers['accent']!.text,
      backgroundColor: _colorControllers['background']!.text,
      surfaceColor: _colorControllers['surface']!.text,
      errorColor: _colorControllers['error']!.text,
      successColor: _colorControllers['success']!.text,
      warningColor: _colorControllers['warning']!.text,
      textPrimaryColor: _colorControllers['textPrimary']!.text,
      textSecondaryColor: _colorControllers['textSecondary']!.text,
      contentColor: _colorControllers['content']!.text,
    );

    final success = await themeProvider.updateCurrentTheme(colors: colors);

    if (success) {
      // Invalidate cache to force refresh on next load
      await ThemeCacheService.forceRefreshCache();
      DelightfulToast.showSuccess(
          context, 'Success', 'Colors updated successfully');
    } else {
      DelightfulToast.showError(context, 'Error', 'Failed to update colors');
    }
  }

  Future<void> _updateLogos() async {
    if (_logoFiles.isEmpty) {
      DelightfulToast.showInfo(
          context, 'Info', 'Please select at least one logo file to upload');
      return;
    }

    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          title: Text('Uploading logos...'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
            ],
          ),
          actions: [],
        ),
      );

      final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
      final currentTheme = themeProvider.currentTheme;

      if (currentTheme == null) {
        Navigator.of(context).pop(); // Close loading dialog
        DelightfulToast.showError(context, 'Error',
            'No active theme found. Please create a theme first.');
        return;
      }

      // Upload each selected logo
      final Map<String, String> updatedLogos =
          Map.from(currentTheme.logos.toMap());
      int uploadedCount = 0;

      for (final entry in _logoFiles.entries) {
        final logoKey = entry.key;
        final logoBytes = entry.value;

        try {
          final fileId = await ThemeManagementService.uploadLogo(
            fileBytes: logoBytes!,
            fileName: '${logoKey}_${DateTime.now().millisecondsSinceEpoch}',
            fileId: '${logoKey}_${DateTime.now().millisecondsSinceEpoch}',
          );

          if (fileId != null) {
            updatedLogos[logoKey] = fileId;
            uploadedCount++;
          }
        } catch (e) {
          debugPrint('Failed to upload $logoKey: $e');
        }
      }

      // Update the theme with new logo file IDs
      if (uploadedCount > 0) {
        final updatedLogosConfig = LogoConfig.fromMap(updatedLogos);

        final success = await ThemeManagementService.updateTheme(
          themeId: currentTheme.id,
          logos: updatedLogosConfig,
        );

        if (success) {
          // Reload the theme to get updated logos
          await themeProvider.initialize();

          Navigator.of(context).pop(); // Close loading dialog

          // Invalidate cache to force refresh on next load
          await ThemeCacheService.forceRefreshCache();

          DelightfulToast.showSuccess(context, 'Success',
              'Successfully uploaded $uploadedCount logo(s)');

          // Clear the selected files
          setState(() {
            _logoFiles.clear();
            _logoFileNames.clear();
          });
        } else {
          Navigator.of(context).pop(); // Close loading dialog
          DelightfulToast.showError(
              context, 'Error', 'Failed to update theme with new logos');
        }
      } else {
        Navigator.of(context).pop(); // Close loading dialog
        DelightfulToast.showError(
            context, 'Error', 'Failed to upload any logos');
      }
    } catch (e) {
      Navigator.of(context).pop(); // Close loading dialog
      DelightfulToast.showError(context, 'Error', 'Failed to upload logos: $e');
    }
  }

  Widget _buildThemesTab() {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                themeProvider.currentColors['primary']!,
                                themeProvider.currentColors['primary']!
                                    .withValues(alpha: 0.8),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.style_outlined,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Theme Management',
                                style: GoogleFonts.poppins(
                                  color: Colors.black87,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Manage and apply your custom themes',
                                style: GoogleFonts.poppins(
                                  color: Colors.grey.shade600,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Create New Theme Section
                    _buildCreateThemeSection(themeProvider),
                    const SizedBox(height: 24),

                    // Current Active Theme
                    if (themeProvider.currentTheme != null) ...[
                      _buildCurrentThemeCard(themeProvider),
                      const SizedBox(height: 20),
                    ],

                    // Cache Management Section
                    _buildCacheManagementSection(themeProvider),
                    const SizedBox(height: 20),

                    // Available Themes List
                    _buildThemesList(themeProvider),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCreateThemeSection(ThemeProvider themeProvider) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      themeProvider.currentColors['primary']!,
                      themeProvider.currentColors['primary']!
                          .withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.add_circle_outline,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create New Theme',
                      style: GoogleFonts.poppins(
                        color: Colors.black87,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Design a custom theme for your application',
                      style: GoogleFonts.poppins(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Theme Name Field
          TextField(
            controller: _nameController,
            style: GoogleFonts.poppins(
              color: Colors.black87,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
            decoration: InputDecoration(
              labelText: 'Theme Name',
              labelStyle: GoogleFonts.poppins(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: themeProvider.currentColors['primary']!,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Description Field
          TextField(
            controller: _descriptionController,
            style: GoogleFonts.poppins(
              color: Colors.black87,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Description',
              labelStyle: GoogleFonts.poppins(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: themeProvider.currentColors['primary']!,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Theme Creation Options
          Row(
            children: [
              // Create from Current Colors
              Expanded(
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        themeProvider.currentColors['primary']!,
                        themeProvider.currentColors['primary']!
                            .withValues(alpha: 0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: themeProvider.currentColors['primary']!
                            .withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () => _createNewTheme(fromCurrent: true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.palette,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'From Current',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Create from Default
              Expanded(
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        themeProvider.currentColors['secondary']!,
                        themeProvider.currentColors['secondary']!
                            .withValues(alpha: 0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: themeProvider.currentColors['secondary']!
                            .withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () => _createNewTheme(fromCurrent: false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.refresh,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'From Default',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Help Text
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.blue.shade600,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'From Current: Uses your current color picker values. From Default: Uses original SmartEdu colors.',
                    style: GoogleFonts.poppins(
                      color: Colors.blue.shade700,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentThemeCard(ThemeProvider themeProvider) {
    final theme = themeProvider.currentTheme!;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Currently Active',
                style: GoogleFonts.poppins(
                  color: Colors.green,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            theme.name,
            style: GoogleFonts.poppins(
              color: Colors.black87,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            theme.description,
            style: GoogleFonts.poppins(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                'Created: ',
                style: GoogleFonts.poppins(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
              Text(
                '${theme.createdAt.day}/${theme.createdAt.month}/${theme.createdAt.year}',
                style: GoogleFonts.poppins(
                  color: Colors.black87,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThemesList(ThemeProvider themeProvider) {
    return FutureBuilder<List<ThemeConfigModel>>(
      future: _loadAllThemes(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            height: 200,
            child: Center(
              child: CircularProgressIndicator(
                color: themeProvider.currentColors['primary'],
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red.shade600),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Error loading themes: ${snapshot.error}',
                    style: GoogleFonts.poppins(
                      color: Colors.red.shade700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        final themes = snapshot.data ?? [];
        if (themes.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.grey.shade600),
                const SizedBox(width: 12),
                Text(
                  'No themes found. Create your first theme in the Overview tab.',
                  style: GoogleFonts.poppins(
                    color: Colors.grey.shade700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Available Themes',
              style: GoogleFonts.poppins(
                color: Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            ...themes.map((theme) => _buildThemeCard(theme, themeProvider)),
          ],
        );
      },
    );
  }

  Widget _buildThemeCard(ThemeConfigModel theme, ThemeProvider themeProvider) {
    final isActive = themeProvider.currentTheme?.id == theme.id;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isActive
              ? [
                  Colors.white,
                  themeProvider.currentColors['primary']!
                      .withValues(alpha: 0.05),
                  Colors.white,
                ]
              : [
                  Colors.white,
                  Colors.grey.shade50,
                ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive
              ? themeProvider.currentColors['primary']!
              : Colors.grey.shade300,
          width: isActive ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isActive
                ? themeProvider.currentColors['primary']!.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: isActive ? 12 : 8,
            offset: Offset(0, isActive ? 6 : 2),
          ),
          if (isActive)
            BoxShadow(
              color: themeProvider.currentColors['primary']!
                  .withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
        ],
      ),
      child: Row(
        children: [
          // Enhanced Theme preview
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  themeProvider.getColorFromHex(theme.colors.primaryColor),
                  themeProvider.getColorFromHex(theme.colors.secondaryColor),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: themeProvider
                      .getColorFromHex(theme.colors.primaryColor)
                      .withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                const Center(
                  child: Icon(
                    Icons.palette,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                if (isActive)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // Theme info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      theme.name,
                      style: GoogleFonts.poppins(
                        color: Colors.black87,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (isActive) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'ACTIVE',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  theme.description,
                  style: GoogleFonts.poppins(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Created by ${theme.createdBy} • ${theme.createdAt.day}/${theme.createdAt.month}/${theme.createdAt.year}',
                  style: GoogleFonts.poppins(
                    color: Colors.grey.shade500,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          // Enhanced Action buttons
          if (!isActive) ...[
            const SizedBox(width: 12),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    themeProvider.currentColors['primary']!,
                    themeProvider.currentColors['primary']!
                        .withValues(alpha: 0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: themeProvider.currentColors['primary']!
                        .withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _applyTheme(theme.id, themeProvider),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.check_circle_outline,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Apply',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<List<ThemeConfigModel>> _loadAllThemes() async {
    try {
      return await ThemeManagementService.getAllThemes();
    } catch (e) {
      debugPrint('Error loading themes: $e');
      return [];
    }
  }

  Future<void> _applyTheme(String themeId, ThemeProvider themeProvider) async {
    try {
      final success = await themeProvider.loadTheme(themeId);
      if (success) {
        // Update the color controllers with the new theme's colors
        _loadCurrentThemeColors(forceUpdate: true);
        DelightfulToast.showSuccess(
            context, 'Success', 'Theme applied successfully!');
        setState(() {}); // Refresh the UI
      } else {
        DelightfulToast.showError(context, 'Error', 'Failed to apply theme');
      }
    } catch (e) {
      DelightfulToast.showError(context, 'Error', 'Failed to apply theme: $e');
    }
  }

  void _showColorPicker(BuildContext context, String colorName,
      TextEditingController controller) {
    final currentColor = _getColorFromHex(controller.text);

    // Initialize the picker color with the current color of this field
    _currentPickerColor = currentColor;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.palette,
              color: currentColor,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              'Pick ${_getColorDisplayName(colorName)}',
              style: GoogleFonts.poppins(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Color picker
              ColorPicker(
                pickerColor: currentColor,
                onColorChanged: (Color color) {
                  _currentPickerColor = color;
                },
                pickerAreaHeightPercent: 0.8,
                enableAlpha: false,
                displayThumbColor: true,
                paletteType: PaletteType.hslWithHue,
                labelTypes: const [],
                portraitOnly: true,
              ),
              const SizedBox(height: 20),

              // Current color preview
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _currentPickerColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selected Color',
                            style: GoogleFonts.poppins(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '#${_currentPickerColor.value.toRadixString(16).substring(2).toUpperCase()}',
                            style: GoogleFonts.poppins(
                              color: Colors.black87,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _currentPickerColor,
                  _currentPickerColor.withValues(alpha: 0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ElevatedButton(
              onPressed: () {
                final hexColor =
                    '#${_currentPickerColor.value.toRadixString(16).substring(2).toUpperCase()}';
                controller.text = hexColor;
                Navigator.of(context).pop();
                setState(() {}); // Refresh the UI
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Apply',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterTab() {
    return Consumer2<ThemeProvider, FooterConfigProvider>(
      builder: (context, themeProvider, footerProvider, child) {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Enhanced Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.95),
                      themeProvider.currentColors['primary']!
                          .withValues(alpha: 0.02),
                      Colors.white.withValues(alpha: 0.95),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: themeProvider.currentColors['primary']!
                        .withValues(alpha: 0.1),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: themeProvider.currentColors['primary']!
                          .withValues(alpha: 0.1),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                themeProvider.currentColors['primary']!,
                                themeProvider.currentColors['primary']!
                                    .withValues(alpha: 0.8),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: themeProvider.currentColors['primary']!
                                    .withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.text_fields_outlined,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Footer Configuration',
                                style: GoogleFonts.poppins(
                                  color: themeProvider
                                      .currentColors['textPrimary'],
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Customize footer content and branding',
                                style: GoogleFonts.poppins(
                                  color: themeProvider
                                      .currentColors['textSecondary'],
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // App Name Field
                    _buildFooterField(
                      'App Name',
                      _appNameController,
                      'Enter the application name',
                      themeProvider,
                    ),
                    const SizedBox(height: 24),

                    // Privacy Policy Content Field
                    _buildFooterLargeTextArea(
                      'Privacy Policy Content',
                      _privacyPolicyContentController,
                      'Edit the privacy policy content that users will see',
                      themeProvider,
                    ),
                    const SizedBox(height: 24),

                    // Terms & Conditions Content Field
                    _buildFooterLargeTextArea(
                      'Terms & Conditions Content',
                      _termsAndConditionsContentController,
                      'Edit the terms & conditions content that users will see',
                      themeProvider,
                    ),
                    const SizedBox(height: 24),

                    // Update Footer Button
                    Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            themeProvider.currentColors['primary']!,
                            themeProvider.currentColors['primary']!
                                .withValues(alpha: 0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: themeProvider.currentColors['primary']!
                                .withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: footerProvider.isLoading
                            ? null
                            : _updateFooterConfig,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: footerProvider.isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.save_outlined,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Update Footer',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFooterField(
    String label,
    TextEditingController controller,
    String hint,
    ThemeProvider themeProvider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(
              color: Colors.grey.shade500,
              fontSize: 14,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: themeProvider.currentColors['primary']!,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooterLargeTextArea(
    String label,
    TextEditingController controller,
    String hint,
    ThemeProvider themeProvider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                color: Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: () => _showLargeTextEditor(
                  context, label, controller, themeProvider),
              icon: Icon(
                Icons.open_in_full,
                color: themeProvider.currentColors['primary'],
                size: 18,
              ),
              label: Text(
                'Open in Full Editor',
                style: GoogleFonts.poppins(
                  color: themeProvider.currentColors['primary'],
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 200,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: TextField(
            controller: controller,
            maxLines: null,
            expands: true,
            textAlignVertical: TextAlignVertical.top,
            style: GoogleFonts.poppins(
              color: Colors.black87,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.poppins(
                color: Colors.grey.shade500,
                fontSize: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: themeProvider.currentColors['primary']!,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _updateFooterConfig() async {
    final footerProvider =
        Provider.of<FooterConfigProvider>(context, listen: false);

    final config = FooterConfigModel(
      appName: _appNameController.text.trim(),
      privacyPolicyText: 'Privacy Policy', // Always the same
      termsAndConditionsText: 'Terms & Conditions', // Always the same
      privacyPolicyContent: _privacyPolicyContentController.text.trim(),
      termsAndConditionsContent:
          _termsAndConditionsContentController.text.trim(),
      lastUpdated: DateTime.now(),
    );

    final success = await footerProvider.updateFooterConfig(config);

    if (success) {
      DelightfulToast.showSuccess(
        context,
        'Success',
        'Footer configuration updated successfully!',
      );
    } else {
      DelightfulToast.showError(
        context,
        'Error',
        'Failed to update footer configuration',
      );
    }
  }

  void _showLargeTextEditor(BuildContext context, String title,
      TextEditingController controller, ThemeProvider themeProvider) {
    final tempController = TextEditingController(text: controller.text);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    Icons.edit_note,
                    color: themeProvider.currentColors['primary'],
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Edit $title',
                      style: GoogleFonts.poppins(
                        color: Colors.black87,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Text Editor
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: TextField(
                    controller: tempController,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    style: GoogleFonts.poppins(
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter your content here...',
                      hintStyle: GoogleFonts.poppins(
                        color: Colors.grey.shade500,
                        fontSize: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: themeProvider.currentColors['primary']!,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.poppins(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      controller.text = tempController.text;
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeProvider.currentColors['primary'],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Save Changes',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCacheManagementSection(ThemeProvider themeProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.blue.shade200,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.cached,
                color: Colors.blue.shade700,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Cache Management',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Manage theme cache to improve loading performance and ensure fresh data.',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await themeProvider.refreshTheme();
                    DelightfulToast.showSuccess(context, 'Success',
                        'Theme cache refreshed from Firebase');
                  },
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Refresh Cache'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await ThemeCacheService.clearAllCache();
                    DelightfulToast.showSuccess(
                        context, 'Success', 'All cache cleared');
                  },
                  icon: const Icon(Icons.clear_all, size: 18),
                  label: const Text('Clear Cache'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
