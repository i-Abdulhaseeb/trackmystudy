import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/theme_controller.dart';
import '../controllers/dashboard_controller.dart';

class AppFooterStatusBar extends StatelessWidget {
  const AppFooterStatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();
    final DashboardController dashboardController = Get.find<DashboardController>();

    return Obx(() {
      final palette = themeController.palette;

      return Container(
        height: 28,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: palette.sidebar,
          border: Border(
            top: BorderSide(color: palette.borderSubtle, width: 1),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: InkWell(
                  onTap: dashboardController.noOp,
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          border: Border.all(color: palette.textMuted, width: 1),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'INDEXED: 79 DOCUMENTS',
                        style: AppTypography.monoCaption(palette.textMuted),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '•',
                        style: AppTypography.monoCaption(palette.textMuted),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'ENCODING: UTF-8',
                        style: AppTypography.monoCaption(palette.textMuted),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '•',
                        style: AppTypography.monoCaption(palette.textMuted),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'CACHE SYNCED',
                        style: AppTypography.monoCaption(palette.textMuted),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            InkWell(
              onTap: dashboardController.noOp,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '1440 x 900',
                    style: AppTypography.monoCaption(palette.textMuted),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'WINDOW 01/01',
                    style: AppTypography.monoCaption(palette.textMuted),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'ESC TO CANCEL',
                    style: AppTypography.monoCaption(palette.textMuted),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}
