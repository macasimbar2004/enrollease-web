import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:enrollease_web/states_management/theme_provider.dart';
import 'package:enrollease_web/utils/logos.dart';

/// A widget that displays logos dynamically based on the current theme
/// Falls back to static assets if no dynamic logo is available
class DynamicLogo extends StatelessWidget {
  final String logoType;
  final double? width;
  final double? height;
  final BoxFit fit;
  final String? fallbackAsset;

  const DynamicLogo({
    super.key,
    required this.logoType,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.fallbackAsset,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final logoUrl = themeProvider.getLogoUrl(logoType);

        if (logoUrl != null && logoUrl.isNotEmpty) {
          // Use dynamic logo from Appwrite
          return Image.network(
            logoUrl,
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (context, error, stackTrace) {
              // Fallback to static asset if network image fails
              return _buildFallbackImage();
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return SizedBox(
                width: width,
                height: height,
                child: Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                ),
              );
            },
          );
        } else {
          // Use static asset fallback
          return _buildFallbackImage();
        }
      },
    );
  }

  Widget _buildFallbackImage() {
    String assetPath = fallbackAsset ?? _getDefaultAssetPath();

    return Image.asset(
      assetPath,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        // Ultimate fallback - show a placeholder
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(
            Icons.image_not_supported,
            color: Colors.grey.shade400,
            size: (width != null && height != null)
                ? (width! < height! ? width! * 0.5 : height! * 0.5)
                : 24,
          ),
        );
      },
    );
  }

  String _getDefaultAssetPath() {
    switch (logoType) {
      case 'adventist':
        return CustomLogos.adventistLogo;
      case 'adventistEducation':
        return 'assets/logos/adventist_education.png';
      case 'banner':
        return 'assets/logos/banner.png';
      case 'favicon':
        return 'assets/logos/SDALogo.png';
      case 'loginBackground':
        return 'assets/logos/banner.png';
      case 'defaultProfilePic':
        return CustomLogos.editProfileImage;
      default:
        return CustomLogos.adventistLogo;
    }
  }
}

/// Convenience widgets for specific logo types
class AdventistLogo extends StatelessWidget {
  final double? width;
  final double? height;
  final BoxFit fit;

  const AdventistLogo({
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    return DynamicLogo(
      logoType: 'adventist',
      width: width,
      height: height,
      fit: fit,
    );
  }
}

class AdventistEducationLogo extends StatelessWidget {
  final double? width;
  final double? height;
  final BoxFit fit;

  const AdventistEducationLogo({
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    return DynamicLogo(
      logoType: 'adventistEducation',
      width: width,
      height: height,
      fit: fit,
    );
  }
}

class BannerLogo extends StatelessWidget {
  final double? width;
  final double? height;
  final BoxFit fit;

  const BannerLogo({
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    return DynamicLogo(
      logoType: 'banner',
      width: width,
      height: height,
      fit: fit,
    );
  }
}
