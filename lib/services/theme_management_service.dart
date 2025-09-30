import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:appwrite/appwrite.dart';
import 'package:flutter/foundation.dart';
import 'package:enrollease_web/model/theme_config_model.dart';
import 'package:enrollease_web/appwrite.dart';

class ThemeManagementService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName = 'theme_configurations';

  // Appwrite configuration - using existing appwrite.dart configuration
  static const String _bucketId =
      '674985ef0038f4e4b5cb'; // Using profile pics bucket for theme assets

  /// Get the currently active theme configuration
  static Future<ThemeConfigModel?> getActiveTheme() async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        return ThemeConfigModel.fromMap(doc.data()..['id'] = doc.id);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting active theme: $e');
      return null;
    }
  }

  /// Get all theme configurations
  static Future<List<ThemeConfigModel>> getAllThemes() async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => ThemeConfigModel.fromMap(doc.data()..['id'] = doc.id))
          .toList();
    } catch (e) {
      debugPrint('Error getting all themes: $e');
      return [];
    }
  }

  /// Create a new theme configuration
  static Future<String?> createTheme({
    required String id,
    required String name,
    required String description,
    required String createdBy,
    required CustomColorScheme colors,
    required LogoConfig logos,
    required TypographyConfig typography,
  }) async {
    try {
      final now = DateTime.now();
      final theme = ThemeConfigModel(
        id: id, // Will be set by Firestore
        name: name,
        description: description,
        isActive: false, // New themes are inactive by default
        createdAt: now,
        updatedAt: now,
        createdBy: createdBy,
        colors: colors,
        logos: logos,
        typography: typography,
      );

      final docRef =
          await _firestore.collection(_collectionName).add(theme.toMap());

      return docRef.id;
    } catch (e) {
      debugPrint('Error creating theme: $e');
      return null;
    }
  }

  /// Update an existing theme configuration
  static Future<bool> updateTheme({
    required String themeId,
    String? name,
    String? description,
    CustomColorScheme? colors,
    LogoConfig? logos,
    TypographyConfig? typography,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      };

      if (name != null) updateData['name'] = name;
      if (description != null) updateData['description'] = description;
      if (colors != null) updateData['colors'] = colors.toMap();
      if (logos != null) updateData['logos'] = logos.toMap();
      if (typography != null) updateData['typography'] = typography.toMap();

      await _firestore
          .collection(_collectionName)
          .doc(themeId)
          .update(updateData);

      return true;
    } catch (e) {
      debugPrint('Error updating theme: $e');
      return false;
    }
  }

  /// Activate a theme (deactivates all others)
  static Future<bool> activateTheme(String themeId) async {
    try {
      // Deactivate all themes
      final batch = _firestore.batch();
      final allThemes = await _firestore.collection(_collectionName).get();

      for (var doc in allThemes.docs) {
        batch.update(doc.reference, {'isActive': false});
      }

      // Activate the selected theme
      batch.update(
        _firestore.collection(_collectionName).doc(themeId),
        {'isActive': true, 'updatedAt': Timestamp.fromDate(DateTime.now())},
      );

      await batch.commit();
      return true;
    } catch (e) {
      debugPrint('Error activating theme: $e');
      return false;
    }
  }

  /// Delete a theme configuration
  static Future<bool> deleteTheme(String themeId) async {
    try {
      await _firestore.collection(_collectionName).doc(themeId).delete();
      return true;
    } catch (e) {
      debugPrint('Error deleting theme: $e');
      return false;
    }
  }

  /// Upload a logo/image to Appwrite
  static Future<String?> uploadLogo({
    required String fileId,
    required Uint8List fileBytes,
    required String fileName,
  }) async {
    try {
      final file = InputFile.fromBytes(
        bytes: fileBytes,
        filename: fileName,
      );

      final result = await storage.createFile(
        bucketId: _bucketId,
        fileId: fileId,
        file: file,
      );

      return result.$id;
    } catch (e) {
      debugPrint('Error uploading logo: $e');
      return null;
    }
  }

  /// Get logo/image from Appwrite
  static Future<Uint8List?> getLogo(String fileId) async {
    try {
      final result = await storage.getFileDownload(
        bucketId: _bucketId,
        fileId: fileId,
      );
      return result;
    } catch (e) {
      debugPrint('Error getting logo: $e');
      return null;
    }
  }

  /// Delete a logo/image from Appwrite
  static Future<bool> deleteLogo(String fileId) async {
    try {
      await storage.deleteFile(
        bucketId: _bucketId,
        fileId: fileId,
      );
      return true;
    } catch (e) {
      debugPrint('Error deleting logo: $e');
      return false;
    }
  }

  /// Get logo URL for display
  static String getLogoUrl(String fileId) {
    return 'https://cloud.appwrite.io/v1/storage/buckets/$_bucketId/files/$fileId/view?project=674982d000220a32a166';
  }

  /// Create default theme configuration
  static Future<String?> createDefaultTheme(String createdBy) async {
    try {
      final defaultColors = CustomColorScheme(
        primaryColor: '#2E7D32',
        secondaryColor: '#1976D2',
        accentColor: '#FFC107',
        backgroundColor: '#F5F5F5',
        surfaceColor: '#FFFFFF',
        errorColor: '#D32F2F',
        successColor: '#388E3C',
        warningColor: '#F57C00',
        textPrimaryColor: '#212121',
        textSecondaryColor: '#757575',
        contentColor: '#4CAF50',
      );

      final defaultLogos = LogoConfig(
        adventistLogo: '',
        adventistEducationLogo: '',
        bannerLogo: '',
        favicon: '',
        loginBackground: '',
        defaultProfilePic: '',
      );

      final defaultTypography = TypographyConfig(
        primaryFontFamily: 'Poppins',
        secondaryFontFamily: 'Roboto',
        baseFontSize: 16.0,
        headingFontSize: 24.0,
        subheadingFontSize: 18.0,
        bodyFontSize: 14.0,
        captionFontSize: 12.0,
      );

      return await createTheme(
        id: 'default',
        name: 'Default Theme',
        description: 'Default theme configuration for the application',
        createdBy: createdBy,
        colors: defaultColors,
        logos: defaultLogos,
        typography: defaultTypography,
      );
    } catch (e) {
      debugPrint('Error creating default theme: $e');
      return null;
    }
  }
}
