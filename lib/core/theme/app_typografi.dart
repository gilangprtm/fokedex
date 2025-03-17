import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_color.dart';

/// A class that contains all the typography styles used in the application.
/// This class provides a consistent typography system for both light and dark themes.
class AppTypography {
  // Font families
  static final String pokemonFontFamily = GoogleFonts.rubik().fontFamily!;
  static final String bodyFontFamily = GoogleFonts.poppins().fontFamily!;

  // Headline styles - More playful for Pokemon theme
  static TextStyle headline1 = TextStyle(
    fontFamily: pokemonFontFamily,
    fontSize: 96.0,
    fontWeight: FontWeight.bold,
    letterSpacing: -1.5,
    height: 1.2,
  );

  static TextStyle headline2 = TextStyle(
    fontFamily: pokemonFontFamily,
    fontSize: 60.0,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static TextStyle headline3 = TextStyle(
    fontFamily: pokemonFontFamily,
    fontSize: 48.0,
    fontWeight: FontWeight.bold,
    height: 1.2,
  );

  static TextStyle headline4 = TextStyle(
    fontFamily: pokemonFontFamily,
    fontSize: 34.0,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.25,
    height: 1.2,
  );

  static TextStyle headline5 = TextStyle(
    fontFamily: pokemonFontFamily,
    fontSize: 24.0,
    fontWeight: FontWeight.bold,
    height: 1.2,
  );

  static TextStyle headline6 = TextStyle(
    fontFamily: pokemonFontFamily,
    fontSize: 20.0,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.15,
    height: 1.2,
  );

  // Subtitle styles
  static TextStyle subtitle1 = TextStyle(
    fontFamily: bodyFontFamily,
    fontSize: 16.0,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.15,
    height: 1.5,
  );

  static TextStyle subtitle2 = TextStyle(
    fontFamily: bodyFontFamily,
    fontSize: 14.0,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.1,
    height: 1.5,
  );

  // Body styles
  static TextStyle bodyText1 = TextStyle(
    fontFamily: bodyFontFamily,
    fontSize: 16.0,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.5,
    height: 1.5,
  );

  static TextStyle bodyText2 = TextStyle(
    fontFamily: bodyFontFamily,
    fontSize: 14.0,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.25,
    height: 1.5,
  );

  // Button styles
  static TextStyle button = TextStyle(
    fontFamily: pokemonFontFamily,
    fontSize: 15.0,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.25,
    height: 1.5,
  );

  // Caption styles
  static TextStyle caption = TextStyle(
    fontFamily: bodyFontFamily,
    fontSize: 12.0,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.4,
    height: 1.5,
  );

  // Overline styles
  static TextStyle overline = TextStyle(
    fontFamily: bodyFontFamily,
    fontSize: 10.0,
    fontWeight: FontWeight.normal,
    letterSpacing: 1.5,
    height: 1.5,
  );

  // Link styles
  static TextStyle link = TextStyle(
    fontFamily: bodyFontFamily,
    fontSize: 16.0,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.5,
    height: 1.5,
    color: AppColors.primaryColor,
    decoration: TextDecoration.underline,
  );

  // List item styles
  static TextStyle listItem = TextStyle(
    fontFamily: bodyFontFamily,
    fontSize: 16.0,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.5,
    height: 1.5,
  );

  // Form label styles
  static TextStyle formLabel = TextStyle(
    fontFamily: bodyFontFamily,
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.25,
    height: 1.5,
  );

  // Pokemon-specific styles
  static TextStyle pokemonName = TextStyle(
    fontFamily: pokemonFontFamily,
    fontSize: 24.0,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.5,
    height: 1.2,
  );

  static TextStyle pokemonId = TextStyle(
    fontFamily: pokemonFontFamily,
    fontSize: 16.0,
    fontWeight: FontWeight.bold,
    color: AppColors.pokemonGray,
    height: 1.2,
  );

  static TextStyle pokemonType = TextStyle(
    fontFamily: pokemonFontFamily,
    fontSize: 14.0,
    fontWeight: FontWeight.bold,
    color: AppColors.white,
    letterSpacing: 0.5,
    height: 1.2,
  );

  static TextStyle pokemonStat = TextStyle(
    fontFamily: bodyFontFamily,
    fontSize: 14.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.25,
    height: 1.5,
  );

  static TextStyle muted = TextStyle(
    color: AppColors.black.withValues(alpha: .5),
    height: 1.5,
  );
  // Helper method for creating a style with custom color
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  // Helper method for creating a style with custom weight
  static TextStyle withWeight(TextStyle style, FontWeight weight) {
    return style.copyWith(fontWeight: weight);
  }
}
