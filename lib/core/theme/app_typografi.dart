import 'package:flutter/material.dart';
import 'app_color.dart';

/// A class that contains all the typography styles used in the application.
/// This class provides a consistent typography system for both light and dark themes.
class AppTypography {
  // Headline styles
  static const TextStyle headline1 = TextStyle(
    fontSize: 96.0,
    fontWeight: FontWeight.bold,
    letterSpacing: -1.5,
    height: 1.2,
  );

  static const TextStyle headline2 = TextStyle(
    fontSize: 60.0,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static const TextStyle headline3 = TextStyle(
    fontSize: 48.0,
    fontWeight: FontWeight.bold,
    height: 1.2,
  );

  static const TextStyle headline4 = TextStyle(
    fontSize: 34.0,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.25,
    height: 1.2,
  );

  static const TextStyle headline5 = TextStyle(
    fontSize: 24.0,
    fontWeight: FontWeight.bold,
    height: 1.2,
  );

  static const TextStyle headline6 = TextStyle(
    fontSize: 20.0,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.15,
    height: 1.2,
  );

  // Subtitle styles
  static const TextStyle subtitle1 = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.15,
    height: 1.5,
  );

  static const TextStyle subtitle2 = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.1,
    height: 1.5,
  );

  // Body styles
  static const TextStyle bodyText1 = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.5,
    height: 1.5,
  );

  static const TextStyle bodyText2 = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.25,
    height: 1.5,
  );

  // Button styles
  static const TextStyle button = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.25,
    height: 1.5,
  );

  // Caption styles
  static const TextStyle caption = TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.4,
    height: 1.5,
  );

  // Overline styles
  static const TextStyle overline = TextStyle(
    fontSize: 10.0,
    fontWeight: FontWeight.normal,
    letterSpacing: 1.5,
    height: 1.5,
  );

  // Link styles
  static const TextStyle link = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.5,
    height: 1.5,
    decoration: TextDecoration.underline,
  );

  // List item styles
  static const TextStyle listItem = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.5,
    height: 1.5,
  );

  // Form label styles
  static const TextStyle formLabel = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.25,
    height: 1.5,
  );

  // Mahas Custom Styles
  static const TextStyle h1 = TextStyle(
    fontSize: 18.0,
    fontWeight: FontWeight.bold,
    height: 1.5,
  );

  static const TextStyle title = TextStyle(
    fontWeight: FontWeight.bold,
    height: 1.5,
  );

  static TextStyle muted = TextStyle(
    color: AppColors.black.withValues(alpha: .5),
    height: 1.5,
  );

  static TextStyle mahasLink = const TextStyle(
    fontWeight: FontWeight.bold,
    color: AppColors.primaryColor,
    height: 1.5,
  );

  // Input Decoration
  static InputDecoration textFieldDecoration({String? hintText}) {
    return InputDecoration(
      border: const OutlineInputBorder(),
      hintText: hintText,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  // Helper method for responsive typography
  static TextStyle responsive(TextStyle style, double scale) {
    return style.copyWith(
      fontSize: style.fontSize! * scale,
    );
  }

  // Helper method for creating a style with custom color
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  // Helper method for creating a style with custom weight
  static TextStyle withWeight(TextStyle style, FontWeight weight) {
    return style.copyWith(fontWeight: weight);
  }
}
