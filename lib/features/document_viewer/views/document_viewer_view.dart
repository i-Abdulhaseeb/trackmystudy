import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/theme_controller.dart';
import '../../dashboard/widgets/app_top_bar.dart';
import '../../file_manager/models/app_file_model.dart';
import '../../file_manager/controllers/file_manager_controller.dart';
import '../widgets/viewer_library_search.dart';
import '../controllers/document_viewer_controller.dart';
import '../widgets/viewer_controls.dart';
import '../widgets/viewer_document_canvas.dart';
import '../widgets/viewer_inspector.dart';
import '../widgets/viewer_thumbnails.dart';
import '../widgets/viewer_toolbar.dart';

class DocumentViewerView extends StatefulWidget {
  const DocumentViewerView({
    super.key,
    required this.file,
    required this.onTogglePin,
  });
  final AppFileModel file;
  final VoidCallback onTogglePin;

  @override
  State<DocumentViewerView> createState() => _DocumentViewerViewState();
}

class _DocumentViewerViewState extends State<DocumentViewerView> {
  late final String tag = 'viewer-${widget.file.id}-${identityHashCode(this)}';
  late final DocumentViewerController c;
  bool _leaving = false;

  @override
  void initState() {
    super.initState();
    c = Get.put(
      DocumentViewerController(
        file: widget.file,
        onTogglePin: widget.onTogglePin,
      ),
      tag: tag,
    );
    c.darkPaper.value = Get.find<ThemeController>().isDarkMode.value;
  }

  @override
  void dispose() {
    Get.delete<DocumentViewerController>(tag: tag);
    super.dispose();
  }

