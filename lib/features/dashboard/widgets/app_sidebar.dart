import '../../courses/controllers/course_controller.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_typography.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../core/widgets/mono_badge.dart';
import '../../../core/widgets/shortcut_badge.dart';
import '../controllers/dashboard_controller.dart';
import '../../file_manager/controllers/file_manager_controller.dart';

class AppSidebar extends StatelessWidget {
  const AppSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();
    final DashboardController dashboardController =
        Get.find<DashboardController>();
    final FileManagerController fileController =
        Get.find<FileManagerController>();

    final courseController = Get.find<CourseController>();

    return Obx(() {
      final palette = themeController.palette;
      final activeItem = dashboardController.activeSidebarItem.value;
      final isDarkMode = themeController.isDarkMode.value;

      return Container(
        width: 250,
        decoration: BoxDecoration(
          color: palette.sidebar,
          border: Border(
            right: BorderSide(color: palette.borderSubtle, width: 1),
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
              child: Column(
                children: [
                  InkWell(
                    onTap: () {
                      dashboardController.setActiveSidebarItem('Dashboard');
                      dashboardController.setActiveTopTab('Dashboard');
                    },
                    child: Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: palette.cardElevated,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: palette.borderStrong,
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            Icons.school_outlined,
                            size: 16,
                            color: palette.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'University Manager',
                                style:
                                    AppTypography.headlineMd(
                                      palette.textPrimary,
                                    ).copyWith(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'Academic Workspace',
                                style: AppTypography.monoCaption(
                                  palette.textMuted,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  InkWell(
                    onTap: fileController.pickAndImportFiles,
                    borderRadius: BorderRadius.circular(4),
                    child: Container(
                      height: 32,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: palette.cardElevated,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: palette.borderSubtle,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add, size: 14, color: palette.textPrimary),
                          const SizedBox(width: 6),
                          Text(
                            'New Entry',
                            style: AppTypography.bodySm(palette.textPrimary)
                                .copyWith(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: palette.borderSubtle, height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _buildNavItem(
                    icon: Icons.dashboard_outlined,
                    label: 'Dashboard',
                    isSelected: activeItem == 'Dashboard',
                    palette: palette,
                    onTap: () {
                      dashboardController.setActiveSidebarItem('Dashboard');
                      dashboardController.setActiveTopTab('Dashboard');
                    },
                  ),
                  _buildNavItem(
                    icon: Icons.school_outlined,
                    label: 'My Courses',
                    isSelected: activeItem == 'My Courses',
                    palette: palette,
                    onTap: () {
                      courseController.showOverview();
                      dashboardController.setActiveSidebarItem('My Courses');
                      dashboardController.setActiveTopTab('Courses');
                    },
                  ),
                  _buildNavItem(
                    icon: Icons.search,
                    label: 'Search',
                    trailing: ShortcutBadge(
                      shortcut: 'Ctrl+K',
                      backgroundColor: palette.card,
                      borderColor: palette.borderSubtle,
                      textColor: palette.textMuted,
                    ),
                    isSelected: activeItem == 'Search',
                    palette: palette,
                    onTap: () =>
                        dashboardController.setActiveSidebarItem('Search'),
                  ),
                  _buildNavItem(
                    icon: Icons.calendar_today_outlined,
                    label: 'Exam Schedule',
                    trailing: MonoBadge(
                      text: '[URGT]',
                      backgroundColor: palette.badgeBg,
                      borderColor: palette.borderSubtle,
                      textColor: palette.textMuted,
                    ),
                    isSelected: activeItem == 'Exam Schedule',
                    palette: palette,
                    onTap: () {
                      dashboardController.setActiveSidebarItem('Exam Schedule');
                      dashboardController.setActiveTopTab('Schedule');
                    },
                  ),
                  const SizedBox(height: 14),
                  _buildSectionHeader(
                    'LIBRARY',
                    palette,
                    dashboardController.noOp,
                  ),
                  _buildNavItem(
                    icon: Icons.folder_open_outlined,
                    label: 'All Files',
                    isSelected: activeItem == 'All Files',
                    palette: palette,
                    onTap: () {
                      dashboardController.setActiveSidebarItem('All Files');
                      dashboardController.setActiveTopTab('Library');
                    },
                  ),
                  _buildNavItem(
                    icon: Icons.star_border,
                    label: 'Favorites',
                    isSelected: activeItem == 'Favorites',
                    palette: palette,
                    onTap: () =>
                        dashboardController.setActiveSidebarItem('Favorites'),
                  ),
                  _buildNavItem(
                    icon: Icons.label_outline,
                    label: 'Tags',
                    isSelected: activeItem == 'Tags',
                    palette: palette,
                    onTap: () =>
                        dashboardController.setActiveSidebarItem('Tags'),
                  ),
                  const SizedBox(height: 14),
                  _buildSectionHeader(
                    'SEMESTERS',
                    palette,
                    dashboardController.noOp,
                    trailingIcon: Icons.unfold_more,
                  ),
                  for (final semester in courseController.sortedSemesters)
                    Opacity(
                      opacity: semester.isArchived ? 0.5 : 1,
                      child: _buildSemesterGroup(
                        title: semester.name,
                        count: semester.isArchived
                            ? '[ARCH]'
                            : '[${courseController.coursesFor(semester.id).length}]',
                        isExpanded: !courseController.collapsed.contains(
                          semester.id,
                        ),
                        onToggle: () =>
                            courseController.toggleSemester(semester.id),
                        palette: palette,
                        children: [
                          for (final course in courseController.coursesFor(
                            semester.id,
                          ))
                            _buildCourseSubItem(
                              course.name,
                              course.code,
                              palette,
                              activeItem == 'My Courses' &&
                                  courseController.selectedCourseId.value ==
                                      course.id,
                              () {
                                courseController.openCourse(course.id);
                                dashboardController.setActiveSidebarItem(
                                  'My Courses',
                                );
                                dashboardController.setActiveTopTab('Courses');
                              },
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            Divider(color: palette.borderSubtle, height: 1),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  InkWell(
                    onTap: () {
                      dashboardController.setActiveSidebarItem('All Files');
                      dashboardController.setActiveTopTab('Library');
                    },
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 4,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.storage_outlined,
                                      size: 13,
                                      color: palette.textMuted,
                                    ),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        '${fileController.formattedTotalStorage} stored locally',
                                        style: AppTypography.monoCaption(
                                          palette.textMuted,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${((fileController.totalSizeBytes / (5 * 1024 * 1024 * 1024)) * 100).clamp(0, 100).toStringAsFixed(0)}%',
                                style: AppTypography.monoCaption(
                                  palette.textMuted,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: LinearProgressIndicator(
                              value:
                                  (fileController.totalSizeBytes /
                                          (5 * 1024 * 1024 * 1024))
                                      .clamp(0.01, 1.0),
                              backgroundColor: palette.cardElevated,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                palette.textSecondary,
                              ),
                              minHeight: 3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildNavItem(
                    icon: Icons.settings_outlined,
                    label: 'Settings',
                    isSelected: activeItem == 'Settings',
                    palette: palette,
                    onTap: () =>
                        dashboardController.setActiveSidebarItem('Settings'),
                  ),
                  const SizedBox(height: 6),
                  InkWell(
                    onTap: themeController.toggleTheme,
                    borderRadius: BorderRadius.circular(4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: palette.cardElevated,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: palette.borderSubtle,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isDarkMode
                                ? Icons.dark_mode_outlined
                                : Icons.light_mode_outlined,
                            size: 15,
                            color: palette.textPrimary,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              isDarkMode
                                  ? 'Dark Monochrome'
                                  : 'Light Monochrome',
                              style: AppTypography.bodySm(palette.textPrimary)
                                  .copyWith(fontWeight: FontWeight.w600),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: palette.badgeBg,
                              borderRadius: BorderRadius.circular(3),
                              border: Border.all(
                                color: palette.borderStrong,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              'SWITCH',
                              style: AppTypography.monoShortcut(
                                palette.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required dynamic palette,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          height: 30,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? palette.selected : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
            border: isSelected
                ? Border.all(color: palette.borderStrong, width: 1)
                : null,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 14,
                color: isSelected ? palette.textPrimary : palette.textSecondary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style:
                      AppTypography.bodySm(
                        isSelected
                            ? palette.textPrimary
                            : palette.textSecondary,
                      ).copyWith(
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              ?trailing,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    String title,
    dynamic palette,
    VoidCallback onTap, {
    IconData? trailingIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
      child: InkWell(
        onTap: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: AppTypography.monoCaption(
                palette.textMuted,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (trailingIcon != null)
              Icon(trailingIcon, size: 12, color: palette.textMuted),
          ],
        ),
      ),
    );
  }

  Widget _buildSemesterGroup({
    required String title,
    required String count,
    required bool isExpanded,
    required VoidCallback onToggle,
    required dynamic palette,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
          child: InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(4),
            child: Container(
              height: 28,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_down
                        : Icons.keyboard_arrow_right,
                    size: 14,
                    color: palette.textMuted,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      title,
                      style: AppTypography.bodySm(palette.textPrimary)
                          .copyWith(fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    count,
                    style: AppTypography.monoCaption(palette.textMuted),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (isExpanded)
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Column(children: children),
          ),
      ],
    );
  }

  Widget _buildCourseSubItem(
    String name,
    String code,
    dynamic palette,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          height: 26,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: isSelected ? palette.selected : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  name,
                  style: AppTypography.bodySm(
                    isSelected ? palette.textPrimary : palette.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Text(code, style: AppTypography.monoCaption(palette.textMuted)),
            ],
          ),
        ),
      ),
    );
  }
}
