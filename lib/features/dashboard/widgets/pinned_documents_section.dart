import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_typography.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../core/widgets/mono_badge.dart';
import '../../file_manager/controllers/file_manager_controller.dart';

class PinnedDocumentsSection extends StatelessWidget {
  const PinnedDocumentsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();
    final fileController = Get.find<FileManagerController>();

    return Obx(() {
      final palette = themeController.palette;
      final pinnedDocs = fileController.files
          .where((file) => file.isPinned)
          .toList();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'Pinned Documents',
                    style: AppTypography.headlineLg(palette.textPrimary)
                        .copyWith(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '[DESK REFS]',
                    style: AppTypography.monoCaption(palette.textMuted),
                  ),
                ],
              ),
              Text(
                '${pinnedDocs.length} PINNED ITEMS',
                style: AppTypography.monoCaption(palette.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 10,
            children: pinnedDocs.map((item) {
              return _PinnedItemCard(
                name: item.name,
                code: item.course,
                palette: palette,
                onTap: () => fileController.openFile(item),
              );
            }).toList(),
          ),
        ],
      );
    });
  }
}

class _PinnedItemCard extends StatefulWidget {
  final String name;
  final String code;
  final dynamic palette;
  final VoidCallback onTap;

  const _PinnedItemCard({
    required this.name,
    required this.code,
    required this.palette,
    required this.onTap,
  });

  @override
  State<_PinnedItemCard> createState() => _PinnedItemCardState();
}

class _PinnedItemCardState extends State<_PinnedItemCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final palette = widget.palette;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: _isHovered ? palette.hover : palette.card,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: _isHovered ? palette.borderStrong : palette.borderSubtle,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.star_border, size: 14, color: palette.textSecondary),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  widget.name,
                  style: AppTypography.monoData(palette.textPrimary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              MonoBadge(
                text: widget.code,
                backgroundColor: palette.cardElevated,
                borderColor: palette.borderSubtle,
                textColor: palette.textMuted,
                fontSize: 10,
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
