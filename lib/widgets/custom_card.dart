import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final Color? color;
  final EdgeInsetsGeometry? padding;
  final double elevation;
  final BorderRadius? borderRadius;
  final Clip clipBehavior;

  const CustomCard({
    super.key,
    required this.child,
    this.color,
    this.padding,
    this.elevation = 2.0,
    this.borderRadius,
    this.clipBehavior = Clip.antiAlias,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: elevation,
      color: Colors.transparent,
      borderRadius: borderRadius ?? BorderRadius.circular(16.0),
      clipBehavior: clipBehavior,
      child: Container(
        decoration: BoxDecoration(
          color: color ?? Colors.teal,
          borderRadius: borderRadius ?? BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }
}