  Future<void> _back() async {
    if (_leaving) return;
    _leaving = true;
    if (!await c.flush()) {
      _leaving = false;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Annotations could not be saved. Export a PDF copy, then retry.',
            ),
          ),
        );
      }
      return;
    }
    if (!mounted) return;
    setState(() {});
    await WidgetsBinding.instance.endOfFrame;
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _addNote() async {
    final input = TextEditingController();
    final value = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Note for page ${c.page.value}'),
        content: SizedBox(
          width: 440,
          child: TextField(
            controller: input,
            autofocus: true,
            minLines: 4,
            maxLines: 10,
            maxLength: 10000,
            decoration: const InputDecoration(
              hintText: 'Write your study note…',
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (input.text.trim().isNotEmpty) {
                Navigator.pop(context, input.text.trim());
              }
            },
            child: const Text('Save Note'),
          ),
        ],
      ),
    );
    input.dispose();
    if (value != null && mounted) await c.addNote(value);
  }

  Future<void> _searchLibrary() async {
    final file = await showDialog<AppFileModel>(
      context: context,
      builder: (_) => const ViewerLibrarySearch(),
    );
    if (file == null || !mounted || file.id == widget.file.id) return;
    await _back();
    if (_leaving) Get.find<FileManagerController>().openFile(file);
  }

  @override
  Widget build(BuildContext context) => CallbackShortcuts(
    bindings: {
      const SingleActivator(LogicalKeyboardKey.keyK, control: true):
          _searchLibrary,
      const SingleActivator(LogicalKeyboardKey.keyF, control: true):
          c.toggleSearch,
      const SingleActivator(LogicalKeyboardKey.keyE, control: true):
          c.openExternally,
      const SingleActivator(LogicalKeyboardKey.keyP, control: true):
          c.printDocument,
      const SingleActivator(LogicalKeyboardKey.keyS, control: true):
          c.exportPdf,
      const SingleActivator(LogicalKeyboardKey.equal, control: true): () =>
          c.changeZoom(0.25),
      const SingleActivator(LogicalKeyboardKey.minus, control: true): () =>
          c.changeZoom(-0.25),
      const SingleActivator(LogicalKeyboardKey.f11): c.focusMode.toggle,
      const SingleActivator(LogicalKeyboardKey.escape): () {
        if (c.showSearch.value) {
          c.toggleSearch();
        } else if (c.focusMode.value) {
          c.focusMode.value = false;
        } else {
          _back();
        }
      },
    },
    child: Focus(
      autofocus: true,
      child: Obx(() {
        final palette = Get.find<ThemeController>().palette;
        final focused = c.focusMode.value;
        final thumbnailsVisible = c.showThumbnails.value;
        final inspectorVisible = c.showInspector.value;
        return PopScope(
          canPop: _leaving,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) _back();
          },
          child: Scaffold(
            backgroundColor: palette.background,
            body: Column(
              children: [
                if (!focused) ...[
                  LayoutBuilder(
                    builder: (context, constraints) => SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        width: constraints.maxWidth < 1100
                            ? 1100
                            : constraints.maxWidth,
                        child: AppTopBar(
                          showWindowControls: false,
                          onNavigate: _back,
                          onSearch: _searchLibrary,
                          activeTabOverride: 'Library',
                        ),
                      ),
                    ),
                  ),
                  _header(palette),
                ],
                if (c.showSearch.value)
                  ViewerSearchBar(controller: c, palette: palette),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final rail =
                          !focused &&
                          thumbnailsVisible &&
                          constraints.maxWidth >= 900;
                      final inspector =
                          !focused &&
                          inspectorVisible &&
                          constraints.maxWidth >= 1180;
                      return Row(
                        children: [
                          if (rail)
                            ViewerThumbnails(controller: c, palette: palette),
                          Expanded(
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                    horizontal: 8,
                                  ),
                                  child: ViewerToolbar(
                                    controller: c,
                                    palette: palette,
                                  ),
                                ),
                                Expanded(
                                  child: ViewerDocumentCanvas(
                                    controller: c,
                                    palette: palette,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (inspector)
                            ViewerInspector(
                              controller: c,
                              palette: palette,
                              onAddNote: _addNote,
                            ),
                        ],
                      );
                    },
                  ),
                ),
                _status(palette),
              ],
            ),
          ),
        );
      }),
    ),
  );

  Widget _header(AppThemePalette palette) => ViewerPanel(
    palette: palette,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
    child: Row(
      children: [
        ViewerButton(
          icon: Icons.arrow_back,
          label: 'Return to previous screen',
          text: 'Back',
          palette: palette,
          onPressed: _back,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Tooltip(
            message: '${widget.file.course} / ${widget.file.name}',
            child: Text(
              '${widget.file.course}  /  ${widget.file.name}',
              overflow: TextOverflow.ellipsis,
              style: AppTypography.bodyMd(palette.textPrimary),
            ),
          ),
        ),
        ViewerButton(
          icon: Icons.search,
          label: 'Find · Ctrl+F',
          palette: palette,
          onPressed: c.toggleSearch,
        ),
        Obx(
          () => ViewerButton(
            icon: c.pinned.value ? Icons.star : Icons.star_border,
            label: 'Pin document',
            palette: palette,
            active: c.pinned.value,
            onPressed: c.togglePin,
          ),
        ),
        ViewerButton(
          icon: Icons.refresh,
          label: 'Reload document',
          palette: palette,
          onPressed: () async {
            if (await c.flush()) await c.load();
          },
        ),
        ViewerButton(
          icon: Icons.print_outlined,
          label: 'Print · Ctrl+P',
          palette: palette,
          onPressed: c.ready && !c.printing.value ? c.printDocument : null,
        ),
        ViewerButton(
          icon: Icons.open_in_new,
          label: 'Open externally · Ctrl+E',
          palette: palette,
          onPressed: c.openExternally,
        ),
        PopupMenuButton<String>(
          tooltip: 'Viewer options',
          icon: Icon(Icons.more_horiz, size: 18, color: palette.textPrimary),
          onSelected: (value) {
            switch (value) {
              case 'thumbnails':
                _thumbnails(palette);
              case 'inspector':
                _inspector(palette);
              case 'night':
                c.darkPaper.toggle();
              case 'export':
                c.exportPdf();
              case 'note':
                _addNote();
              case 'highlight':
                c.pdf.annotationMode = PdfAnnotationMode.highlight;
              case 'select':
                c.pdf.annotationMode = PdfAnnotationMode.none;
            }
          },
          itemBuilder: (_) => [
            const PopupMenuItem(
              value: 'thumbnails',
              child: Text('Toggle thumbnails'),
            ),
            const PopupMenuItem(
              value: 'inspector',
              child: Text('Toggle inspector'),
            ),
            const PopupMenuItem(
              value: 'night',
              child: Text('Toggle dark paper'),
            ),
            PopupMenuItem(
              value: 'note',
              enabled: c.ready,
              child: const Text('Add page note'),
            ),
            PopupMenuItem(
              value: 'highlight',
              enabled: c.ready,
              child: const Text('Highlight text'),
            ),
            PopupMenuItem(
              value: 'select',
              enabled: c.ready,
              child: const Text('Select text'),
            ),
            PopupMenuItem(
              value: 'export',
              enabled: c.ready,
              child: const Text('Export PDF copy · Ctrl+S'),
            ),
          ],
        ),
      ],
    ),
  );

  void _thumbnails(AppThemePalette palette) {
    if (MediaQuery.sizeOf(context).width < 900) {
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (sheetContext) => SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.8,
          child: ViewerThumbnails(
            controller: c,
            palette: palette,
            onClose: () => Navigator.pop(sheetContext),
          ),
        ),
      );
    } else {
      c.showThumbnails.toggle();
    }
  }

  void _inspector(AppThemePalette palette) {
    if (MediaQuery.sizeOf(context).width < 1180) {
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (sheetContext) => SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.8,
          child: ViewerInspector(
            controller: c,
            palette: palette,
            onAddNote: _addNote,
            onClose: () => Navigator.pop(sheetContext),
          ),
        ),
      );
    } else {
      c.showInspector.toggle();
    }
  }

  Widget _status(AppThemePalette palette) => ViewerPanel(
    palette: palette,
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Obx(
        () => Row(
          children: [
            Icon(Icons.circle, size: 8, color: palette.textPrimary),
            const SizedBox(width: 7),
            Text(
              c.status.value,
              style: AppTypography.monoCaption(palette.textPrimary),
            ),
            const SizedBox(width: 24),
            Text(
              'Reading Mode: ${c.singlePage.value ? 'Single Page' : 'Continuous'}     |     Render Engine: Syncfusion     |     ${widget.file.extension}     |     Page ${c.page.value}/${c.pageCount.value}     |     Zoom: ${(c.zoom.value * 100).round()}%',
              style: AppTypography.monoCaption(palette.textSecondary),
            ),
          ],
        ),
      ),
    ),
  );
}
