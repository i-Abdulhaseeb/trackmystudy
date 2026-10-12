import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/theme_controller.dart';
import '../widgets/file_manager_toolbar.dart';
import '../widgets/file_manager_table.dart';

class FileManagerView extends StatelessWidget {
  const FileManagerView({super.key, this.favoritesOnly = false});

  final bool favoritesOnly;

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();

    return Obx(() {
      final palette = themeController.palette;

      return Container(
        color: palette.background,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FileManagerToolbar(favoritesOnly: favoritesOnly),
              const SizedBox(height: 18),
              FileManagerTable(favoritesOnly: favoritesOnly),
              const SizedBox(height: 24),
            ],
          ),
        ),
      );
    });
  }
}
