import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_typography.dart';
import '../../../core/theme/theme_controller.dart';
import '../controllers/exam_controller.dart';
import '../models/exam.dart';
import '../services/exam_format.dart';
import 'exam_components.dart';

class ExamDatesheetTable extends StatelessWidget {
  const ExamDatesheetTable({super.key});
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ExamController>();
    final theme = Get.find<ThemeController>();
    return Obx(() {
      final palette = theme.palette;
      final exams = controller.visibleExams;
      final active = ExamClock.at(
        controller.exams,
        controller.statusTime.value,
      ).exam;
      return ExamPanel(
        palette: palette,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: math.max(1080, constraints.maxWidth),
                  child: Table(
                    columnWidths: const {
                      0: FixedColumnWidth(50),
                      1: FlexColumnWidth(2.2),
                      2: FlexColumnWidth(1.7),
                      3: FixedColumnWidth(135),
                      4: FixedColumnWidth(212),
                      5: FlexColumnWidth(1),
                      6: FixedColumnWidth(132),
                    },
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    border: TableBorder(
                      horizontalInside: BorderSide(color: palette.borderSubtle),
                    ),
                    children: [
                      TableRow(
                        decoration: BoxDecoration(color: palette.background),
                        children:
                            [
                                  '#',
                                  'SUBJECT / CLASS',
                                  'TEACHER',
                                  'DATE',
                                  'TIME · PKT',
                                  'VENUE',
                                  'STATUS',
                                ]
                                .map(
                                  (label) => Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 20,
                                    ),
                                    child: Text(
                                      label,
                                      style: AppTypography.monoCaption(
                                        palette.textSecondary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                      ),
                      for (final exam in exams)
                        TableRow(
                          decoration: BoxDecoration(
                            color: identical(exam, active)
                                ? palette.selected
                                : palette.card,
                          ),
                          children: [
                            for (final value in [
                              '${exam.order}',
                              exam.subject,
                              exam.teacher,
                              ExamFormat.date(exam.startsAt),
                              ExamFormat.range(exam.startsAt, exam.endsAt),
                              exam.venue,
                            ])
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 24,
                                ),
                                child: SelectableText(
                                  value,
                                  style: value == exam.subject
                                      ? AppTypography.headlineMd(
                                          palette.textPrimary,
                                        )
                                      : AppTypography.bodyMd(
                                          palette.textSecondary,
                                        ),
                                ),
                              ),
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: ExamBadge(
                                palette: palette,
                                text: switch (exam.phaseAt(
                                  controller.statusTime.value,
                                )) {
                                  ExamPhase.upcoming => 'UPCOMING',
                                  ExamPhase.ongoing => 'IN PROGRESS',
                                  ExamPhase.completed => 'COMPLETED',
                                },
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
            if (exams.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 64,
                  horizontal: 24,
                ),
                child: Text(
                  controller.exams.isEmpty
                      ? 'Upload a datesheet image to see your examinations.'
                      : 'No exams match this filter.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyLg(palette.textMuted),
                ),
              ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                color: palette.background,
                border: Border(top: BorderSide(color: palette.borderStrong)),
              ),
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                spacing: 24,
                runSpacing: 8,
                children: [
                  Text(
                    'Showing ${exams.length} of ${controller.exams.length} examinations',
                    style: AppTypography.monoCaption(palette.textSecondary),
                  ),
                  Text(
                    'Sort: Chronological ▲',
                    style: AppTypography.monoCaption(palette.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}
