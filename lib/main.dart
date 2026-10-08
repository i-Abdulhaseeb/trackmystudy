import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'features/dashboard/bindings/dashboard_binding.dart';
import 'features/dashboard/views/dashboard_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const UniversityMaterialManagerApp());
}

class UniversityMaterialManagerApp extends StatelessWidget {
  const UniversityMaterialManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.put<ThemeController>(ThemeController(), permanent: true);

    return Obx(() {
      return GetMaterialApp(
        title: 'University Material Manager',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeController.themeMode,
        initialBinding: DashboardBinding(),
        home: const DashboardView(),
      );
    });
  }
}
