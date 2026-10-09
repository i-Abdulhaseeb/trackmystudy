import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_typography.dart';
import '../../../core/theme/theme_controller.dart';
import '../controllers/exam_controller.dart';
import '../services/exam_format.dart';
import 'exam_components.dart';

class ExamCalendar extends StatelessWidget {
  const ExamCalendar({super.key});
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ExamController>();
    final theme = Get.find<ThemeController>();
    return Obx(() {
      final palette = theme.palette;
      final month = controller.month.value;
      final exams = controller.visibleExams;
      final firstOffset = month.weekday - 1;
      final days = DateTime(month.year, month.month + 1, 0).day;
      final weeks = ((firstOffset + days) / 7).ceil();
      final today = ExamFormat.local(controller.statusTime.value);
      return ExamPanel(
        palette: palette,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Text(
                    '${ExamFormat.months[month.month - 1]} ${month.year}',
                    style: AppTypography.headlineLg(palette.textPrimary),
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: 'Previous month',
                    onPressed: () => controller.moveMonth(-1),
                    icon: Icon(Icons.chevron_left, color: palette.textPrimary),
                  ),
                  TextButton(
                    onPressed: () => controller.month.value = DateTime(
                      today.year,
                      today.month,
                    ),
                    child: Text(
                      'Today',
                      style: AppTypography.bodyMd(palette.textPrimary),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Next month',
                    onPressed: () => controller.moveMonth(1),
                    icon: Icon(Icons.chevron_right, color: palette.textPrimary),
                  ),
                ],
              ),
            ),
            LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 900),
                  child: SizedBox(
                    width: math.max(900, constraints.maxWidth),
                    child: Table(
                      border: TableBorder.all(color: palette.borderSubtle),
                      children: [
                        TableRow(
                          children:
                              ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN']
                                  .map(
                                    (day) => Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Text(
                                        day,
                                        style: AppTypography.monoCaption(
                                          palette.textMuted,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                        ),
                        for (var week = 0; week < weeks; week++)
                          TableRow(
                            children: [
                              for (var weekday = 0; weekday < 7; weekday++)
                                Builder(
                                  builder: (context) {
                                    final day =
                                        week * 7 + weekday - firstOffset + 1;
                                    if (day < 1 || day > days) {
                                      return const SizedBox(height: 120);
                                    }
                                    final dayExams = exams.where((exam) {
                                      final date = ExamFormat.local(
                                        exam.startsAt,
                                      );
                                      return date.year == month.year &&
                                          date.month == month.month &&
                                          date.day == day;
                                    });
                                    final isToday =
                                        today.year == month.year &&
                                        today.month == month.month &&
                                        today.day == day;
                                    return Container(
                                      constraints: const BoxConstraints(
                                        minHeight: 120,
                                      ),
                                      padding: const EdgeInsets.all(10),
                                      color: isToday ? palette.selected : null,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '$day',
                                            style: AppTypography.monoData(
                                              palette.textPrimary,
                                            ),
                                          ),
                                          for (final exam in dayExams)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                top: 10,
                                              ),
                                              child: Tooltip(
                                                message:
                                                    '${exam.teacher}\n${ExamFormat.range(exam.startsAt, exam.endsAt)}\n${exam.venue}',
                                                child: Container(
                                                  width: double.infinity,
                                                  padding: const EdgeInsets.all(
                                                    8,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: palette.background,
                                                    border: Border(
                                                      left: BorderSide(
                                                        color:
                                                            palette.textPrimary,
                                                        width: 2,
                                                      ),
                                                    ),
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        exam.subject,
                                                        style:
                                                            AppTypography.headlineMd(
                                                              palette
                                                                  .textPrimary,
                                                            ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        '${ExamFormat.time(exam.startsAt)}\n${exam.venue}',
                                                        style:
                                                            AppTypography.bodySm(
                                                              palette
                                                                  .textSecondary,
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
