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
        borderRadius: BorderRadius.circular(15.0),
        child: Ink(
          padding: EdgeInsets.symmetric(vertical: vertical, horizontal: horizontal),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.0),
            color: colorBg,
          ),
          child: SizedBox(
            height: height, // Set height here
            child: Center(child: _buildContent(textStyle)),
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
        ),
      );
    }

    // Display an image as a leading icon if provided
    if (imageAsset != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            imageAsset!,
            width: 34.0,
            height: 34.0,
          ),
          const SizedBox(width: 8.0), // Add spacing between image and text
          Text(
            btnTxt!,
            style: textStyle,
          ),
        ],
      );
    }

    // Default layout with an icon
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          btnIcon,
          color: colorTxt,
          size: 34.0,
        ),
        const SizedBox(width: 8.0), // Add spacing between icon and text
        Text(
          btnTxt!,
          style: textStyle,
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

  const CustomActionButton({
    super.key,
    required this.text,
    required this.backgroundColor,
    required this.textColor,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all<Color>(backgroundColor),
        foregroundColor: WidgetStateProperty.all<Color>(textColor),
      ),
      onPressed: onPressed,
      child: Text(text),
    );
  }
}
