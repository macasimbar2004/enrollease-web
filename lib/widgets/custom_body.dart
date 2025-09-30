import 'package:flutter/material.dart';
import 'package:enrollease_web/widgets/responsive_widget.dart';

import 'package:enrollease_web/utils/theme_colors.dart';
import 'package:enrollease_web/states_management/theme_provider.dart';
import 'package:provider/provider.dart';

class CustomBody extends StatelessWidget {
  final Widget child;
  final bool useSafeArea;
  final EdgeInsets? padding;
  final Color? backgroundColor;
  final bool useScrollView;
  final bool useMaxWidth;
  final double? maxWidth;
  final bool useCard;
  final bool useShadow;
  final double? elevation;
  final BorderRadius? borderRadius;
  final bool useGradient;
  final List<Color>? gradientColors;

  const CustomBody({
    super.key,
    required this.child,
    this.useSafeArea = true,
    this.padding,
    this.backgroundColor,
    this.useScrollView = true,
    this.useMaxWidth = true,
    this.maxWidth,
    this.useCard = false,
    this.useShadow = true,
    this.elevation,
    this.borderRadius,
    this.useGradient = false,
    this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate responsive padding
    final responsivePadding = padding ??
        EdgeInsets.symmetric(
          horizontal: ResponsiveWidget.isSmallScreen(context) ? 16.0 : 24.0,
          vertical: ResponsiveWidget.isSmallScreen(context) ? 12.0 : 16.0,
        );

    // Calculate max width based on screen size
    final calculatedMaxWidth = maxWidth ??
        (ResponsiveWidget.isLargeScreen(context)
            ? 1200.0
            : ResponsiveWidget.isMediumScreen(context)
                ? 900.0
                : double.infinity);

    // Start with the child widget
    Widget content = child;

    // Add max width constraint if specified
    if (useMaxWidth) {
      content = Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: calculatedMaxWidth,
          ),
          child: content,
        ),
      );
    }

    // Add padding if specified
    if (padding != null) {
      content = Padding(
        padding: responsivePadding,
        child: content,
      );
    }

    // Wrap in card if specified
    if (useCard) {
      content = Card(
        elevation: elevation ?? (useShadow ? 4.0 : 0.0),
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius ?? BorderRadius.circular(12.0),
        ),
        child: content,
      );
    }

    // Add background color or gradient if specified
    if (backgroundColor != null || useGradient) {
      content = Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          gradient: useGradient
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: gradientColors ??
                      [
                        (Provider.of<ThemeProvider>(context, listen: false)
                                    .currentColors['content'] ??
                                ThemeColors.content(context))
                            .withValues(alpha: 0.05),
                        (Provider.of<ThemeProvider>(context, listen: false)
                                    .currentColors['content'] ??
                                ThemeColors.content(context))
                            .withValues(alpha: 0.02),
                      ],
                )
              : null,
        ),
        child: content,
      );
    }

    // Add scroll view if specified
    if (useScrollView) {
      content = SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: content,
      );
    }

    // Add safe area if specified
    if (useSafeArea) {
      content = SafeArea(
        child: content,
      );
    }

    return content;
  }
}

// Example usage:
/*
CustomBody(
  child: YourContent(),
  useSafeArea: true,
  padding: EdgeInsets.all(16.0),
  backgroundColor: Colors.white,
  useScrollView: true,
  useMaxWidth: true,
  useCard: true,
  useShadow: true,
  elevation: 4.0,
  borderRadius: BorderRadius.circular(12.0),
  useGradient: true,
  gradientColors: [
    Colors.blue.withValues(alpha: 0.05),
    Colors.blue.withValues(alpha: 0.02),
  ],
)
*/
