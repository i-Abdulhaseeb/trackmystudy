import 'package:flutter/material.dart';

class AppColors {
  static const Color darkBackground = Color(0xFF0B0B0B);
  static const Color darkSurface = Color(0xFF131313);
  static const Color darkSidebar = Color(0xFF111111);
  static const Color darkCard = Color(0xFF171717);
  static const Color darkCardElevated = Color(0xFF1C1B1B);
  static const Color darkHover = Color(0xFF202020);
  static const Color darkSelected = Color(0xFF252525);
  static const Color darkBorderSubtle = Color(0xFF2A2A2A);
  static const Color darkBorderStrong = Color(0xFF383838);
  static const Color darkTextPrimary = Color(0xFFF5F5F5);
  static const Color darkTextSecondary = Color(0xFFA3A3A3);
  static const Color darkTextMuted = Color(0xFF737373);
  static const Color darkBadgeBg = Color(0xFF1A1A1A);
  static const Color darkPrimary = Color(0xFFFFFFFF);
  static const Color darkOnPrimary = Color(0xFF111111);

  static const Color lightBackground = Color(0xFFF4F4F5);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSidebar = Color(0xFFF0F0F2);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightCardElevated = Color(0xFFF7F7F8);
  static const Color lightHover = Color(0xFFEAEAEC);
  static const Color lightSelected = Color(0xFFE2E2E5);
  static const Color lightBorderSubtle = Color(0xFFE4E4E7);
  static const Color lightBorderStrong = Color(0xFFD1D1D6);
  static const Color lightTextPrimary = Color(0xFF111111);
  static const Color lightTextSecondary = Color(0xFF52525B);
  static const Color lightTextMuted = Color(0xFF71717A);
  static const Color lightBadgeBg = Color(0xFFE4E4E7);
  static const Color lightPrimary = Color(0xFF111111);
  static const Color lightOnPrimary = Color(0xFFFFFFFF);
}

class AppThemePalette {
  final Color background;
  final Color surface;
  final Color sidebar;
  final Color card;
  final Color cardElevated;
  final Color hover;
  final Color selected;
  final Color borderSubtle;
  final Color borderStrong;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color badgeBg;
  final Color primary;
  final Color onPrimary;
  final bool isDark;

  const AppThemePalette({
    required this.background,
    required this.surface,
    required this.sidebar,
    required this.card,
    required this.cardElevated,
    required this.hover,
    required this.selected,
    required this.borderSubtle,
    required this.borderStrong,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.badgeBg,
    required this.primary,
    required this.onPrimary,
    required this.isDark,
  });

  static const AppThemePalette dark = AppThemePalette(
    background: AppColors.darkBackground,
    surface: AppColors.darkSurface,
    sidebar: AppColors.darkSidebar,
    card: AppColors.darkCard,
    cardElevated: AppColors.darkCardElevated,
    hover: AppColors.darkHover,
    selected: AppColors.darkSelected,
    borderSubtle: AppColors.darkBorderSubtle,
    borderStrong: AppColors.darkBorderStrong,
    textPrimary: AppColors.darkTextPrimary,
    textSecondary: AppColors.darkTextSecondary,
    textMuted: AppColors.darkTextMuted,
    badgeBg: AppColors.darkBadgeBg,
    primary: AppColors.darkPrimary,
    onPrimary: AppColors.darkOnPrimary,
    isDark: true,
  );

  static const AppThemePalette light = AppThemePalette(
    background: AppColors.lightBackground,
    surface: AppColors.lightSurface,
    sidebar: AppColors.lightSidebar,
    card: AppColors.lightCard,
    cardElevated: AppColors.lightCardElevated,
    hover: AppColors.lightHover,
    selected: AppColors.lightSelected,
    borderSubtle: AppColors.lightBorderSubtle,
    borderStrong: AppColors.lightBorderStrong,
    textPrimary: AppColors.lightTextPrimary,
    textSecondary: AppColors.lightTextSecondary,
    textMuted: AppColors.lightTextMuted,
    badgeBg: AppColors.lightBadgeBg,
    primary: AppColors.lightPrimary,
    onPrimary: AppColors.lightOnPrimary,
    isDark: false,
  );
}
