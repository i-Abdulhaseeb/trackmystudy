import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../core/widgets/mono_badge.dart';
import '../controllers/dashboard_controller.dart';
import 'course_card.dart';

class CoursesSection extends StatelessWidget {
  const CoursesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();
    final DashboardController dashboardController = Get.find<DashboardController>();

    return Obx(() {
      final palette = themeController.palette;
      final courses = dashboardController.courses;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'My Courses',
                    style: AppTypography.headlineLg(palette.textPrimary).copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  MonoBadge(
                    text: '${courses.length} ACTIVE',
                    backgroundColor: palette.cardElevated,
                    borderColor: palette.borderSubtle,
                    textColor: palette.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ],
              ),
              InkWell(
                onTap: dashboardController.noOp,
                child: Row(
                  children: [
                    Text(
                      'View all',
                      style: AppTypography.bodySm(palette.textSecondary),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.chevron_right,
                      size: 14,
                      color: palette.textSecondary,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              const double spacing = 12;
              final int count = courses.length;

              return Row(
                children: courses.asMap().entries.map((entry) {
                  final index = entry.key;
                  final course = entry.value;

                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: index < count - 1 ? spacing : 0,
                      ),
                      child: CourseCard(course: course),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      );
    });
  }
}
