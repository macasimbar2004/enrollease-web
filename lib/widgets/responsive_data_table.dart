import 'package:flutter/material.dart';

class ResponsiveDataTable extends StatelessWidget {
  final Widget child;
  final double minWidth;
  final double maxWidth;
  final double initialFontSize;
  final double minFontSize;
  final double columnSpacing;
  final double horizontalMargin;

  const ResponsiveDataTable({
    super.key,
    required this.child,
    this.minWidth = 800,
    this.maxWidth = 1200,
    this.initialFontSize = 18,
    this.minFontSize = 12,
    this.columnSpacing = 20,
    this.horizontalMargin = 20,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Ensure we have valid constraints
        final availableWidth =
            constraints.maxWidth.isFinite ? constraints.maxWidth : minWidth;

        // Calculate scale factor based on available width
        final scaleFactor = (availableWidth / maxWidth).clamp(0.5, 1.0);

        // Calculate responsive values
        final currentFontSize = (initialFontSize * scaleFactor).clamp(
          minFontSize,
          initialFontSize,
        );

        final currentColumnSpacing = (columnSpacing * scaleFactor).clamp(
          8.0,
          columnSpacing,
        );

        final currentHorizontalMargin = (horizontalMargin * scaleFactor).clamp(
          10.0,
          horizontalMargin,
        );

        return Theme(
          data: Theme.of(context).copyWith(
            dataTableTheme: DataTableThemeData(
              columnSpacing: currentColumnSpacing,
              horizontalMargin: currentHorizontalMargin,
              headingRowHeight: 56 * (currentFontSize / initialFontSize),
              dataRowMinHeight: 48 * (currentFontSize / initialFontSize),
              dataRowMaxHeight: 75 * (currentFontSize / initialFontSize),
              headingTextStyle: TextStyle(
                fontSize: currentFontSize,
                fontWeight: FontWeight.bold,
              ),
              dataTextStyle: TextStyle(
                fontSize: currentFontSize,
              ),
            ),
          ),
          child: child,
        );
      },
    );
  }
}
