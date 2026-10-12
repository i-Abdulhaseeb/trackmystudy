import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../controllers/course_controller.dart';
import '../models/course_workspace.dart';
import 'course_dialogs.dart';
import 'course_folder_card.dart';
import 'workspace_components.dart';

class SemesterSection extends StatelessWidget {
  const SemesterSection({
    super.key,
    required this.semester,
    required this.palette,
  });
  final Semester semester;
  final AppThemePalette palette;
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CourseController>();
    return Obx(() {
      final courses = controller.coursesFor(semester.id);
      final expanded = !controller.collapsed.contains(semester.id);
      final count = courses.fold(
        0,
        (sum, course) => sum + controller.fileCount(course.id),
      );
      return Padding(
        padding: const EdgeInsets.only(bottom: 42),
        child: Opacity(
          opacity: semester.isArchived ? 0.5 : 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: double.infinity,
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 18,
                  runSpacing: 8,
                  children: [
                    InkWell(
                      onTap: () => controller.toggleSemester(semester.id),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 12,
                          runSpacing: 8,
                          children: [
                            Icon(
                              expanded
                                  ? Icons.keyboard_arrow_down
                                  : Icons.chevron_right,
                              size: 19,
                              color: palette.textPrimary,
                            ),
                            Text(
                              '${semester.name.toUpperCase()}${semester.isArchived ? ' [ARCHIVED]' : ''}',
                              style: AppTypography.headlineLg(
                                palette.textPrimary,
                              ).copyWith(fontSize: 16),
                            ),
                            Text(
                              '${courses.length} Courses · $count Files',
                              style: AppTypography.monoData(
                                palette.textSecondary,
                              ),
                            ),
                            WorkspaceBadge(
                              semester.isArchived ? 'READ ONLY' : 'ACTIVE TERM',
                              palette: palette,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!semester.isArchived)
                          TextButton.icon(
                            onPressed: () => CourseDialogs.name(
                              context,
                              title: 'Rename semester',
                              initial: semester.name,
                              onSave: (name) =>
                                  controller.renameSemester(semester.id, name),
                            ),
                            icon: const Icon(Icons.edit_outlined, size: 17),
                            label: const Text('Rename'),
                          ),
                        TextButton.icon(
                          onPressed: () async {
                            if (!semester.isArchived &&
                                !await CourseDialogs.confirm(
                                  context,
                                  'Archive ${semester.name}?',
                                  'This semester and all its courses become dimmed and read-only. You can restore them anytime.',
                                )) {
                              return;
                            }
                            controller.setArchived(
                              semester.id,
                              !semester.isArchived,
                            );
                          },
                          icon: Icon(
                            semester.isArchived
                                ? Icons.unarchive_outlined
                                : Icons.archive_outlined,
                            size: 17,
                          ),
                          label: Text(
                            semester.isArchived ? 'Restore' : 'Archive',
                          ),
                        ),
                        if (!semester.isArchived)
                          IconButton(
                            tooltip: 'Add course to ${semester.name}',
                            onPressed: () => CourseDialogs.course(
                              context,
                              semesterId: semester.id,
                            ),
                            icon: const Icon(Icons.add, size: 18),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: palette.borderSubtle),
              if (expanded) ...[
                const SizedBox(height: 16),
                if (courses.isEmpty)
                  WorkspaceEmpty(
                    title: 'No courses yet',
                    message: semester.isArchived
                        ? 'Restore this semester to add courses.'
                        : 'Create a course folder for this semester.',
                    palette: palette,
                    action: semester.isArchived
                        ? null
                        : WorkspaceButton(
                            'New Course',
                            icon: Icons.add,
                            onPressed: () => CourseDialogs.course(
                              context,
                              semesterId: semester.id,
                            ),
                          ),
                  ),
                if (courses.isNotEmpty)
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final columns = ((constraints.maxWidth + 16) / 285)
                          .floor()
                          .clamp(1, 4);
                      final width =
                          (constraints.maxWidth - (columns - 1) * 16) / columns;
                      return Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: courses
                            .map(
                              (course) => SizedBox(
                                width: width,
                                height: 230,
                                child: CourseFolderCard(
                                  course: course,
                                  palette: palette,
                                  onOpen: () =>
                                      controller.openCourse(course.id),
                                ),
                              ),
                            )
                            .toList(),
                      );
                    },
                  ),
              ],
            ],
          ),
        ),
      );
    });
  }
}
