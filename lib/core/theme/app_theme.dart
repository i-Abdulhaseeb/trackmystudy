import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: GoogleFonts.ibmPlexSans().fontFamily,
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: const ColorScheme.dark(
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkTextPrimary,
        primary: AppColors.darkPrimary,
        onPrimary: AppColors.darkOnPrimary,
        outline: AppColors.darkBorderSubtle,
        outlineVariant: AppColors.darkBorderStrong,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.darkBorderSubtle,
        thickness: 1,
        space: 1,
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: GoogleFonts.ibmPlexSans().fontFamily,
      scaffoldBackgroundColor: AppColors.lightBackground,
      colorScheme: const ColorScheme.light(
        surface: AppColors.lightSurface,
        onSurface: AppColors.lightTextPrimary,
        primary: AppColors.lightPrimary,
        onPrimary: AppColors.lightOnPrimary,
        outline: AppColors.lightBorderSubtle,
        outlineVariant: AppColors.lightBorderStrong,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.lightBorderSubtle,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
