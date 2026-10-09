import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../controllers/document_viewer_controller.dart';
import 'viewer_controls.dart';

class ViewerThumbnails extends StatelessWidget {
  const ViewerThumbnails({
    super.key,
    required this.controller,
    required this.palette,
    this.onClose,
  });
  final DocumentViewerController controller;
  final AppThemePalette palette;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 198,
    child: ViewerPanel(
      palette: palette,
      child: Column(
        children: [
          SizedBox(
            height: 40,
            child: Row(
              children: [
                const SizedBox(width: 10),
                Expanded(
                  child: Obx(
                    () => Text(
                      'THUMBNAILS (${controller.pageCount.value})',
                      style: AppTypography.monoCaption(palette.textMuted),
                    ),
                  ),
                ),
                ViewerButton(
                  icon: Icons.unfold_less,
                  label: 'Collapse thumbnails',
                  palette: palette,
                  onPressed: onClose ?? controller.showThumbnails.toggle,
                ),
              ],
            ),
          ),
          Expanded(
            child: Obx(
              () => ListView.builder(
                key: ValueKey(controller.bytes),
                padding: const EdgeInsets.all(10),
                itemCount: controller.pageCount.value,
                itemBuilder: (context, index) => _Thumbnail(
                  controller: controller,
                  number: index + 1,
                  palette: palette,
                ),
              ),
            ),
          ),
          const Divider(height: 1),
          ViewerButton(
            icon: Icons.chevron_left,
            label: 'Collapse thumbnail rail',
            text: 'Collapse Rail',
            palette: palette,
            onPressed: onClose ?? controller.showThumbnails.toggle,
          ),
        ],
      ),
    ),
  );
}

class _Thumbnail extends StatefulWidget {
  const _Thumbnail({
    required this.controller,
    required this.number,
    required this.palette,
  });
  final DocumentViewerController controller;
  final int number;
  final AppThemePalette palette;

  @override
  State<_Thumbnail> createState() => _ThumbnailState();
}

class _ThumbnailState extends State<_Thumbnail> {
  late final Future<Uint8List?> image = widget.controller.thumbnail(
    widget.number,
  );

  @override
  Widget build(BuildContext context) => Obx(() {
    final selected = widget.controller.page.value == widget.number;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => widget.controller.goToPage(widget.number),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: widget.palette.card,
                border: Border.all(
                  color: selected
                      ? widget.palette.textPrimary
                      : widget.palette.borderSubtle,
                  width: selected ? 2 : 1,
                ),
              ),
              child: AspectRatio(
                aspectRatio: 0.72,
                child: FutureBuilder<Uint8List?>(
                  future: image,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const Center(
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 1.5),
                        ),
                      );
                    }
                    if (snapshot.data == null) {
                      return Center(
                        child: Text(
                          'Page ${widget.number}\nPreview unavailable',
                          textAlign: TextAlign.center,
                          style: AppTypography.monoCaption(
                            widget.palette.textMuted,
                          ),
                        ),
                      );
                    }
                    return Image.memory(
                      snapshot.data!,
                      fit: BoxFit.contain,
                      gaplessPlayback: true,
                      excludeFromSemantics: true,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Page ${widget.number}',
              style: AppTypography.monoCaption(
                selected
                    ? widget.palette.textPrimary
                    : widget.palette.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  });
}
