import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app_colors.dart';

class ThemeController extends GetxController {
  final RxBool isDarkMode = true.obs;

  AppThemePalette get palette =>
      isDarkMode.value ? AppThemePalette.dark : AppThemePalette.light;

  ThemeMode get themeMode =>
      isDarkMode.value ? ThemeMode.dark : ThemeMode.light;

  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
  }

  void setTheme(bool dark) {
    isDarkMode.value = dark;
  }
}
