import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/theme_controller.dart';
import '../../../core/theme/app_typography.dart';
import '../../courses/controllers/course_controller.dart';
import '../../courses/widgets/course_folder_card.dart';
import '../controllers/dashboard_controller.dart';

class CoursesSection extends StatelessWidget {
  const CoursesSection({super.key});
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CourseController>();
    final dashboard = Get.find<DashboardController>();
    final theme = Get.find<ThemeController>();
    void navigate([String? id]) {
      if (id == null) {
        controller.showOverview();
      } else {
        controller.openCourse(id);
      }
      dashboard.setActiveSidebarItem('My Courses');
      dashboard.setActiveTopTab('Courses');
    }

    return Obx(() {
      final palette = theme.palette;
      final courses =
          controller.courses.where((e) => !controller.isArchived(e.id)).toList()
            ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'My Courses · ${courses.length} active',
                  style: AppTypography.headlineLg(palette.textPrimary),
                ),
              ),
              TextButton(onPressed: navigate, child: const Text('View all →')),
            ],
          ),
          const SizedBox(height: 12),
          if (courses.isEmpty)
            OutlinedButton.icon(
              onPressed: navigate,
              icon: const Icon(Icons.add),
              label: const Text('Add your first semester and courses'),
            ),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = ((constraints.maxWidth + 16) / 285).floor().clamp(
                1,
                4,
              );
              final width =
                  (constraints.maxWidth - (columns - 1) * 16) / columns;
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: courses
                    .take(4)
                    .map(
                      (course) => SizedBox(
                        width: width,
                        height: 230,
                        child: CourseFolderCard(
                          course: course,
                          palette: palette,
                          onOpen: () => navigate(course.id),
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      );
    });
  }
}
