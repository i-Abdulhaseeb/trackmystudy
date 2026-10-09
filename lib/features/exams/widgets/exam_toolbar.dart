import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/theme_controller.dart';
import '../controllers/exam_controller.dart';
import 'exam_components.dart';

class ExamToolbar extends StatelessWidget {
  const ExamToolbar({super.key});

  Future<void> _showSource(
    BuildContext context,
    ExamController controller,
  ) async {
    final image = await controller.sourceImage();
    if (image == null || !context.mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        child: SizedBox(
          width: 950,
          height: MediaQuery.sizeOf(context).height * .85,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 8, 12),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Original datesheet · check the OCR result against this image',
                      ),
                    ),
                    IconButton(
                      tooltip: 'Dismiss image preview',
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: InteractiveViewer(
                  minScale: .5,
                  maxScale: 6,
                  child: Image.file(
                    image,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => const Center(
                      child: Text('The source image could not be opened.'),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ExamController>();
    final theme = Get.find<ThemeController>();
    return Obx(() {
      final palette = theme.palette;
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          _group(palette, [
            for (final filter in ExamFilter.values)
              _tab(
                palette,
                switch (filter) {
                  ExamFilter.all => 'All Exams',
                  ExamFilter.upcoming => 'Upcoming',
                  ExamFilter.completed => 'Completed',
                },
                controller.filter.value == filter,
                () => controller.filter.value = filter,
              ),
          ]),
          _group(palette, [
            _tab(
              palette,
              'List View',
              !controller.calendar.value,
              () => controller.calendar.value = false,
              Icons.view_list_outlined,
            ),
            _tab(
              palette,
              'Calendar View',
              controller.calendar.value,
              () => controller.calendar.value = true,
              Icons.calendar_month_outlined,
            ),
          ]),
          if (controller.sheets.isNotEmpty)
            Container(
              width: 310,
              height: 42,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: palette.background,
                border: Border.all(color: palette.borderStrong),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: controller.activeId.value,
                  isExpanded: true,
                  dropdownColor: palette.card,
                  icon: Icon(
                    Icons.expand_more,
                    size: 16,
                    color: palette.textSecondary,
                  ),
                  style: AppTypography.bodyMd(palette.textPrimary),
                  onChanged: controller.busy ? null : controller.selectSheet,
                  items: controller.sheets
                      .map(
                        (sheet) => DropdownMenuItem(
                          value: sheet.id,
                          child: Text(
                            'Datesheet: ${sheet.name}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          if (controller.activeSheet != null) ...[
            Tooltip(
              message: 'View original image',
              child: ExamAction(
                palette: palette,
                label: 'Source',
                icon: Icons.image_outlined,
                onPressed: () => _showSource(context, controller),
              ),
            ),
            Tooltip(
              message: 'Print the complete datesheet',
              child: ExamAction(
                palette: palette,
                label: 'Print',
                icon: Icons.print_outlined,
                loading: controller.printing.value,
                onPressed: controller.printDatesheet,
              ),
            ),
          ],
        ],
      );
    });
  }

  Widget _group(AppThemePalette palette, List<Widget> children) => Container(
    padding: const EdgeInsets.all(3),
    decoration: BoxDecoration(
      color: palette.background,
      border: Border.all(color: palette.borderStrong),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: children),
  );
  Widget _tab(
    AppThemePalette palette,
    String label,
    bool selected,
    VoidCallback onTap, [
    IconData? icon,
  ]) => TextButton(
    onPressed: onTap,
    style: TextButton.styleFrom(
      backgroundColor: selected ? palette.selected : Colors.transparent,
      foregroundColor: palette.textPrimary,
      shape: const RoundedRectangleBorder(),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[Icon(icon, size: 15), const SizedBox(width: 6)],
        Text(
          label,
          style: AppTypography.bodyMd(
            selected ? palette.textPrimary : palette.textSecondary,
          ).copyWith(fontWeight: selected ? FontWeight.w600 : FontWeight.w400),
        ),
      ],
    ),
  );
}
