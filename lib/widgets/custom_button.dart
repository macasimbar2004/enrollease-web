import 'package:flutter/material.dart';

class CustomBtn extends StatelessWidget {
  final Function()? onTap;
  final double vertical;
  final double? height; // Optional height parameter
  final Color colorBg;
  final Color colorTxt;
  final String? btnTxt;
  final FontWeight? btnFontWeight;
  final double? txtSize;
  final TextStyle? textStyle;
  final IconData? btnIcon;
  final FocusNode? focusNode;
  final String? imageAsset;
  final double horizontal;

  const CustomBtn({
    super.key,
    this.onTap,
    required this.vertical,
    this.height, // Initialize height
    required this.colorBg,
    required this.colorTxt,
    this.btnTxt,
    this.btnFontWeight = FontWeight.normal,
    required this.txtSize,
    this.horizontal = 0,
    this.btnIcon,
    this.focusNode,
    this.textStyle,
    this.imageAsset,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = this.textStyle ??
        TextStyle(
          fontWeight: btnFontWeight,
          color: colorTxt,
          fontSize: txtSize,
        );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        focusNode: focusNode,
        onTap: onTap,
        borderRadius: BorderRadius.circular(18.0),
        child: Ink(
          padding:
              EdgeInsets.symmetric(vertical: vertical, horizontal: horizontal),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18.0),
            color: colorBg,
            boxShadow: [
              BoxShadow(
                color: colorBg.withValues(alpha: 0.3),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SizedBox(
            height: height, // Set height here
            child: Center(
              child: _buildContent(textStyle),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(TextStyle textStyle) {
    // If no text or icon is provided, show only the centered icon
    if (btnTxt == null && imageAsset == null) {
      return Center(
        child: Icon(
          btnIcon ?? Icons.help_outline,
          color: colorTxt,
          size: 34.0,
        ),
      );
    }

    // If no icon or image is provided, center only the text
    if (btnIcon == null && imageAsset == null) {
      return Center(
        child: Text(
          btnTxt!,
          style: textStyle,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      );
    }

    // Display an image as a leading icon if provided
    if (imageAsset != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            imageAsset!,
            width: 24.0,
            height: 24.0,
          ),
          const SizedBox(width: 8.0), // Add spacing between image and text
          Flexible(
            child: Text(
              btnTxt!,
              style: textStyle,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      );
    }

    // Default layout with an icon
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          btnIcon,
          color: colorTxt,
          size: 24.0, // Smaller icon size
        ),
        const SizedBox(width: 8.0), // Add spacing between icon and text
        Flexible(
          child: Text(
            btnTxt!,
            style: textStyle,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }
}

//for dialogs button action
class CustomActionButton extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback? onPressed;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double borderRadius;
  final IconData? icon;

  const CustomActionButton({
    super.key,
    required this.text,
    required this.backgroundColor,
    required this.textColor,
    required this.onPressed,
    this.padding,
    this.width,
    this.borderRadius = 12.0,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.disabled)) {
            return backgroundColor.withValues(alpha: 0.6);
          }
          return backgroundColor;
        }),
        foregroundColor: WidgetStateProperty.all<Color>(textColor),
        padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
          padding ?? const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        elevation: WidgetStateProperty.resolveWith<double>((states) {
          if (states.contains(WidgetState.pressed)) return 1.0;
          return 3.0;
        }),
      ),
      onPressed: onPressed,
      child: SizedBox(
        width: width,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Text(
                text,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
