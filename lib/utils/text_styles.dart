import 'package:flutter/material.dart';

class CustomTextStyles {
  // Factory method to create a custom TextStyle
  static TextStyle customInknutAntiquaStyle({
    double fontSize = 16.0, // Default font size
    FontWeight fontWeight = FontWeight.normal, // Default font weight
    Color color = Colors.black, // Default text color
    String fontFamily = 'Inknut Antiqua', // Default font family
  }) {
    return TextStyle(
      fontFamily: fontFamily,
      fontWeight: fontWeight,
      fontSize: fontSize,
      color: color,
    );
  }

  // You can still provide specific styles if desired
  static TextStyle inknutAntiquaBlack(
      {double? fontSize, FontWeight? fontWeight, Color? color}) {
    return customInknutAntiquaStyle(
      fontSize: fontSize ?? 20.0,
      fontWeight: fontWeight ?? FontWeight.w900,
      color: color ?? Colors.black,
    );
  }

  // Factory method to create a custom TextStyle
  static TextStyle customMacondoStyle({
    double fontSize = 16.0, // Default font size
    FontWeight fontWeight = FontWeight.normal, // Default font weight
    Color color = Colors.black, // Default text color
    String fontFamily = 'Macondo', // Default font family
  }) {
    return TextStyle(
      fontFamily: fontFamily,
      fontWeight: fontWeight,
      fontSize: fontSize,
      color: color,
    );
  }

  // You can still provide specific styles if desired
  static TextStyle macondoFont(
      {double? fontSize, FontWeight? fontWeight, Color? color}) {
    return customMacondoStyle(
      fontSize: fontSize ?? 20.0,
      fontWeight: fontWeight ?? FontWeight.w900,
      color: color ?? Colors.black,
    );
  }

  // Factory method to create a custom TextStyle
  static TextStyle customLusitanaStyle({
    double fontSize = 16.0, // Default font size
    FontWeight fontWeight = FontWeight.normal, // Default font weight
    Color color = Colors.black, // Default text color
    String fontFamily = 'Lusitana', // Default font family
  }) {
    return TextStyle(
      fontFamily: fontFamily,
      fontWeight: fontWeight,
      fontSize: fontSize,
      color: color,
    );
  }

  // You can still provide specific styles if desired
  static TextStyle lusitanaFont(
      {double? fontSize, FontWeight? fontWeight, Color? color}) {
    return customLusitanaStyle(
      fontSize: fontSize ?? 20.0,
      fontWeight: fontWeight ?? FontWeight.w900,
      color: color ?? Colors.black,
    );
  }

  // Factory method to create a custom TextStyle
  static TextStyle customMaShanZhengStyle({
    double fontSize = 16.0, // Default font size
    FontWeight fontWeight = FontWeight.normal, // Default font weight
    Color color = Colors.black, // Default text color
    String fontFamily = 'Ma Shan Zheng', // Default font family
  }) {
    return TextStyle(
      fontFamily: fontFamily,
      fontWeight: fontWeight,
      fontSize: fontSize,
      color: color,
    );
  }

  // You can still provide specific styles if desired
  static TextStyle maShanZhengFont(
      {double? fontSize, FontWeight? fontWeight, Color? color}) {
    return customMaShanZhengStyle(
      fontSize: fontSize ?? 20.0,
      fontWeight: fontWeight ?? FontWeight.w900,
      color: color ?? Colors.black,
    );
  }
}
