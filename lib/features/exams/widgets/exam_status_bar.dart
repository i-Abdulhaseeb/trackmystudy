import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_typography.dart';
import '../../../core/theme/theme_controller.dart';
import '../controllers/exam_controller.dart';
import '../models/exam.dart';
import '../services/exam_format.dart';

class ExamStatusBar extends StatelessWidget {
  const ExamStatusBar({super.key});
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ExamController>();
    final theme = Get.find<ThemeController>();
    return Obx(() {
      final palette = theme.palette;
      final upcoming = controller.exams
          .where(
            (exam) =>
                exam.phaseAt(controller.statusTime.value) !=
                ExamPhase.completed,
          )
          .length;
      final sheet = controller.activeSheet;
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: palette.surface,
          border: Border(top: BorderSide(color: palette.borderStrong)),
        ),
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          spacing: 20,
          runSpacing: 6,
          children: [
            Text(
              '$upcoming REMAINING EXAMS${sheet == null ? '' : ' · IMPORTED ${ExamFormat.date(sheet.importedAt)}'}',
              style: AppTypography.monoCaption(palette.textSecondary),
            ),
            Text(
              '${ExamFormat.zoneLabel} · LOCAL OCR · ${controller.busy ? 'PROCESSING' : 'SAVED ON DEVICE'}',
              style: AppTypography.monoCaption(palette.textMuted),
            ),
          ],
        ),
      );
    });
  }
}
