import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_typography.dart';
import '../../../core/theme/theme_controller.dart';
import '../controllers/exam_controller.dart';
import '../widgets/exam_calendar.dart';
import '../widgets/exam_components.dart';
import '../widgets/exam_datesheet_table.dart';
import '../widgets/exam_toolbar.dart';
import '../widgets/next_exam_card.dart';

class ExamView extends StatelessWidget {
  const ExamView({super.key});
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ExamController>();
    final theme = Get.find<ThemeController>();
    return Obx(() {
      final palette = theme.palette;
      return ColoredBox(
        color: palette.background,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: palette.borderStrong),
                  ),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final title = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Exam Schedule',
                          style: AppTypography.headlineXl(palette.textPrimary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Your upcoming examinations and imported datesheets.',
                          style: AppTypography.bodyLg(palette.textSecondary),
                        ),
                      ],
                    );
                    final upload = ExamAction(
                      palette: palette,
                      label: controller.importing.value
                          ? 'Reading Datesheet'
                          : 'Upload Datesheet',
                      icon: Icons.upload_file_outlined,
                      primary: true,
                      loading: controller.importing.value,
                      onPressed: controller.busy
                          ? null
                          : controller.importImage,
                    );
                    return constraints.maxWidth > 650
                        ? Row(
                            children: [
                              Expanded(child: title),
                              const SizedBox(width: 20),
                              upload,
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              title,
                              const SizedBox(height: 16),
                              upload,
                            ],
                          );
                  },
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  if (controller.error.value.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: ExamPanel(
                        palette: palette,
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: palette.textPrimary,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: SelectableText(
                                controller.error.value,
                                style: AppTypography.bodyMd(
                                  palette.textPrimary,
                                ),
                              ),
                            ),
                            if (controller.activeSheet == null)
                              TextButton(
                                onPressed: controller.busy
                                    ? null
                                    : controller.reload,
                                child: const Text('Retry'),
                              ),
                            IconButton(
                              tooltip: 'Dismiss message',
                              onPressed: () => controller.error.value = '',
                              icon: const Icon(Icons.close, size: 18),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (controller.importing.value)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          LinearProgressIndicator(
                            color: palette.textPrimary,
                            backgroundColor: palette.borderSubtle,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            controller.importStatus.value,
                            style: AppTypography.bodySm(palette.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  const NextExamCard(),
                  const SizedBox(height: 20),
                  const ExamToolbar(),
                  const SizedBox(height: 12),
                  controller.calendar.value
                      ? const ExamCalendar()
                      : const ExamDatesheetTable(),
                  const SizedBox(height: 12),
                  Text(
                    'Times use Pakistan Standard Time (UTC+05:00). Check the imported text against the source image. The countdown follows the active datesheet on both screens.',
                    style: AppTypography.bodySm(palette.textMuted),
                  ),
                ]),
              ),
            ),
          ],
        ),
      );
    });
  }
}
