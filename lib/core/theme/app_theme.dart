import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_color.dart';
import 'app_typografi.dart';

/// A class that contains all the theme data used in the application.
/// This class provides a consistent theme system for both light and dark modes.
class AppTheme {
  // Common theme properties
  static const double _borderRadius = 10.0;
  static const double _elevation = 2.0;
  static const double borderRadius = _borderRadius;
  static const double elevation = _elevation;
  static const Duration _animationDuration = Duration(milliseconds: 200);
  static const Curve _animationCurve = Curves.easeInOut;

  // Spacing constants
  static const double spacing4 = 4.0;
  static const double spacing8 = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;

  // Shape constants
  static final RoundedRectangleBorder _cardShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(_borderRadius),
  );

  static final RoundedRectangleBorder _buttonShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(_borderRadius),
  );

  static final RoundedRectangleBorder _dialogShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(_borderRadius),
  );

  // Light Theme
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: false,
    fontFamily: GoogleFonts.poppins().fontFamily,
    brightness: Brightness.light,
    primaryColor: AppColors.primaryColor,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primaryColor,
      primaryContainer: AppColors.primaryLightColor,
      secondary: AppColors.lightSecondaryColor,
      secondaryContainer: AppColors.lightSecondaryLightColor,
      surface: AppColors.lightSurfaceColor,
      error: AppColors.errorColor,
      onPrimary: Colors.white,
      onSecondary: AppColors.lightTextPrimaryColor,
      onSurface: AppColors.lightTextPrimaryColor,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: AppColors.lightBackgroundColor,
    cardColor: AppColors.lightCardColor,
    cardTheme: CardTheme(
      color: AppColors.lightCardColor,
      shape: _cardShape,
      elevation: _elevation,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.primaryColor,
      foregroundColor: Colors.white,
      titleTextStyle: AppTypography.headline6.copyWith(color: Colors.white),
      elevation: 0,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.lightCardColor,
      selectedItemColor: AppColors.primaryColor,
      unselectedItemColor: AppColors.lightTextSecondaryColor,
    ),
    textTheme: TextTheme(
      displayLarge: AppTypography.headline1
          .copyWith(color: AppColors.lightTextPrimaryColor),
      displayMedium: AppTypography.headline2
          .copyWith(color: AppColors.lightTextPrimaryColor),
      displaySmall: AppTypography.headline3
          .copyWith(color: AppColors.lightTextPrimaryColor),
      headlineMedium: AppTypography.headline4
          .copyWith(color: AppColors.lightTextPrimaryColor),
      headlineSmall: AppTypography.headline5
          .copyWith(color: AppColors.lightTextPrimaryColor),
      titleLarge: AppTypography.headline6
          .copyWith(color: AppColors.lightTextPrimaryColor),
      titleMedium: AppTypography.subtitle1
          .copyWith(color: AppColors.lightTextPrimaryColor),
      titleSmall: AppTypography.subtitle2
          .copyWith(color: AppColors.lightTextSecondaryColor),
      bodyLarge: AppTypography.bodyText1
          .copyWith(color: AppColors.lightTextPrimaryColor),
      bodyMedium: AppTypography.bodyText2
          .copyWith(color: AppColors.lightTextSecondaryColor),
      labelLarge: AppTypography.button.copyWith(color: Colors.white),
      bodySmall: AppTypography.caption
          .copyWith(color: AppColors.lightTextSecondaryColor),
      labelSmall: AppTypography.overline
          .copyWith(color: AppColors.lightTextSecondaryColor),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: AppColors.primaryColor,
        textStyle: AppTypography.button,
        shape: _buttonShape,
        minimumSize: const Size(88, 40),
        padding: const EdgeInsets.symmetric(
            horizontal: spacing16, vertical: spacing8),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: const Size(88, 40),
        shape: _buttonShape,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
          horizontal: spacing16, vertical: spacing12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_borderRadius),
        borderSide: const BorderSide(color: AppColors.lightBorderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_borderRadius),
        borderSide: const BorderSide(color: AppColors.lightBorderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_borderRadius),
        borderSide: const BorderSide(color: AppColors.primaryColor),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_borderRadius),
        borderSide: const BorderSide(color: AppColors.errorColor),
      ),
      labelStyle: AppTypography.formLabel
          .copyWith(color: AppColors.lightTextSecondaryColor),
      errorStyle: AppTypography.caption.copyWith(color: AppColors.errorColor),
    ),
    dialogTheme: DialogTheme(
      shape: _dialogShape,
      titleTextStyle: AppTypography.headline6
          .copyWith(color: AppColors.lightTextPrimaryColor),
      contentTextStyle: AppTypography.bodyText1
          .copyWith(color: AppColors.lightTextPrimaryColor),
      actionsPadding: const EdgeInsets.all(spacing16),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.darkSurfaceColor,
      contentTextStyle: AppTypography.bodyText1.copyWith(color: Colors.white),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_borderRadius),
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.lightSurfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(_borderRadius)),
      ),
    ),
    drawerTheme: const DrawerThemeData(
      backgroundColor: AppColors.lightSurfaceColor,
      elevation: _elevation,
    ),
    tabBarTheme: const TabBarTheme(
      labelColor: AppColors.primaryColor,
      unselectedLabelColor: AppColors.lightTextSecondaryColor,
      labelStyle: AppTypography.button,
      unselectedLabelStyle: AppTypography.button,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.lightSecondaryColor,
      labelStyle: AppTypography.bodyText2
          .copyWith(color: AppColors.lightTextPrimaryColor),
      selectedColor: AppColors.primaryColor,
      secondarySelectedColor: AppColors.primaryColor,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primaryColor;
        }
        return AppColors.lightTextSecondaryColor;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primaryLightColor;
        }
        return AppColors.lightSecondaryColor;
      }),
    ),
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primaryColor;
        }
        return AppColors.lightTextSecondaryColor;
      }),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primaryColor;
        }
        return AppColors.lightTextSecondaryColor;
      }),
    ),
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );

  // Dark Theme
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: false,
    fontFamily: GoogleFonts.poppins().fontFamily,
    brightness: Brightness.dark,
    primaryColor: AppColors.primaryColor,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primaryColor,
      primaryContainer: AppColors.primaryLightColor,
      secondary: AppColors.darkSecondaryColor,
      secondaryContainer: AppColors.darkSecondaryLightColor,
      surface: AppColors.darkSurfaceColor,
      error: AppColors.errorColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.white,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: AppColors.darkBackgroundColor,
    cardColor: AppColors.darkCardColor,
    cardTheme: CardTheme(
      color: AppColors.darkCardColor,
      shape: _cardShape,
      elevation: _elevation,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.primaryColor,
      foregroundColor: Colors.white,
      titleTextStyle: AppTypography.headline6.copyWith(color: Colors.white),
      elevation: 0,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.darkCardColor,
      selectedItemColor: AppColors.primaryLightColor,
      unselectedItemColor: Colors.white70,
    ),
    textTheme: TextTheme(
      displayLarge: AppTypography.headline1
          .copyWith(color: AppColors.darkTextPrimaryColor),
      displayMedium: AppTypography.headline2
          .copyWith(color: AppColors.darkTextPrimaryColor),
      displaySmall: AppTypography.headline3
          .copyWith(color: AppColors.darkTextPrimaryColor),
      headlineMedium: AppTypography.headline4
          .copyWith(color: AppColors.darkTextPrimaryColor),
      headlineSmall: AppTypography.headline5
          .copyWith(color: AppColors.darkTextPrimaryColor),
      titleLarge: AppTypography.headline6
          .copyWith(color: AppColors.darkTextPrimaryColor),
      titleMedium: AppTypography.subtitle1
          .copyWith(color: AppColors.darkTextPrimaryColor),
      titleSmall: AppTypography.subtitle2
          .copyWith(color: AppColors.darkTextSecondaryColor),
      bodyLarge: AppTypography.bodyText1
          .copyWith(color: AppColors.darkTextPrimaryColor),
      bodyMedium: AppTypography.bodyText2
          .copyWith(color: AppColors.darkTextSecondaryColor),
      labelLarge: AppTypography.button.copyWith(color: Colors.black),
      bodySmall: AppTypography.caption
          .copyWith(color: AppColors.darkTextSecondaryColor),
      labelSmall: AppTypography.overline
          .copyWith(color: AppColors.darkTextSecondaryColor),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: AppColors.primaryColor,
        textStyle: AppTypography.button,
        shape: _buttonShape,
        minimumSize: const Size(88, 40),
        padding: const EdgeInsets.symmetric(
            horizontal: spacing16, vertical: spacing8),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: const Size(88, 40),
        shape: _buttonShape,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkSurfaceColor,
      contentPadding: const EdgeInsets.symmetric(
          horizontal: spacing16, vertical: spacing12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_borderRadius),
        borderSide: const BorderSide(color: AppColors.darkBorderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_borderRadius),
        borderSide: const BorderSide(color: AppColors.darkBorderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_borderRadius),
        borderSide: const BorderSide(color: AppColors.primaryColor),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_borderRadius),
        borderSide: const BorderSide(color: AppColors.errorColor),
      ),
      labelStyle: AppTypography.formLabel
          .copyWith(color: AppColors.darkTextSecondaryColor),
      errorStyle: AppTypography.caption.copyWith(color: AppColors.errorColor),
    ),
    dialogTheme: DialogTheme(
      shape: _dialogShape,
      titleTextStyle: AppTypography.headline6
          .copyWith(color: AppColors.darkTextPrimaryColor),
      contentTextStyle: AppTypography.bodyText1
          .copyWith(color: AppColors.darkTextPrimaryColor),
      actionsPadding: const EdgeInsets.all(spacing16),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.darkSurfaceColor,
      contentTextStyle: AppTypography.bodyText1.copyWith(color: Colors.white),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_borderRadius),
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.darkSurfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(_borderRadius)),
      ),
    ),
    drawerTheme: const DrawerThemeData(
      backgroundColor: AppColors.darkSurfaceColor,
      elevation: _elevation,
    ),
    tabBarTheme: const TabBarTheme(
      labelColor: AppColors.primaryColor,
      unselectedLabelColor: AppColors.darkTextSecondaryColor,
      labelStyle: AppTypography.button,
      unselectedLabelStyle: AppTypography.button,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.darkSecondaryColor,
      labelStyle: AppTypography.bodyText2
          .copyWith(color: AppColors.darkTextPrimaryColor),
      selectedColor: AppColors.primaryColor,
      secondarySelectedColor: AppColors.primaryColor,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primaryColor;
        }
        return AppColors.darkTextSecondaryColor;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primaryLightColor;
        }
        return AppColors.darkSecondaryColor;
      }),
    ),
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primaryColor;
        }
        return AppColors.darkTextSecondaryColor;
      }),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primaryColor;
        }
        return AppColors.darkTextSecondaryColor;
      }),
    ),
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );
}
