import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_typography.dart';
import '../../../core/theme/theme_controller.dart';
import '../controllers/course_controller.dart';
import '../widgets/course_dialogs.dart';
import '../widgets/semester_section.dart';
import '../widgets/workspace_components.dart';
import '../widgets/course_workspace_body.dart';

class CourseView extends StatelessWidget {
  const CourseView({super.key});
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CourseController>();
    final theme = Get.find<ThemeController>();
    return Obx(() {
      final palette = theme.palette;
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.loadError.value != null) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Text(controller.loadError.value!),
          ),
        );
      }
      final selected = controller.selectedCourse;
      return Column(
        children: [
          if (controller.saveError.value != null)
            MaterialBanner(
              content: Text(controller.saveError.value!),
              actions: [
                TextButton(
                  onPressed: controller.save,
                  child: const Text('Retry save'),
                ),
              ],
            ),
          if (controller.isSaving.value)
            const LinearProgressIndicator(minHeight: 2),
          Expanded(
            child: selected != null
                ? CourseWorkspaceBody(course: selected, palette: palette)
                : SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(30, 24, 30, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'REPOSITORY / ACADEMIC WORKSPACE / MY COURSES',
                          style: AppTypography.monoCaption(palette.textMuted),
                        ),
                        const SizedBox(height: 12),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final title = Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'My Courses',
                                  style: AppTypography.headlineXl(
                                    palette.textPrimary,
                                  ).copyWith(fontSize: 28),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Manage your semesters, courses, and study materials.',
                                  style: AppTypography.bodyLg(
                                    palette.textSecondary,
                                  ),
                                ),
                              ],
                            );
                            final actions = Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: [
                                WorkspaceButton(
                                  'New Semester',
                                  icon: Icons.create_new_folder_outlined,
                                  onPressed: () => CourseDialogs.name(
                                    context,
                                    title: 'New semester',
                                    onSave: (name) {
                                      controller.addSemester(name);
                                    },
                                  ),
                                ),
                                WorkspaceButton(
                                  'New Course',
                                  icon: Icons.add,
                                  primary: true,
                                  onPressed:
                                      controller.semesters.any(
                                        (e) => !e.isArchived,
                                      )
                                      ? () => CourseDialogs.course(context)
                                      : null,
                                ),
                              ],
                            );
                            if (constraints.maxWidth < 800) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  title,
                                  const SizedBox(height: 18),
                                  actions,
                                ],
                              );
                            }
                            return Row(
                              children: [
                                Expanded(child: title),
                                actions,
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                        Divider(color: palette.borderSubtle),
                        const SizedBox(height: 20),
                        if (controller.semesters.isEmpty)
                          WorkspaceEmpty(
                            title: 'Build your academic workspace',
                            message: 'Start with a semester, then add your courses and topic folders.',
                            palette: palette,
                            action: WorkspaceButton(
                              'New Semester',
                              icon: Icons.create_new_folder_outlined,
                              onPressed: () => CourseDialogs.name(
                                context,
                                title: 'New semester',
                                onSave: (name) {
                                  controller.addSemester(name);
                                },
                              ),
                            ),
                          ),
                        for (final semester in controller.sortedSemesters)
                          SemesterSection(semester: semester, palette: palette),
                      ],
                    ),
                  ),
          ),
        ],
      );
    });
  }
}
