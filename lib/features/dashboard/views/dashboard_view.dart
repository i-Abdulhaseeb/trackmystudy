import '../../courses/views/course_view.dart';
import '../../gpa/views/gpa_view.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../exams/views/exam_view.dart';
import '../../exams/widgets/exam_status_bar.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../core/widgets/shortcut_badge.dart';
import '../controllers/dashboard_controller.dart';
import '../../file_manager/controllers/file_manager_controller.dart';
import '../../file_manager/views/file_manager_view.dart';
import '../widgets/app_top_bar.dart';
import '../widgets/app_sub_header.dart';
import '../widgets/app_sidebar.dart';
import '../widgets/hero_assessment_card.dart';
import '../widgets/courses_section.dart';
import '../widgets/recent_documents_table.dart';
import '../widgets/pinned_documents_section.dart';
import '../widgets/app_footer_status_bar.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();
    final DashboardController dashboardController =
        Get.find<DashboardController>();
    final FileManagerController fileController =
        Get.find<FileManagerController>();

    return Obx(() {
      final palette = themeController.palette;
      final activeItem = dashboardController.activeSidebarItem.value;

      final isGpa = activeItem == 'GPA Calculator';
      final isCourses = activeItem == 'My Courses';
      final isExamSchedule = activeItem == 'Exam Schedule';
      final isFileManager =
          activeItem == 'All Files' ||
          activeItem == 'Favorites' ||
          activeItem == 'Tags';

      return Scaffold(
        backgroundColor: palette.background,
        body: Column(
          children: [
            const AppTopBar(),
            if (!isExamSchedule && !isCourses && !isGpa) const AppSubHeader(),
            Expanded(
              child: Row(
                children: [
                  const AppSidebar(),
                  Expanded(
                    child: isGpa
                        ? const GpaView()
                        : isCourses
                        ? const CourseView()
                        : isFileManager
                        ? FileManagerView(
                            favoritesOnly: activeItem == 'Favorites',
                          )
                        : isExamSchedule
                        ? const ExamView()
                        : Container(
                            color: palette.background,
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 20,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Dashboard',
                                            style: AppTypography.headlineXl(
                                              palette.textPrimary,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Your courses, documents, and upcoming examinations.',
                                            style: AppTypography.bodySm(
                                              palette.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                      InkWell(
                                        onTap:
                                            fileController.pickAndImportFiles,
                                        borderRadius: BorderRadius.circular(4),
                                        child: Container(
                                          height: 32,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                          ),
                                          decoration: BoxDecoration(
                                            color: palette.primary,
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.file_upload_outlined,
                                                size: 15,
                                                color: palette.onPrimary,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                'Import Files',
                                                style:
                                                    AppTypography.bodySm(
                                                      palette.onPrimary,
                                                    ).copyWith(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                              ),
                                              const SizedBox(width: 8),
                                              ShortcutBadge(
                                                shortcut: 'Ctrl+0',
                                                backgroundColor:
                                                    Colors.transparent,
                                                borderColor: palette.onPrimary
                                                    .withValues(alpha: 0.3),
                                                textColor: palette.onPrimary,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  const HeroAssessmentCard(),
                                  const SizedBox(height: 22),
                                  const CoursesSection(),
                                  const SizedBox(height: 22),
                                  const RecentDocumentsTable(),
                                  const SizedBox(height: 22),
                                  const PinnedDocumentsSection(),
                                  const SizedBox(height: 24),
                                ],
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
            if (isExamSchedule)
              const ExamStatusBar()
            else
              const AppFooterStatusBar(),
          ],
        ),
      );
    });
  }
}
