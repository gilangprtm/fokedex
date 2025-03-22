import 'package:flutter/material.dart';

/// A class that contains all the colors used in the application.
/// This class provides a consistent color palette for both light and dark themes.
class AppColors {
  // Pokéball Theme Colors
  static const Color pokemonRed =
      Color(0xFFE3350D); // Primary red (top of Pokéball)
  static const Color pokemonDarkRed =
      Color(0xFFC62828); // Darker shade for emphasis
  static const Color pokemonWhite =
      Color(0xFFFEFEFE); // Clean white (bottom of Pokéball)
  static const Color pokemonBlack =
      Color(0xFF31312F); // Black for the middle band
  static const Color pokemonGray =
      Color(0xFF8B8B8D); // Gray for subtle elements
  static const Color pokemonYellow =
      Color(0xFFFDD23C); // Pikachu yellow for accents

  // Primary Colors (Pokéball themed)
  static const Color primaryColor = pokemonRed;
  static const Color primaryLightColor = Color(0xFFFF6B52); // Lighter red
  static const Color primaryDarkColor = pokemonDarkRed;

  // Secondary Colors
  static const Color secondaryColor = pokemonBlack;
  static const Color secondaryLightColor = pokemonGray;
  static const Color accentColor = pokemonYellow;

  // Status Colors
  static const Color errorColor = Color(0xFFE53935);
  static const Color successColor = Color(0xFF43A047);
  static const Color warningColor = Color(0xFFFFA000);
  static const Color infoColor = Color(0xFF1E88E5);

  // Status Colors with Opacity
  static Color errorColorWithOpacity(double opacity) =>
      errorColor.withValues(alpha: opacity);
  static Color successColorWithOpacity(double opacity) =>
      successColor.withValues(alpha: opacity);
  static Color warningColorWithOpacity(double opacity) =>
      warningColor.withValues(alpha: opacity);
  static Color infoColorWithOpacity(double opacity) =>
      infoColor.withValues(alpha: opacity);

  // Utility Colors
  static const Color transparent = Colors.transparent;
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color grey = Color(0xFFb8b8d1);

  // Disabled State Colors
  static const Color disabledColor = Color(0xFFD6D6D6);
  static const Color disabledTextColor = Color(0xFF9E9E9E);

  // Divider and Border Colors
  static const Color dividerColor = Color(0xFFE0E0E0);
  static const Color borderColor = Color(0xFFE0E0E0);

  // Overlay Colors
  static const Color overlayColor = Color(0x80000000);
  static const Color modalOverlayColor = Color(0x40000000);

  // Light Mode Colors
  static const Color lightSecondaryColor = Color(0xFFF5F8FA);
  static const Color lightSecondaryLightColor = pokemonWhite;
  static const Color lightSecondaryDarkColor = Color(0xFFE8E8E8);

  static const Color lightBackgroundColor = pokemonWhite;
  static const Color lightSurfaceColor = Color(0xFFF8F8F8);
  static const Color lightCardColor = pokemonWhite;

  static const Color lightTextPrimaryColor = pokemonBlack;
  static const Color lightTextSecondaryColor = pokemonGray;

  // Light Mode Additional Colors
  static const Color lightDividerColor = Color(0xFFE0E0E0);
  static const Color lightBorderColor = Color(0xFFE0E0E0);
  static const Color lightDisabledColor = Color(0xFFBDBDBD);
  static const Color lightDisabledTextColor = Color(0xFF757575);

  // Dark Mode Colors
  static const Color darkSecondaryColor = Color(0xFF303030);
  static const Color darkSecondaryLightColor = Color(0xFF424242);
  static const Color darkSecondaryDarkColor = Color(0xFF212121);

  static const Color darkBackgroundColor = Color(0xFF121212);
  static const Color darkSurfaceColor = Color(0xFF212121);
  static const Color darkCardColor = Color(0xFF272727);

  static const Color darkTextPrimaryColor = pokemonWhite;
  static const Color darkTextSecondaryColor = Color(0xFFB0B0B0);

  // Dark Mode Additional Colors
  static const Color darkDividerColor = Color(0xFF424242);
  static const Color darkBorderColor = Color(0xFF424242);
  static const Color darkDisabledColor = Color(0xFF424242);
  static const Color darkDisabledTextColor = Color(0xFF757575);

  // Gradient Decorations
  static BoxDecoration get pokemonRedGradientDecoration => BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            pokemonRed.withValues(alpha: 0.8),
            pokemonDarkRed,
          ],
        ),
      );

  // Pokéball pattern box decoration
  static BoxDecoration get pokeBallPatternDecoration => BoxDecoration(
        color: pokemonWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: pokemonGray.withValues(alpha: 0.2), width: 1),
        borderRadius: BorderRadius.circular(12),
      );
}
