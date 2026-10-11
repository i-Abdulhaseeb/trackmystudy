import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../controllers/course_controller.dart';
import '../models/course_workspace.dart';
import 'course_dialogs.dart';
import 'workspace_components.dart';

class CourseWorkspaceBody extends StatelessWidget {
  const CourseWorkspaceBody({
    super.key,
    required this.course,
    required this.palette,
  });
  final StudyCourse course;
  final AppThemePalette palette;
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CourseController>();
    return Obx(() {
      final folderId = controller.selectedFolderId.value;
      final archived = controller.isArchived(course.id);
      final folders = controller.foldersAt(course.id, folderId);
      final files = controller.filesAt(course.id, folderId);
      return SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                TextButton.icon(
                  onPressed: controller.showOverview,
                  icon: const Icon(Icons.arrow_back, size: 16),
                  label: const Text('My Courses'),
                ),
                Text(
                  '/ ${controller.semester(course.semesterId)?.name ?? ''} / ',
                  style: AppTypography.monoCaption(palette.textMuted),
                ),
                TextButton(
                  onPressed: () => controller.selectedFolderId.value = null,
                  child: Text(course.name),
                ),
                for (final folder in controller.breadcrumbs)
                  TextButton(
                    onPressed: () =>
                        controller.selectedFolderId.value = folder.id,
                    child: Text('/ ${folder.name}'),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            Opacity(
              opacity: archived ? 0.5 : 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.breadcrumbs.isEmpty
                        ? course.name
                        : controller.breadcrumbs.last.name,
                    style: AppTypography.headlineXl(palette.textPrimary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    [
                      if (course.code.isNotEmpty) course.code,
                      if (course.instructor.isNotEmpty) course.instructor,
                      if (course.credits.isNotEmpty)
                        '${course.credits} credit hours',
                      '${controller.fileCount(course.id)} documents',
                    ].join(' · '),
                    style: AppTypography.bodyLg(palette.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (archived)
              Row(
                children: [
                  const Icon(Icons.archive_outlined, size: 18),
                  const SizedBox(width: 10),
                  const Expanded(child: Text('Archived semester · Read only')),
                  TextButton(
                    onPressed: () =>
                        controller.setArchived(course.semesterId, false),
                    child: const Text('Restore semester'),
                  ),
                ],
              )
            else
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  WorkspaceButton(
                    'New Topic Folder',
                    icon: Icons.create_new_folder_outlined,
                    onPressed: () => CourseDialogs.name(
                      context,
                      title: 'New topic folder',
                      onSave: (name) => controller.saveFolder(
                        courseId: course.id,
                        parentId: folderId,
                        name: name,
                      ),
                    ),
                  ),
                  WorkspaceButton(
                    'Add Existing Files',
                    icon: Icons.library_add_outlined,
                    onPressed: () => CourseDialogs.existingFiles(
                      context,
                      course.id,
                      folderId,
                    ),
                  ),
                  WorkspaceButton(
                    controller.library.isImporting.value
                        ? 'Importing…'
                        : 'Import from Computer',
                    icon: Icons.file_upload_outlined,
                    primary: true,
                    onPressed: controller.library.isImporting.value
                        ? null
                        : () async {
                            try {
                              await controller.importFiles(course.id, folderId);
                            } catch (e) {
                              Get.snackbar(
                                'Import',
                                e.toString(),
                                snackPosition: SnackPosition.BOTTOM,
                              );
                            }
                          },
                  ),
                ],
              ),
            const SizedBox(height: 24),
            Divider(color: palette.borderSubtle),
            const SizedBox(height: 16),
            Opacity(
              opacity: archived ? 0.5 : 1,
              child: Column(
                children: [
                  if (folders.isEmpty && files.isEmpty)
                    WorkspaceEmpty(
                      title: 'This folder is empty',
                      message: archived
                          ? 'Restore the semester to make changes.'
                          : 'Create a topic folder or add documents from All Files or your computer.',
                      palette: palette,
                    ),
                  for (final folder in folders)
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: palette.card,
                        border: Border.all(color: palette.borderSubtle),
                      ),
                      child: ListTile(
                        leading: Icon(
                          Icons.folder_outlined,
                          color: palette.textPrimary,
                        ),
                        title: Text(folder.name),
                        subtitle: Text(
                          '${controller.foldersAt(course.id, folder.id).length} folders · ${controller.filesAt(course.id, folder.id).length} files',
                        ),
                        onTap: () =>
                            controller.selectedFolderId.value = folder.id,
                        trailing: archived
                            ? const Icon(Icons.chevron_right)
                            : PopupMenuButton<String>(
                                onSelected: (value) async {
                                  if (value == 'rename') {
                                    await CourseDialogs.name(
                                      context,
                                      title: 'Rename topic folder',
                                      initial: folder.name,
                                      onSave: (name) => controller.saveFolder(
                                        id: folder.id,
                                        courseId: course.id,
                                        parentId: folder.parentId,
                                        name: name,
                                      ),
                                    );
                                  }
                                  if (value == 'remove' &&
                                      context.mounted &&
                                      await CourseDialogs.confirm(
                                        context,
                                        'Remove folder?',
                                        'All nested folders and file links are removed. Documents remain in All Files.',
                                      )) {
                                    controller.removeFolder(folder);
                                  }
                                },
                                itemBuilder: (_) => [
                                  const PopupMenuItem(
                                    value: 'rename',
                                    child: Text('Rename'),
                                  ),
                                  const PopupMenuItem(
                                    value: 'remove',
                                    child: Text('Remove folder'),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  for (final file in files)
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: palette.borderSubtle),
                      ),
                      child: ListTile(
                        leading: Icon(
                          file.extension == 'PDF'
                              ? Icons.picture_as_pdf_outlined
                              : Icons.description_outlined,
                          color: palette.textSecondary,
                        ),
                        title: Text(file.name),
                        subtitle: Text(
                          '${file.extension} · ${file.formattedSize}',
                        ),
                        onTap: () => controller.library.openFile(file),
                        trailing: archived
                            ? const Icon(Icons.lock_outline, size: 16)
                            : PopupMenuButton<String>(
                                onSelected: (value) async {
                                  if (value == 'rename') {
                                    await CourseDialogs.renameFile(
                                      context,
                                      file,
                                    );
                                  }
                                  if (value == 'remove') {
                                    controller.removeLink(
                                      course.id,
                                      folderId,
                                      file.id,
                                    );
                                  }
                                  if (value == 'pin') {
                                    controller.library.togglePin(file.id);
                                  }
                                },
                                itemBuilder: (_) => [
                                  if (!controller.isFileArchived(file.id))
                                    const PopupMenuItem(
                                      value: 'rename',
                                      child: Text('Rename file everywhere'),
                                    ),
                                  PopupMenuItem(
                                    value: 'pin',
                                    child: Text(
                                      file.isPinned ? 'Unpin' : 'Pin',
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'remove',
                                    child: Text('Remove from this folder'),
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
}
