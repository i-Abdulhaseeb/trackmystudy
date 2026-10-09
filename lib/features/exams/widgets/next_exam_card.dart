import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_typography.dart';
import '../../../core/theme/theme_controller.dart';
import '../../dashboard/controllers/dashboard_controller.dart';
import '../controllers/exam_controller.dart';
import '../models/exam.dart';
import '../services/exam_format.dart';
import 'exam_components.dart';

class NextExamCard extends StatelessWidget {
  const NextExamCard({super.key, this.dashboard = false});
  final bool dashboard;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ExamController>();
    final theme = Get.find<ThemeController>();
    return Obx(() {
      final palette = theme.palette;
      final clock = controller.clock;
      final exam = clock.exam;
      final loading = controller.loading.value;
      final hasSheet = controller.activeSheet != null;
      final ongoing = clock.phase == ExamPhase.ongoing;
      final details = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            exam?.subject ??
                (loading
                    ? 'Loading your datesheet…'
                    : hasSheet
                    ? 'All examinations completed'
                    : 'Your next exam starts here'),
            style: AppTypography.headlineXl(palette.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            exam == null
                ? (hasSheet
                      ? 'Upload or select your next datesheet to start a new countdown.'
                      : 'Upload a datesheet image. Your schedule and countdown will appear here.')
                : '${exam.teacher} · ${ExamFormat.date(exam.startsAt)} · ${ExamFormat.range(exam.startsAt, exam.endsAt)} · ${exam.venue}',
            style: AppTypography.bodyLg(palette.textSecondary),
          ),
          const SizedBox(height: 16),
          if (dashboard)
            TextButton(
              onPressed: () {
                final navigation = Get.find<DashboardController>();
                navigation.activeSidebarItem.value = 'Exam Schedule';
                navigation.activeTopTab.value = 'Schedule';
              },
              style: TextButton.styleFrom(
                foregroundColor: palette.textPrimary,
                padding: EdgeInsets.zero,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Open Exam Schedule',
                    style: AppTypography.headlineMd(palette.textPrimary),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward, size: 16),
                ],
              ),
            )
          else
            Text(
              exam == null
                  ? 'IMAGE IMPORT · LOCAL OCR'
                  : 'EXAM ${exam.order.toString().padLeft(2, '0')} · ${ExamFormat.zoneLabel}',
              style: AppTypography.monoCaption(palette.textMuted),
            ),
        ],
      );
      final timer = Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
        decoration: BoxDecoration(
          color: palette.background,
          border: Border.all(color: palette.borderStrong),
        ),
        child: Column(
          children: [
            Text(
              exam == null
                  ? 'NO ACTIVE COUNTDOWN'
                  : ongoing
                  ? 'TIME REMAINING UNTIL SESSION ENDS'
                  : 'TIME REMAINING UNTIL SESSION COMMENCEMENT',
              textAlign: TextAlign.center,
              style: AppTypography.monoCaption(palette.textSecondary),
            ),
            const SizedBox(height: 12),
            Semantics(
              liveRegion: false,
              label:
                  '${clock.days} days, ${clock.hours} hours, ${clock.minutes} minutes, ${clock.seconds} seconds',
              child: ExcludeSemantics(
                child: Row(
                  children: [
                    for (var index = 0; index < 4; index++) ...[
                      if (index != 0)
                        Text(
                          ':',
                          style: AppTypography.monoTimer(palette.textMuted),
                        ),
                      Expanded(
                        child: Column(
                          children: [
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                ExamFormat.two(
                                  [
                                    clock.days,
                                    clock.hours,
                                    clock.minutes,
                                    clock.seconds,
                                  ][index],
                                ),
                                style: AppTypography.monoTimer(
                                  palette.textPrimary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              ['DAYS', 'HOURS', 'MIN', 'SEC'][index],
                              style: AppTypography.monoCaption(
                                palette.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      );
      return ExamPanel(
        palette: palette,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              spacing: 16,
              runSpacing: 8,
              children: [
                Text(
                  ongoing
                      ? '▪ EXAMINATION IN PROGRESS · IMPORTED DATESHEET'
                      : '▪ NEXT UPCOMING EXAMINATION · IMPORTED DATESHEET',
                  style: AppTypography.monoData(
                    palette.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                ExamBadge(
                  palette: palette,
                  text: loading
                      ? 'LOADING'
                      : ongoing
                      ? 'IN PROGRESS'
                      : exam != null
                      ? 'UPCOMING'
                      : hasSheet
                      ? 'COMPLETED'
                      : 'AWAITING IMPORT',
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 18),
              child: Divider(height: 1, color: palette.borderStrong),
            ),
            LayoutBuilder(
              builder: (context, constraints) => constraints.maxWidth >= 850
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(child: details),
                        const SizedBox(width: 28),
                        SizedBox(width: 440, child: timer),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [details, const SizedBox(height: 16), timer],
                    ),
            ),
          ],
        ),
      );
    });
  }
}
