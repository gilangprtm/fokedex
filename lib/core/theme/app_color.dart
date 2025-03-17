import 'package:flutter/material.dart';

/// A class that contains all the colors used in the application.
/// This class provides a consistent color palette for both light and dark themes.
class AppColors {
  // Primary Colors
  static const Color primaryColor = Color(0xFF1DA1F2);
  static const Color primaryLightColor = Color(0xFF71C9F8);
  static const Color primaryDarkColor = Color(0xFF1A91DA);

  // Mahas Custom Colors
  static const Color brown = Color(0xFFA66E68);
  static const Color cream = Color(0xFFF2C094);
  static const Color blue = Color(0xFF33428a);
  static const Color yellow = Color(0xFFffc145);
  static const Color red = Color(0xFFff4000);
  static const Color grey = Color(0xFFb8b8d1);
  static const Color green = Color(0xFF11911B);

  // Status Colors
  static const Color errorColor = Color(0xFFE0245E);
  static const Color successColor = Color(0xFF17BF63);
  static const Color warningColor = Color(0xFFFF8A50);
  static const Color infoColor = Color(0xFF1DA1F2);

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

  // Disabled State Colors
  static const Color disabledColor = Color(0xFFBDBDBD);
  static const Color disabledTextColor = Color(0xFF757575);

  // Divider and Border Colors
  static const Color dividerColor = Color(0xFFE0E0E0);
  static const Color borderColor = Color(0xFFE0E0E0);

  // Overlay Colors
  static const Color overlayColor = Color(0x80000000);
  static const Color modalOverlayColor = Color(0x40000000);

  // Light Mode Colors
  static const Color lightSecondaryColor = Color(0xFFF5F8FA);
  static const Color lightSecondaryLightColor = Color(0xFFFFFFFF);
  static const Color lightSecondaryDarkColor = Color(0xFFE1E8ED);

  static const Color lightBackgroundColor = Color(0xFFFFFFFF);
  static const Color lightSurfaceColor = Color(0xFFF5F8FA);
  static const Color lightCardColor = Color(0xFFFFFFFF);

  static const Color lightTextPrimaryColor = Color(0xFF14171A);
  static const Color lightTextSecondaryColor = Color(0xFF657786);

  // Light Mode Additional Colors
  static const Color lightDividerColor = Color(0xFFE1E8ED);
  static const Color lightBorderColor = Color(0xFFE1E8ED);
  static const Color lightDisabledColor = Color(0xFFBDBDBD);
  static const Color lightDisabledTextColor = Color(0xFF757575);

  // Dark Mode Colors
  static const Color darkSecondaryColor = Color(0xFF1B2836);
  static const Color darkSecondaryLightColor = Color(0xFF22303C);
  static const Color darkSecondaryDarkColor = Color(0xFF15202B);

  static const Color darkBackgroundColor = Color(0xFF121212);
  static const Color darkSurfaceColor = Color(0xFF192734);
  static const Color darkCardColor = Color(0xFF22303C);

  static const Color darkTextPrimaryColor = Color(0xFFFFFFFF);
  static const Color darkTextSecondaryColor = Color(0xFF8899A6);

  // Dark Mode Additional Colors
  static const Color darkDividerColor = Color(0xFF38444D);
  static const Color darkBorderColor = Color(0xFF38444D);
  static const Color darkDisabledColor = Color(0xFF424242);
  static const Color darkDisabledTextColor = Color(0xFF757575);

  // Gradient Decorations
  static BoxDecoration get creamGradientDecoration => BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            cream.withValues(alpha: .8),
            cream,
          ],
        ),
      );
}
