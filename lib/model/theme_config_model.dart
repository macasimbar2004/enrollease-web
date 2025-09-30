import 'package:cloud_firestore/cloud_firestore.dart';

class ThemeConfigModel {
  final String id;
  final String name;
  final String description;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;

  // Color Configuration
  final CustomColorScheme colors;

  // Logo Configuration
  final LogoConfig logos;

  // Typography Configuration
  final TypographyConfig typography;

  ThemeConfigModel({
    required this.id,
    required this.name,
    required this.description,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    required this.colors,
    required this.logos,
    required this.typography,
  });

  factory ThemeConfigModel.fromMap(Map<String, dynamic> map) {
    return ThemeConfigModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      isActive: map['isActive'] ?? false,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      createdBy: map['createdBy'] ?? '',
      colors: CustomColorScheme.fromMap(map['colors'] ?? {}),
      logos: LogoConfig.fromMap(map['logos'] ?? {}),
      typography: TypographyConfig.fromMap(map['typography'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'createdBy': createdBy,
      'colors': colors.toMap(),
      'logos': logos.toMap(),
      'typography': typography.toMap(),
    };
  }

  ThemeConfigModel copyWith({
    String? id,
    String? name,
    String? description,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    CustomColorScheme? colors,
    LogoConfig? logos,
    TypographyConfig? typography,
  }) {
    return ThemeConfigModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      colors: colors ?? this.colors,
      logos: logos ?? this.logos,
      typography: typography ?? this.typography,
    );
  }
}

class CustomColorScheme {
  final String primaryColor;
  final String secondaryColor;
  final String accentColor;
  final String backgroundColor;
  final String surfaceColor;
  final String errorColor;
  final String successColor;
  final String warningColor;
  final String textPrimaryColor;
  final String textSecondaryColor;
  final String contentColor;

  CustomColorScheme({
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
    required this.backgroundColor,
    required this.surfaceColor,
    required this.errorColor,
    required this.successColor,
    required this.warningColor,
    required this.textPrimaryColor,
    required this.textSecondaryColor,
    required this.contentColor,
  });

  factory CustomColorScheme.fromMap(Map<String, dynamic> map) {
    return CustomColorScheme(
      primaryColor: map['primaryColor'] ?? '#2E7D32',
      secondaryColor: map['secondaryColor'] ?? '#1976D2',
      accentColor: map['accentColor'] ?? '#FFC107',
      backgroundColor: map['backgroundColor'] ?? '#F5F5F5',
      surfaceColor: map['surfaceColor'] ?? '#FFFFFF',
      errorColor: map['errorColor'] ?? '#D32F2F',
      successColor: map['successColor'] ?? '#388E3C',
      warningColor: map['warningColor'] ?? '#F57C00',
      textPrimaryColor: map['textPrimaryColor'] ?? '#212121',
      textSecondaryColor: map['textSecondaryColor'] ?? '#757575',
      contentColor: map['contentColor'] ?? '#4CAF50',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'primaryColor': primaryColor,
      'secondaryColor': secondaryColor,
      'accentColor': accentColor,
      'backgroundColor': backgroundColor,
      'surfaceColor': surfaceColor,
      'errorColor': errorColor,
      'successColor': successColor,
      'warningColor': warningColor,
      'textPrimaryColor': textPrimaryColor,
      'textSecondaryColor': textSecondaryColor,
      'contentColor': contentColor,
    };
  }
}

class LogoConfig {
  final String
      adventistLogo; // Appwrite file ID - School-related logo (changeable)
  final String
      adventistEducationLogo; // Appwrite file ID - School-related logo (changeable)
  final String bannerLogo; // Appwrite file ID - Banner logo (changeable)
  final String favicon; // Appwrite file ID - Favicon (changeable)
  final String
      loginBackground; // Appwrite file ID - Login background (changeable)
  final String
      defaultProfilePic; // Appwrite file ID - Default profile picture (changeable)

  LogoConfig({
    required this.adventistLogo,
    required this.adventistEducationLogo,
    required this.bannerLogo,
    required this.favicon,
    required this.loginBackground,
    required this.defaultProfilePic,
  });

  factory LogoConfig.fromMap(Map<String, dynamic> map) {
    return LogoConfig(
      adventistLogo: map['adventistLogo'] ?? '',
      adventistEducationLogo: map['adventistEducationLogo'] ?? '',
      bannerLogo: map['bannerLogo'] ?? '',
      favicon: map['favicon'] ?? '',
      loginBackground: map['loginBackground'] ?? '',
      defaultProfilePic: map['defaultProfilePic'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'adventistLogo': adventistLogo,
      'adventistEducationLogo': adventistEducationLogo,
      'bannerLogo': bannerLogo,
      'favicon': favicon,
      'loginBackground': loginBackground,
      'defaultProfilePic': defaultProfilePic,
    };
  }
}

class TypographyConfig {
  final String primaryFontFamily;
  final String secondaryFontFamily;
  final double baseFontSize;
  final double headingFontSize;
  final double subheadingFontSize;
  final double bodyFontSize;
  final double captionFontSize;

  TypographyConfig({
    required this.primaryFontFamily,
    required this.secondaryFontFamily,
    required this.baseFontSize,
    required this.headingFontSize,
    required this.subheadingFontSize,
    required this.bodyFontSize,
    required this.captionFontSize,
  });

  factory TypographyConfig.fromMap(Map<String, dynamic> map) {
    return TypographyConfig(
      primaryFontFamily: map['primaryFontFamily'] ?? 'Poppins',
      secondaryFontFamily: map['secondaryFontFamily'] ?? 'Roboto',
      baseFontSize: (map['baseFontSize'] ?? 16.0).toDouble(),
      headingFontSize: (map['headingFontSize'] ?? 24.0).toDouble(),
      subheadingFontSize: (map['subheadingFontSize'] ?? 18.0).toDouble(),
      bodyFontSize: (map['bodyFontSize'] ?? 14.0).toDouble(),
      captionFontSize: (map['captionFontSize'] ?? 12.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'primaryFontFamily': primaryFontFamily,
      'secondaryFontFamily': secondaryFontFamily,
      'baseFontSize': baseFontSize,
      'headingFontSize': headingFontSize,
      'subheadingFontSize': subheadingFontSize,
      'bodyFontSize': bodyFontSize,
      'captionFontSize': captionFontSize,
    };
  }
}
