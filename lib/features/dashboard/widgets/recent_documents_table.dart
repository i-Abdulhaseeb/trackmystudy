import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_typography.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../core/widgets/mono_badge.dart';
import '../controllers/dashboard_controller.dart';
import '../../file_manager/controllers/file_manager_controller.dart';
import '../models/recent_document.dart';

class RecentDocumentsTable extends StatelessWidget {
  const RecentDocumentsTable({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();
    final DashboardController dashboardController =
        Get.find<DashboardController>();

    return Obx(() {
      final palette = themeController.palette;
      final selectedFilter = dashboardController.selectedFilter.value;
      final fileController = Get.find<FileManagerController>();
      final recent = fileController.recentFiles;
      final documents = recent.where(
        (doc) => selectedFilter != 'PDF_ONLY' || doc.type == 'PDF',
      );

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recently Opened',
                style: AppTypography.headlineLg(palette.textPrimary)
                    .copyWith(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              Row(
                children: [
                  Text(
                    'FILTER: ',
                    style: AppTypography.monoCaption(
                      palette.textMuted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  InkWell(
                    onTap: () => dashboardController.setFilter('ALL_TYPES'),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: selectedFilter == 'ALL_TYPES'
                                ? palette.textPrimary
                                : Colors.transparent,
                            width: 1,
                          ),
                        ),
                      ),
                      child: Text(
                        'ALL TYPES',
                        style: AppTypography.monoCaption(
                          selectedFilter == 'ALL_TYPES'
                              ? palette.textPrimary
                              : palette.textMuted,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Text(
                      '•',
                      style: AppTypography.monoCaption(palette.textMuted),
                    ),
                  ),
                  InkWell(
                    onTap: () => dashboardController.setFilter('PDF_ONLY'),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: selectedFilter == 'PDF_ONLY'
                                ? palette.textPrimary
                                : Colors.transparent,
                            width: 1,
                          ),
                        ),
                      ),
                      child: Text(
                        'PDF ONLY',
                        style: AppTypography.monoCaption(
                          selectedFilter == 'PDF_ONLY'
                              ? palette.textPrimary
                              : palette.textMuted,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: palette.borderSubtle, width: 1),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Text(
                    'NAME',
                    style: AppTypography.monoCaption(
                      palette.textMuted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'COURSE',
                    style: AppTypography.monoCaption(
                      palette.textMuted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
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
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'LAST OPENED',
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
          ...documents.map(
            (doc) => _RecentDocumentRow(
              doc: doc,
              palette: palette,
              onTap: () => doc.fileId != null
                  ? fileController.openFileById(doc.fileId!)
                  : fileController.openFileByName(doc.name),
            ),
          ),
        ],
      );
    });
  }
}

class _RecentDocumentRow extends StatefulWidget {
  final RecentDocument doc;
  final dynamic palette;
  final VoidCallback onTap;

  const _RecentDocumentRow({
    required this.doc,
    required this.palette,
    required this.onTap,
  });

  @override
  State<_RecentDocumentRow> createState() => _RecentDocumentRowState();
}

class _RecentDocumentRowState extends State<_RecentDocumentRow> {
  bool _isHovered = false;

  IconData _getFileIcon(String type) {
    switch (type.toUpperCase()) {
      case 'PDF':
        return Icons.picture_as_pdf_outlined;
      case 'PPTX':
        return Icons.slideshow_outlined;
      case 'DOCX':
        return Icons.article_outlined;
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
        onTap: widget.onTap,
        child: Container(
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: _isHovered ? palette.hover : Colors.transparent,
            border: Border(
              bottom: BorderSide(
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
                      _getFileIcon(widget.doc.type),
                      size: 15,
                      color: palette.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.doc.name,
                        style: AppTypography.bodySm(palette.textPrimary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  widget.doc.course,
                  style: AppTypography.bodySm(palette.textSecondary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Expanded(
                flex: 2,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: MonoBadge(
                    text: widget.doc.type,
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
                  alignment: Alignment.centerRight,
                  child: Text(
                    widget.doc.lastOpened,
                    style: AppTypography.monoCaption(palette.textMuted),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
