import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../controllers/document_viewer_controller.dart';
import 'viewer_controls.dart';

class ViewerToolbar extends StatelessWidget {
  const ViewerToolbar({
    super.key,
    required this.controller,
    required this.palette,
  });
  final DocumentViewerController controller;
  final AppThemePalette palette;

  @override
  Widget build(BuildContext context) => Obx(() {
    final c = controller;
    final ready = c.ready;
    return Center(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ViewerPanel(
          palette: palette,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ViewerButton(
                icon: Icons.chevron_left,
                label: 'Previous page',
                palette: palette,
                onPressed: ready && c.page.value > 1
                    ? () => c.goToPage(c.page.value - 1)
                    : null,
              ),
              Text('Page ', style: AppTypography.bodySm(palette.textSecondary)),
              SizedBox(
                width: 42,
                height: 30,
                child: TextField(
                  controller: c.pageInput,
                  enabled: ready,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  style: AppTypography.monoData(palette.textPrimary),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(vertical: 6),
                    filled: true,
                    fillColor: palette.cardElevated,
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: palette.borderSubtle),
                    ),
                  ),
                  onSubmitted: c.submitPage,
                ),
              ),
              Text(
                ' of ${c.pageCount.value}',
                style: AppTypography.bodySm(palette.textSecondary),
              ),
              ViewerButton(
                icon: Icons.chevron_right,
                label: 'Next page',
                palette: palette,
                onPressed: ready && c.page.value < c.pageCount.value
                    ? () => c.goToPage(c.page.value + 1)
                    : null,
              ),
              SizedBox(
                height: 22,
                child: VerticalDivider(color: palette.borderSubtle),
              ),
              ViewerButton(
                icon: Icons.zoom_out,
                label: 'Zoom out · Ctrl−',
                palette: palette,
                onPressed: ready && c.zoom.value > 1
                    ? () => c.changeZoom(-0.25)
                    : null,
              ),
              SizedBox(
                width: 52,
                child: Text(
                  '${(c.zoom.value * 100).round()}%',
                  textAlign: TextAlign.center,
                  style: AppTypography.monoData(palette.textPrimary),
                ),
              ),
              ViewerButton(
                icon: Icons.zoom_in,
                label: 'Zoom in · Ctrl+',
                palette: palette,
                onPressed: ready && c.zoom.value < 3
                    ? () => c.changeZoom(0.25)
                    : null,
              ),
              SizedBox(
                height: 22,
                child: VerticalDivider(color: palette.borderSubtle),
              ),
              ViewerButton(
                icon: Icons.fit_screen,
                label: 'Fit whole page',
                palette: palette,
                active: c.singlePage.value,
                onPressed: ready ? c.fitPage : null,
              ),
              ViewerButton(
                icon: Icons.width_normal_outlined,
                label: 'Fit width · continuous reading',
                palette: palette,
                active: !c.singlePage.value,
                onPressed: ready ? c.fitWidth : null,
              ),
              SizedBox(
                height: 22,
                child: VerticalDivider(color: palette.borderSubtle),
              ),
              ViewerButton(
                icon: c.focusMode.value
                    ? Icons.fullscreen_exit
                    : Icons.fullscreen,
                label: 'Toggle focus mode · F11',
                palette: palette,
                onPressed: c.focusMode.toggle,
              ),
            ],
          ),
        ),
      ),
    );
  });
}

class ViewerSearchBar extends StatelessWidget {
  const ViewerSearchBar({
    super.key,
    required this.controller,
    required this.palette,
  });
  final DocumentViewerController controller;
  final AppThemePalette palette;

  @override
  Widget build(BuildContext context) => ViewerPanel(
    palette: palette,
    padding: const EdgeInsets.symmetric(horizontal: 12),
    child: Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller.searchInput,
            focusNode: controller.searchFocus,
            onChanged: controller.search,
            onSubmitted: (_) => controller.nextMatch(),
            style: AppTypography.bodyMd(palette.textPrimary),
            decoration: const InputDecoration(
              hintText: 'Find in document…',
              border: InputBorder.none,
            ),
          ),
        ),
        Obx(
          () => Text(
            controller.searching.value
                ? 'Searching…'
                : '${controller.searchCurrent.value} / ${controller.searchTotal.value}',
            style: AppTypography.monoCaption(palette.textMuted),
          ),
        ),
        ViewerButton(
          icon: Icons.keyboard_arrow_up,
          label: 'Previous match',
          palette: palette,
          onPressed: controller.previousMatch,
        ),
        ViewerButton(
          icon: Icons.keyboard_arrow_down,
          label: 'Next match',
          palette: palette,
          onPressed: controller.nextMatch,
        ),
        ViewerButton(
          icon: Icons.close,
          label: 'Close search',
          palette: palette,
          onPressed: controller.toggleSearch,
        ),
      ],
    ),
  );
}
