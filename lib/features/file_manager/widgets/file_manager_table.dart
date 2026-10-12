import '../../../core/widgets/name_edit_dialog.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_typography.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../core/widgets/mono_badge.dart';
import '../controllers/file_manager_controller.dart';
import '../models/app_file_model.dart';

class FileManagerTable extends StatelessWidget {
  const FileManagerTable({super.key, this.favoritesOnly = false});

  final bool favoritesOnly;

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();
    final FileManagerController fileController =
        Get.find<FileManagerController>();

    return Obx(() {
      final palette = themeController.palette;
      final files = fileController.visibleFiles(favoritesOnly: favoritesOnly);

      if (files.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(48),
          decoration: BoxDecoration(
            color: palette.card,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: palette.borderSubtle, width: 1),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.folder_open_outlined,
                  size: 40,
                  color: palette.textMuted,
                ),
                const SizedBox(height: 14),
                Text(
                  favoritesOnly ? 'No favorites found' : 'No files found',
                  style: AppTypography.headlineMd(palette.textPrimary),
                ),
                const SizedBox(height: 6),
                Text(
                  favoritesOnly
                      ? 'Star a document in All Files, a course, or the viewer to see it here. Check your filters if an item is missing.'
                      : 'Select and import PDF, DOCX, PPT, or notes from your workstation.',
                  style: AppTypography.bodySm(palette.textSecondary),
                ),
                const SizedBox(height: 18),
                if (!favoritesOnly)
                  InkWell(
                    onTap: fileController.pickAndImportFiles,
                    borderRadius: BorderRadius.circular(4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: palette.primary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Import Files',
                        style: AppTypography.bodySm(palette.onPrimary)
                            .copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      }

      return Container(
        decoration: BoxDecoration(
          color: palette.card,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: palette.borderSubtle, width: 1),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: palette.cardElevated,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(6),
                ),
                border: Border(
                  bottom: BorderSide(color: palette.borderSubtle, width: 1),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: Text(
                      'NAME & PATH',
                      style: AppTypography.monoCaption(
                        palette.textMuted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'COURSE',
                      style: AppTypography.monoCaption(
                        palette.textMuted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      'TYPE',
                      style: AppTypography.monoCaption(
                        palette.textMuted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'SIZE',
                      style: AppTypography.monoCaption(
                        palette.textMuted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'DATE ADDED',
                      style: AppTypography.monoCaption(
                        palette.textMuted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 92,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'ACTIONS',
                        style: AppTypography.monoCaption(
                          palette.textMuted,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: files.length,
              itemBuilder: (context, index) {
                final file = files[index];
                return _FileManagerRow(
                  file: file,
                  palette: palette,
                  isLast: index == files.length - 1,
                  onOpen: () => fileController.openFile(file),
                  onTogglePin: () => fileController.togglePin(file.id),
                  onDelete: () => fileController.removeFile(file.id),
                );
              },
            ),
          ],
        ),
      );
    });
  }
}

class _FileManagerRow extends StatefulWidget {
  final AppFileModel file;
  final dynamic palette;
  final bool isLast;
  final VoidCallback onOpen;
  final VoidCallback onTogglePin;
  final VoidCallback onDelete;

  const _FileManagerRow({
    required this.file,
    required this.palette,
    required this.isLast,
    required this.onOpen,
    required this.onTogglePin,
    required this.onDelete,
  });

  @override
  State<_FileManagerRow> createState() => _FileManagerRowState();
}

class _FileManagerRowState extends State<_FileManagerRow> {
  bool _isHovered = false;

  IconData _getFileIcon(String ext) {
    switch (ext.toUpperCase()) {
      case 'PDF':
        return Icons.picture_as_pdf_outlined;
      case 'PPT':
      case 'PPTX':
        return Icons.slideshow_outlined;
      case 'DOC':
      case 'DOCX':
        return Icons.article_outlined;
      case 'MD':
      case 'TXT':
        return Icons.code_outlined;
      default:
        return Icons.insert_drive_file_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = widget.palette;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        onTap: widget.onOpen,
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: _isHovered ? palette.hover : Colors.transparent,
            border: Border(
              bottom: widget.isLast
                  ? BorderSide.none
                  : BorderSide(
                      color: palette.borderSubtle.withValues(alpha: 0.5),
                      width: 1,
                    ),
              left: _isHovered
                  ? BorderSide(color: palette.textPrimary, width: 2)
                  : BorderSide(color: Colors.transparent, width: 2),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 5,
                child: Row(
                  children: [
                    Icon(
                      _getFileIcon(widget.file.extension),
                      size: 16,
                      color: palette.textSecondary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.file.name,
                            style: AppTypography.bodySm(palette.textPrimary)
                                .copyWith(fontWeight: FontWeight.w500),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            widget.file.path,
                            style: AppTypography.monoCaption(palette.textMuted),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    Get.find<FileManagerController>().courseFor(widget.file),
                    style: AppTypography.bodySm(palette.textSecondary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: MonoBadge(
                    text: widget.file.extension,
                    backgroundColor: palette.cardElevated,
                    borderColor: palette.borderSubtle,
                    textColor: palette.textSecondary,
                    fontSize: 10,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    widget.file.formattedSize,
                    style: AppTypography.monoCaption(palette.textMuted),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    widget.file.formattedDate,
                    style: AppTypography.monoCaption(palette.textMuted),
                  ),
                ),
              ),
              SizedBox(
                width: 92,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(
                      onTap: widget.onTogglePin,
                      borderRadius: BorderRadius.circular(3),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          widget.file.isPinned ? Icons.star : Icons.star_border,
                          size: 14,
                          color: widget.file.isPinned
                              ? palette.textPrimary
                              : palette.textMuted,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Rename file',
                      constraints: const BoxConstraints(
                        minWidth: 24,
                        minHeight: 24,
                      ),
                      padding: const EdgeInsets.all(4),
                      onPressed: () => showDialog<void>(
                        context: context,
                        builder: (_) => NameEditDialog(
                          title: 'Rename file',
                          initial: widget.file.name,
                          onSave: (name) => Get.find<FileManagerController>()
                              .renameFile(widget.file.id, name),
                        ),
                      ),
                      icon: Icon(
                        Icons.edit_outlined,
                        size: 14,
                        color: palette.textMuted,
                      ),
                    ),
                    const SizedBox(width: 2),
                    InkWell(
                      onTap: widget.onDelete,
                      borderRadius: BorderRadius.circular(3),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.delete_outline,
                          size: 14,
                          color: palette.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
