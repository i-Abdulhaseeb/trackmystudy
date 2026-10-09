import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_typography.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../core/widgets/shortcut_badge.dart';
import '../controllers/dashboard_controller.dart';

class AppTopBar extends StatelessWidget {
  const AppTopBar({
    super.key,
    this.showWindowControls = false,
    this.onNavigate,
    this.onSearch,
    this.activeTabOverride,
  });

  final String? activeTabOverride;
  final bool showWindowControls;
  final VoidCallback? onNavigate;
  final VoidCallback? onSearch;

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();
    final DashboardController dashboardController =
        Get.find<DashboardController>();

    return Obx(() {
      final palette = themeController.palette;
      final activeTab =
          activeTabOverride ?? dashboardController.activeTopTab.value;

      return Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: palette.sidebar,
          border: Border(
            bottom: BorderSide(color: palette.borderSubtle, width: 1),
          ),
        ),
        child: Row(
          children: [
            InkWell(
              onTap: () {
                dashboardController.setActiveTopTab('Dashboard');
                dashboardController.setActiveSidebarItem('Dashboard');
                onNavigate?.call();
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: palette.textPrimary,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Center(
                      child: Container(
                        width: 6,
                        height: 6,
                        color: palette.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'University Material Manager',
                    style: AppTypography.headlineMd(palette.textPrimary)
                        .copyWith(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '|',
                    style: AppTypography.monoCaption(palette.borderStrong),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'v2.4.1 [DESKTOP]',
                    style: AppTypography.monoCaption(palette.textMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 420),
                  height: 28,
                  decoration: BoxDecoration(
                    color: palette.cardElevated,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: palette.borderSubtle, width: 1),
                  ),
                  child: InkWell(
                    onTap: () {
                      if (onSearch != null) {
                        onSearch!();
                        return;
                      }
                      dashboardController.setActiveSidebarItem('All Files');
                      onNavigate?.call();
                      dashboardController.setActiveTopTab('Dashboard');
                    },
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        children: [
                          Icon(
                            Icons.search,
                            size: 14,
                            color: palette.textMuted,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Search materials, notes, exams...',
                              style: AppTypography.bodySm(palette.textMuted),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          ShortcutBadge(
                            shortcut: 'Ctrl+K',
                            backgroundColor: palette.card,
                            borderColor: palette.borderSubtle,
                            textColor: palette.textMuted,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTopTab(
                  'Dashboard',
                  activeTab == 'Dashboard',
                  palette,
                  () {
                    dashboardController.setActiveTopTab('Dashboard');
                    dashboardController.setActiveSidebarItem('Dashboard');
                    onNavigate?.call();
                  },
                ),
                _buildTopTab('Courses', activeTab == 'Courses', palette, () {
                  dashboardController.setActiveTopTab('Courses');
                  dashboardController.setActiveSidebarItem('My Courses');
                  onNavigate?.call();
                }),
                _buildTopTab('Library', activeTab == 'Library', palette, () {
                  dashboardController.setActiveTopTab('Library');
                  dashboardController.setActiveSidebarItem('All Files');
                  onNavigate?.call();
                }),
                _buildTopTab('Schedule', activeTab == 'Schedule', palette, () {
                  dashboardController.setActiveTopTab('Schedule');
                  dashboardController.setActiveSidebarItem('Exam Schedule');
                  onNavigate?.call();
                }),
              ],
            ),
            const SizedBox(width: 14),
            InkWell(
              onTap: dashboardController.noOp,
              borderRadius: BorderRadius.circular(3),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  border: Border.all(color: palette.borderStrong, width: 1),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  'UM',
                  style: AppTypography.monoShortcut(palette.textPrimary),
                ),
              ),
            ),
            if (showWindowControls) const SizedBox(width: 12),
            if (showWindowControls)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildWindowControl(
                    Icons.minimize,
                    palette,
                    dashboardController.noOp,
                  ),
                  const SizedBox(width: 6),
                  _buildWindowControl(
                    Icons.crop_square,
                    palette,
                    dashboardController.noOp,
                  ),
                  const SizedBox(width: 6),
                  _buildWindowControl(
                    Icons.close,
                    palette,
                    dashboardController.noOp,
                  ),
                ],
              ),
          ],
        ),
      );
    });
  }

  Widget _buildTopTab(
    String title,
    bool isActive,
    dynamic palette,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        height: 44,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive ? palette.textPrimary : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Center(
          child: Text(
            title,
            style:
                AppTypography.bodyMd(
                  isActive ? palette.textPrimary : palette.textSecondary,
                ).copyWith(
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                ),
          ),
        ),
      ),
    );
  }

  Widget _buildWindowControl(
    IconData icon,
    dynamic palette,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(3),
      child: Container(
        width: 22,
        height: 22,
        alignment: Alignment.center,
        child: Icon(icon, size: 13, color: palette.textMuted),
      ),
    );
  }
}
