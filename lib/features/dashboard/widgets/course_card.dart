import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../core/widgets/mono_badge.dart';
import '../controllers/dashboard_controller.dart';
import '../models/course_item.dart';

class CourseCard extends StatefulWidget {
  final CourseItem course;

  const CourseCard({super.key, required this.course});

  @override
  State<CourseCard> createState() => _CourseCardState();
}

class _CourseCardState extends State<CourseCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();
    final DashboardController dashboardController = Get.find<DashboardController>();

    return Obx(() {
      final palette = themeController.palette;

      return MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: InkWell(
          onTap: dashboardController.noOp,
          borderRadius: BorderRadius.circular(6),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _isHovered ? palette.hover : palette.card,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: _isHovered ? palette.borderStrong : palette.borderSubtle,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(
                      Icons.folder_outlined,
                      size: 16,
                      color: palette.textPrimary,
                    ),
                    Icon(
                      Icons.north_east,
                      size: 14,
                      color: palette.textMuted,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.course.title,
                      style: AppTypography.headlineMd(palette.textPrimary).copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.course.code,
                      style: AppTypography.monoCaption(palette.textMuted),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        '${widget.course.documentCount} docs',
                        style: AppTypography.monoCaption(palette.textMuted),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    MonoBadge(
                      text: widget.course.statusTag,
                      backgroundColor: Colors.transparent,
                      borderColor: Colors.transparent,
                      textColor: palette.textMuted,
                      padding: EdgeInsets.zero,
                      fontSize: 10,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
