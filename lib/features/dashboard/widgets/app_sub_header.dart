import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/theme_controller.dart';
import '../controllers/dashboard_controller.dart';

class AppSubHeader extends StatelessWidget {
  const AppSubHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();
    final DashboardController dashboardController = Get.find<DashboardController>();

    final views = [
      'Dashboard',
      'Courses',
      'Workspace',
      'Search',
      'Exam Schedule',
    ];

    return Obx(() {
      final palette = themeController.palette;
      final activeView = dashboardController.activeWorkspaceView.value;

      return Container(
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: palette.sidebar,
          border: Border(
            bottom: BorderSide(color: palette.borderSubtle, width: 1),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Text(
                      'WORKSPACE VIEW:',
                      style: AppTypography.monoCaption(
                        palette.textMuted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Row(
                      children: views.map((view) {
                        final isSelected = view == activeView;
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: InkWell(
                            onTap: () {
                              dashboardController.setActiveWorkspaceView(view);
                              if (view == 'Dashboard') {
                                dashboardController.setActiveSidebarItem('Dashboard');
                                dashboardController.setActiveTopTab('Dashboard');
                              } else if (view == 'Courses') {
                                dashboardController.setActiveSidebarItem('My Courses');
                                dashboardController.setActiveTopTab('Courses');
                              } else if (view == 'Workspace') {
                                dashboardController.setActiveSidebarItem('All Files');
                                dashboardController.setActiveTopTab('Library');
                              } else if (view == 'Search') {
                                dashboardController.setActiveSidebarItem('Search');
                              } else if (view == 'Exam Schedule') {
                                dashboardController.setActiveSidebarItem('Exam Schedule');
                                dashboardController.setActiveTopTab('Schedule');
                              }
                            },
                            borderRadius: BorderRadius.circular(4),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: isSelected ? palette.cardElevated : Colors.transparent,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: isSelected ? palette.borderStrong : Colors.transparent,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                view,
                                style: isSelected
                                    ? AppTypography.bodySm(palette.textPrimary).copyWith(fontWeight: FontWeight.w600)
                                    : AppTypography.bodySm(palette.textSecondary),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
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
                    'ACTIVE SESSION: 02h 45m',
                    style: AppTypography.monoCaption(palette.textMuted),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '•',
                    style: AppTypography.monoCaption(palette.textMuted),
                  ),
                  Text(
                    'SYSTEM READY',
                    style: AppTypography.monoCaption(
                      palette.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
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
