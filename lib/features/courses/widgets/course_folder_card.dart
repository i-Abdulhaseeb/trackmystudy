import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../controllers/course_controller.dart';
import '../models/course_workspace.dart';
import 'course_dialogs.dart';
import 'workspace_components.dart';

class CourseFolderCard extends StatelessWidget {
  const CourseFolderCard({
    super.key,
    required this.course,
    required this.palette,
    required this.onOpen,
  });
  final StudyCourse course;
  final AppThemePalette palette;
  final VoidCallback onOpen;
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CourseController>();
    return Obx(() {
      final archived = controller.isArchived(course.id);
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: archived ? palette.background : palette.cardElevated,
          border: Border.all(color: palette.borderSubtle),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  archived ? Icons.folder_zip_outlined : Icons.folder_outlined,
                  size: 18,
                  color: palette.textPrimary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: Text(
                    course.code.isEmpty ? 'COURSE' : course.code,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.monoData(palette.textSecondary),
                  ),
                ),
                if (archived || course.status.isNotEmpty)
                  Flexible(
                    flex: 3,
                    child: WorkspaceBadge(
                      archived
                          ? '[ARCHIVED]'
                          : '[${course.status.toUpperCase()}]',
                      palette: palette,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              course.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.headlineLg(palette.textPrimary)
                  .copyWith(fontSize: 16),
            ),
            const SizedBox(height: 6),
            Text(
              '${controller.fileCount(course.id)} documents · ${controller.folderCount(course.id)} folders',
              style: AppTypography.bodyLg(palette.textSecondary),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  archived ? Icons.event_available_outlined : Icons.schedule,
                  size: 17,
                  color: palette.textMuted,
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    archived
                        ? 'Semester archived'
                        : updatedLabel(course.updatedAt),
                    style: AppTypography.monoCaption(palette.textMuted),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Divider(color: palette.borderSubtle),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: OutlinedButton(
                      onPressed: onOpen,
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(2),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(archived ? 'View Archive' : 'Open Workspace'),
                          const SizedBox(width: 8),
                          Icon(
                            archived
                                ? Icons.unarchive_outlined
                                : Icons.arrow_forward,
                            size: 17,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (!archived)
                  PopupMenuButton<String>(
                    tooltip: 'Course options',
                    icon: const Icon(Icons.more_horiz, size: 18),
                    onSelected: (value) async {
                      if (value == 'edit') {
                        await CourseDialogs.course(context, course: course);
                      }
                      if (value == 'delete' &&
                          context.mounted &&
                          await CourseDialogs.confirm(
                            context,
                            'Remove course?',
                            'Its folders and file links will be removed. Documents remain in All Files.',
                          )) {
                        controller.removeCourse(course.id);
                      }
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Text('Edit course'),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Remove course'),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      );
    });
  }
}
