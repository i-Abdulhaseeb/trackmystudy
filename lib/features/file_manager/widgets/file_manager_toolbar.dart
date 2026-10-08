import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_typography.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../core/widgets/mono_badge.dart';
import '../../../core/widgets/shortcut_badge.dart';
import '../controllers/file_manager_controller.dart';

class FileManagerToolbar extends StatelessWidget {
  const FileManagerToolbar({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();
    final FileManagerController fileController =
        Get.find<FileManagerController>();

    final filterOptions = ['ALL', 'PDF', 'PPTX', 'DOCX', 'MD'];

    return Obx(() {
      final palette = themeController.palette;
      final currentFilter = fileController.selectedFilter.value;
      final currentSort = fileController.sortBy.value;
      final isAsc = fileController.sortAscending.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'All Files',
                          style: AppTypography.headlineXl(palette.textPrimary),
                        ),
                        const SizedBox(width: 10),
                        MonoBadge(
                          text: '${fileController.totalFilesCount} FILES',
                          backgroundColor: palette.cardElevated,
                          borderColor: palette.borderSubtle,
                          textColor: palette.textSecondary,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                        const SizedBox(width: 8),
                        MonoBadge(
                          text: fileController.formattedTotalStorage,
                          backgroundColor: palette.cardElevated,
                          borderColor: palette.borderSubtle,
                          textColor: palette.textMuted,
                          fontSize: 10,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Local document repository, imported syllabus, lecture slides, and notes.',
                      style: AppTypography.bodySm(palette.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              InkWell(
                onTap: fileController.pickAndImportFiles,
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  height: 32,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: palette.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.file_upload_outlined,
                        size: 15,
                        color: palette.onPrimary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Import Files',
                        style: AppTypography.bodySm(palette.onPrimary)
                            .copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 8),
                      ShortcutBadge(
                        shortcut: 'Ctrl+0',
                        backgroundColor: Colors.transparent,
                        borderColor: palette.onPrimary.withValues(alpha: 0.3),
                        textColor: palette.onPrimary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: palette.card,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: palette.borderSubtle, width: 1),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    height: 28,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: palette.cardElevated,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: palette.borderSubtle, width: 1),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search, size: 14, color: palette.textMuted),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            onChanged: fileController.setSearchQuery,
                            style: AppTypography.bodySm(palette.textPrimary),
                            cursorColor: palette.textPrimary,
                            decoration: InputDecoration(
                              hintText: 'Filter files by name or course...',
                              hintStyle: AppTypography.bodySm(
                                palette.textMuted,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Row(
                  children: filterOptions.map((filter) {
                    final isSelected = currentFilter == filter;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: InkWell(
                        onTap: () => fileController.setFilter(filter),
                        borderRadius: BorderRadius.circular(3),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? palette.selected
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(3),
                            border: Border.all(
                              color: isSelected
                                  ? palette.borderStrong
                                  : palette.borderSubtle,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            filter,
                            style: AppTypography.monoCaption(
                              isSelected
                                  ? palette.textPrimary
                                  : palette.textMuted,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const Spacer(),
                Row(
                  children: [
                    Text(
                      'SORT:',
                      style: AppTypography.monoCaption(
                        palette.textMuted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 6),
                    _buildSortButton(
                      'date',
                      'DATE',
                      currentSort,
                      isAsc,
                      palette,
                      fileController,
                    ),
                    const SizedBox(width: 4),
                    _buildSortButton(
                      'name',
                      'NAME',
                      currentSort,
                      isAsc,
                      palette,
                      fileController,
                    ),
                    const SizedBox(width: 4),
                    _buildSortButton(
                      'size',
                      'SIZE',
                      currentSort,
                      isAsc,
                      palette,
                      fileController,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget _buildSortButton(
    String key,
    String label,
    String currentSort,
    bool isAsc,
    dynamic palette,
    FileManagerController controller,
  ) {
    final isSelected = currentSort == key;

    return InkWell(
      onTap: () => controller.setSortBy(key),
      borderRadius: BorderRadius.circular(3),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: isSelected ? palette.selected : Colors.transparent,
          borderRadius: BorderRadius.circular(3),
          border: Border.all(
            color: isSelected ? palette.borderStrong : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTypography.monoCaption(
                isSelected ? palette.textPrimary : palette.textMuted,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 2),
              Icon(
                isAsc ? Icons.arrow_upward : Icons.arrow_downward,
                size: 10,
                color: palette.textPrimary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
