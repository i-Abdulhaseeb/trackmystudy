import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../controllers/document_viewer_controller.dart';
import 'viewer_controls.dart';

class ViewerInspector extends StatelessWidget {
  const ViewerInspector({
    super.key,
    required this.controller,
    required this.palette,
    this.onClose,
    required this.onAddNote,
  });
  final DocumentViewerController controller;
  final AppThemePalette palette;
  final VoidCallback? onClose;
  final VoidCallback onAddNote;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 298,
    child: ViewerPanel(
      palette: palette,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 14, top: 8, bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Inspector',
                    style: AppTypography.headlineMd(palette.textPrimary),
                  ),
                ),
                ViewerButton(
                  icon: Icons.chevron_right,
                  label: 'Hide inspector',
                  palette: palette,
                  onPressed: onClose ?? controller.showInspector.toggle,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Obx(
            () => Row(
              children: [
                _tab('TOC / OUTLINE', 0),
                _tab('ANNOTATIONS (${controller.notes.length})', 1),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _caption('FILE INFO'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Obx(
                          () => _stat(
                            'PAGES',
                            '${controller.pageCount.value} Pages',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _stat('SIZE', controller.file.formattedSize),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Format: ${controller.file.extension.toUpperCase()}\nEngine: Syncfusion PDF\nStorage: Local',
                    style: AppTypography.monoCaption(palette.textSecondary),
                  ),
                  if (controller.isDocx) ...[
                    const SizedBox(height: 12),
                    Text(
                      'DOCX reading preview. Fonts, pagination and complex Word layouts may differ. Open externally for the original layout.',
                      style: AppTypography.bodySm(palette.textSecondary),
                    ),
                  ],
                  const Divider(height: 28),
                  Obx(() {
                    if (controller.inspectorTab.value == 1) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _caption('PAGE NOTES & BOOKMARKS'),
                          const SizedBox(height: 10),
                          if (controller.notes.isEmpty)
                            Text(
                              'No notes yet. Add a bookmark or a note for the current page.',
                              style: AppTypography.bodySm(palette.textMuted),
                            ),
                          ...controller.notes.map(
                            (note) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: ViewerPanel(
                                palette: palette,
                                child: ListTile(
                                  dense: true,
                                  contentPadding: const EdgeInsets.only(
                                    left: 10,
                                  ),
                                  title: Text(
                                    note.text,
                                    style: AppTypography.bodySm(
                                      palette.textPrimary,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '${note.bookmark ? 'Bookmark' : 'Note'} · p.${note.page}',
                                    style: AppTypography.monoCaption(
                                      palette.textMuted,
                                    ),
                                  ),
                                  onTap: () => controller.goToPage(note.page),
                                  trailing: ViewerButton(
                                    icon: Icons.delete_outline,
                                    label: 'Remove note',
                                    palette: palette,
                                    onPressed: () =>
                                        controller.removeNote(note),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          ViewerButton(
                            icon: Icons.edit_note,
                            label: 'Add page note',
                            text: 'Add Note',
                            palette: palette,
                            onPressed: controller.ready ? onAddNote : null,
                          ),
                        ],
                      );
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _caption(
                          'STRUCTURED OUTLINE   ${controller.outline.length} SECTIONS',
                        ),
                        const SizedBox(height: 10),
                        if (controller.outline.isEmpty)
                          Text(
                            'This document has no embedded outline.',
                            style: AppTypography.bodySm(palette.textMuted),
                          ),
                        ...controller.outline.map(
                          (entry) => InkWell(
                            onTap: () =>
                                controller.pdf.jumpToBookmark(entry.bookmark),
                            child: Container(
                              color: entry.page == controller.page.value
                                  ? palette.selected
                                  : Colors.transparent,
                              padding: EdgeInsets.fromLTRB(
                                8 + entry.depth.clamp(0, 4) * 10.0,
                                10,
                                6,
                                10,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      entry.bookmark.title,
                                      style: AppTypography.bodySm(
                                        palette.textPrimary,
                                      ),
                                    ),
                                  ),
                                  if (entry.page != null)
                                    Text(
                                      ' p.${entry.page}',
                                      style: AppTypography.monoCaption(
                                        palette.textMuted,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                  const Divider(height: 28),
                  _caption('COURSE'),
                  const SizedBox(height: 8),
                  Text(
                    controller.file.course,
                    style: AppTypography.bodySm(palette.textPrimary),
                  ),
                  const SizedBox(height: 16),
                  _caption('SOURCE'),
                  const SizedBox(height: 8),
                  SelectableText(
                    controller.file.path,
                    style: AppTypography.monoCaption(palette.textMuted),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Obx(
              () => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  OutlinedButton.icon(
                    onPressed: controller.ready
                        ? () => controller.addNote(
                            'Page ${controller.page.value}',
                            bookmark: true,
                          )
                        : null,
                    icon: const Icon(Icons.bookmark_add_outlined, size: 16),
                    label: const Text('Add Bookmark'),
                  ),
                  const SizedBox(height: 6),
                  OutlinedButton.icon(
                    onPressed: controller.notes.isNotEmpty
                        ? controller.exportNotes
                        : null,
                    icon: const Icon(Icons.file_download_outlined, size: 16),
                    label: const Text('Export Notes'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _caption(String text) =>
      Text(text, style: AppTypography.monoCaption(palette.textMuted));

  Widget _stat(String label, String value) => Container(
    padding: const EdgeInsets.all(8),
    color: palette.cardElevated,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _caption(label),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTypography.monoData(
            palette.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );

  Widget _tab(String label, int index) => Expanded(
    child: InkWell(
      onTap: () => controller.inspectorTab.value = index,
      child: Container(
        alignment: Alignment.center,
        height: 48,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: controller.inspectorTab.value == index
                  ? palette.textPrimary
                  : Colors.transparent,
            ),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: AppTypography.monoCaption(
            controller.inspectorTab.value == index
                ? palette.textPrimary
                : palette.textMuted,
          ),
        ),
      ),
    ),
  );
}
