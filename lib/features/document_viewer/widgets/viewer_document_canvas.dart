import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../controllers/document_viewer_controller.dart';

class ViewerDocumentCanvas extends StatelessWidget {
  const ViewerDocumentCanvas({
    super.key,
    required this.controller,
    required this.palette,
  });
  final DocumentViewerController controller;
  final AppThemePalette palette;

  @override
  Widget build(BuildContext context) => Obx(() {
    final c = controller;
    if (c.busy.value) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              c.status.value,
              style: AppTypography.bodyMd(palette.textSecondary),
            ),
          ],
        ),
      );
    }
    if (c.error.value.isNotEmpty) {
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.description_outlined,
                  size: 48,
                  color: palette.textMuted,
                ),
                const SizedBox(height: 16),
                Text(
                  'Unable to open document',
                  style: AppTypography.headlineLg(palette.textPrimary),
                ),
                const SizedBox(height: 10),
                Text(
                  c.error.value,
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMd(palette.textSecondary),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 12,
                  children: [
                    OutlinedButton(
                      onPressed: c.load,
                      child: const Text('Retry'),
                    ),
                    OutlinedButton(
                      onPressed: c.openExternally,
                      child: const Text('Open externally'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }
    if (c.bytes == null) return const SizedBox.shrink();
    final viewer = SfPdfViewerTheme(
      data: SfPdfViewerThemeData(
        backgroundColor: c.darkPaper.value ? Colors.white : palette.background,
      ),
      child: SfPdfViewer.memory(
        c.bytes!,
        key: ValueKey(c.bytes),
        controller: c.pdf,
        initialPageNumber: c.page.value,
        pageLayoutMode: c.singlePage.value
            ? PdfPageLayoutMode.single
            : PdfPageLayoutMode.continuous,
        canShowScrollHead: false,
        canShowScrollStatus: false,
        canShowPaginationDialog: false,
        enableTextSelection: true,
        enableHyperlinkNavigation: true,
        canShowHyperlinkDialog: true,
        pageSpacing: 16,
        onDocumentLoaded: c.onLoaded,
        onDocumentLoadFailed: c.onFailed,
        onPageChanged: c.onPageChanged,
        onZoomLevelChanged: (details) => c.zoom.value = details.newZoomLevel,
        onAnnotationAdded: c.annotationChanged,
        onAnnotationEdited: c.annotationChanged,
        onAnnotationRemoved: c.annotationChanged,
        onFormFieldValueChanged: (_) => c.markDocumentChanged(),
      ),
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 0, 22, 14),
      child: c.darkPaper.value
          ? ColorFiltered(
              colorFilter: const ColorFilter.matrix([
                -1,
                0,
                0,
                0,
                255,
                0,
                -1,
                0,
                0,
                255,
                0,
                0,
                -1,
                0,
                255,
                0,
                0,
                0,
                1,
                0,
              ]),
              child: viewer,
            )
          : viewer,
    );
  });
}
