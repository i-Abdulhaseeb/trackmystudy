import 'dart:async';

import '../../../core/widgets/name_edit_dialog.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../file_manager/controllers/file_manager_controller.dart';
import '../../file_manager/models/app_file_model.dart';
import '../controllers/course_controller.dart';
import '../models/course_workspace.dart';

class CourseDialogs {
  static Future<void> name(
    BuildContext context, {
    required String title,
    String initial = '',
    required FutureOr<void> Function(String) onSave,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (_) =>
          NameEditDialog(title: title, initial: initial, onSave: onSave),
    );
  }

  static Future<void> course(
    BuildContext context, {
    StudyCourse? course,
    String? semesterId,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (_) => _CourseForm(course: course, semesterId: semesterId),
    );
  }

  static Future<bool> confirm(
    BuildContext context,
    String title,
    String message,
  ) async =>
      await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Confirm'),
            ),
          ],
        ),
      ) ??
      false;

  static Future<void> existingFiles(
    BuildContext context,
    String courseId,
    String? folderId,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (_) =>
          _ExistingFilesDialog(courseId: courseId, folderId: folderId),
    );
  }

  static Future<void> renameFile(
    BuildContext context,
    AppFileModel file,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (_) => NameEditDialog(
        title: 'Rename file',
        initial: file.name,
        onSave: (name) =>
            Get.find<FileManagerController>().renameFile(file.id, name),
      ),
    );
  }
}

class _CourseForm extends StatefulWidget {
  const _CourseForm({this.course, this.semesterId});
  final StudyCourse? course;
  final String? semesterId;
  @override
  State<_CourseForm> createState() => _CourseFormState();
}

class _CourseFormState extends State<_CourseForm> {
  final controller = Get.find<CourseController>();
  late final fields = [
    widget.course?.name ?? '',
    widget.course?.code ?? '',
    widget.course?.instructor ?? '',
    widget.course?.credits ?? '',
    widget.course?.status ?? '',
  ].map((e) => TextEditingController(text: e)).toList();
  late String? semesterId =
      widget.course?.semesterId ??
      widget.semesterId ??
      controller.semesters.firstWhereOrNull((e) => !e.isArchived)?.id;
  String? error;
  @override
  void dispose() {
    for (final field in fields) {
      field.dispose();
    }
    super.dispose();
  }

  void submit() {
    try {
      controller.saveCourse(
        id: widget.course?.id,
        semesterId: semesterId ?? '',
        name: fields[0].text,
        code: fields[1].text,
        instructor: fields[2].text,
        credits: fields[3].text,
        status: fields[4].text,
      );
      Navigator.pop(context);
    } catch (e) {
      setState(() => error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.course == null ? 'Create course folder' : 'Edit course'),
    content: SizedBox(
      width: 480,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              initialValue: semesterId,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Semester'),
              items: controller.semesters
                  .where((e) => !e.isArchived)
                  .map(
                    (e) => DropdownMenuItem(value: e.id, child: Text(e.name)),
                  )
                  .toList(),
              onChanged: (value) => setState(() => semesterId = value),
            ),
            if (semesterId == null)
              const Padding(
                padding: EdgeInsets.only(top: 12),
                child: Text('Add or restore a semester first.'),
              ),
            for (var i = 0; i < fields.length; i++)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: TextField(
                  controller: fields[i],
                  maxLength: i == 0 ? 120 : 60,
                  keyboardType: i == 3
                      ? const TextInputType.numberWithOptions(decimal: true)
                      : TextInputType.text,
                  decoration: InputDecoration(
                    labelText: [
                      'Course name *',
                      'Course code (optional)',
                      'Instructor (optional)',
                      'Credit hours (optional)',
                      'Status label (optional)',
                    ][i],
                    counterText: '',
                  ),
                ),
              ),
            if (error != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: semesterId == null ? null : submit,
        child: const Text('Save course'),
      ),
    ],
  );
}

class _ExistingFilesDialog extends StatefulWidget {
  const _ExistingFilesDialog({required this.courseId, this.folderId});
  final String courseId;
  final String? folderId;
  @override
  State<_ExistingFilesDialog> createState() => _ExistingFilesDialogState();
}

class _ExistingFilesDialogState extends State<_ExistingFilesDialog> {
  final controller = Get.find<CourseController>();
  final selected = <String>{};
  String query = '';
  String? error;
  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Add from All Files'),
    content: SizedBox(
      width: 640,
      height: 420,
      child: Column(
        children: [
          TextField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Search imported files',
            ),
            onChanged: (value) => setState(() => query = value.toLowerCase()),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Obx(() {
              final existing = controller
                  .filesAt(widget.courseId, widget.folderId)
                  .map((e) => e.id)
                  .toSet();
              final files = controller.library.files
                  .where((e) => e.name.toLowerCase().contains(query))
                  .toList();
              if (files.isEmpty) {
                return const Center(
                  child: Text(
                    'No imported files found. Import from your computer first.',
                  ),
                );
              }
              return ListView.builder(
                itemCount: files.length,
                itemBuilder: (context, index) {
                  final file = files[index];
                  final added = existing.contains(file.id);
                  return CheckboxListTile(
                    value: added || selected.contains(file.id),
                    onChanged: added
                        ? null
                        : (value) => setState(() {
                            if (value == true) {
                              selected.add(file.id);
                            } else {
                              selected.remove(file.id);
                            }
                          }),
                    title: Text(file.name),
                    subtitle: Text(
                      added
                          ? 'Already in this folder'
                          : '${file.formattedSize} • ${file.path}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                },
              );
            }),
          ),
          if (error != null) Text(error!),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: selected.isEmpty
            ? null
            : () {
                try {
                  controller.addFiles(
                    widget.courseId,
                    widget.folderId,
                    selected,
                  );
                  Navigator.pop(context);
                } catch (e) {
                  setState(() => error = e.toString());
                }
              },
        child: Text('Add ${selected.length} files'),
      ),
    ],
  );
}
