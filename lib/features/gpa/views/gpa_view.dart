import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/theme_controller.dart';
import '../controllers/gpa_controller.dart';
import '../models/gpa_scenario.dart';
import '../widgets/gpa_baseline_card.dart';
import '../widgets/gpa_components.dart';
import '../widgets/gpa_course_row.dart';
import '../widgets/gpa_results_card.dart';
import '../widgets/gpa_target_card.dart';

class GpaView extends StatelessWidget {
  const GpaView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<GpaController>();
    final theme = Get.find<ThemeController>();
    return Obx(() {
      final palette = theme.palette;
      final scenario = controller.active;
      if (controller.loading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.restoreFailed.value || scenario == null) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  controller.storageError.value,
                  style: AppTypography.bodyMd(palette.textPrimary),
                ),
                const SizedBox(height: 12),
                GpaAction(
                  palette: palette,
                  label: 'Retry opening calculator',
                  icon: Icons.refresh,
                  onPressed: controller.restore,
                ),
              ],
            ),
          ),
        );
      }
      final editable = controller.editable;
      return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 20,
              runSpacing: 12,
              alignment: WrapAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'GPA Calculator',
                      style: AppTypography.headlineXl(palette.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'UCP grading scale · semester GPA & cumulative predictions',
                      style: AppTypography.bodySm(palette.textSecondary),
                    ),
                  ],
                ),
                GpaAction(
                  palette: palette,
                  label: 'Grading scale',
                  icon: Icons.table_chart_outlined,
                  onPressed: () => _showScale(context, palette),
                ),
              ],
            ),
            const SizedBox(height: 20),
            GpaPanel(
              palette: palette,
              title: 'Saved scenarios',
              description: 'Drafts save automatically on this device. Predictions never change your confirmed academic standing.',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      SizedBox(
                        width: 260,
                        child: GpaDropdown<String>(
                          palette: palette,
                          label: 'Scenario',
                          value: scenario.id,
                          items: {
                            for (final item in controller.scenarios)
                              item.id:
                                  '${item.name.trim().isEmpty ? 'Untitled scenario' : item.name}${item.finalized ? ' · confirmed' : ''}',
                          },
                          onChanged: controller.finalizing.value
                              ? null
                              : (value) {
                                  if (value != null) {
                                    controller.selectScenario(value);
                                  }
                                },
                        ),
                      ),
                      GpaAction(
                        palette: palette,
                        label: 'New',
                        icon: Icons.add,
                        onPressed: controller.finalizing.value
                            ? null
                            : controller.newScenario,
                      ),
                      GpaAction(
                        palette: palette,
                        label: 'Duplicate',
                        icon: Icons.copy_outlined,
                        onPressed: controller.finalizing.value
                            ? null
                            : controller.duplicateScenario,
                      ),
                      GpaAction(
                        palette: palette,
                        label: 'Delete',
                        icon: Icons.delete_outline,
                        onPressed: controller.finalizing.value
                            ? null
                            : () async {
                                final confirmed = await _confirm(
                                  context,
                                  palette,
                                  'Delete this scenario?',
                                  'This removes the saved scenario. Your confirmed academic standing will stay unchanged.',
                                  'Delete',
                                );
                                if (confirmed) controller.deleteScenario();
                              },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: 420,
                    child: GpaField(
                      key: ValueKey('${scenario.id}_name'),
                      palette: palette,
                      label: 'Scenario name',
                      value: scenario.name,
                      enabled: editable,
                      onChanged: (value) => controller.updateScenario(
                        controller.active!.copyWith(name: value),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    controller.saving.value
                        ? 'Saving…'
                        : controller.storageError.value.isEmpty
                        ? 'Saved on this device'
                        : controller.storageError.value,
                    style: AppTypography.bodySm(palette.textSecondary),
                  ),
                  if (controller.storageError.value.isNotEmpty)
                    TextButton(
                      onPressed: controller.finalizing.value
                          ? null
                          : controller.save,
                      child: const Text('Retry saving'),
                    ),
                  if (scenario.finalized) ...[
                    const SizedBox(height: 10),
                    Text(
                      'Final results confirmed. This scenario is locked to prevent double-counting. Start a new scenario for the next semester.',
                      style: AppTypography.bodyMd(palette.textPrimary),
                    ),
                  ] else if (controller.staleBaseline) ...[
                    const SizedBox(height: 10),
                    Text(
                      'This scenario uses an older baseline. You can compare it, but must use the latest confirmed standing before confirming another semester.',
                      style: AppTypography.bodySm(palette.textSecondary),
                    ),
                    TextButton(
                      onPressed: controller.useConfirmedBaseline,
                      child: const Text('Use latest confirmed baseline'),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            GpaBaselineCard(controller: controller, palette: palette),
            const SizedBox(height: 16),
            GpaResultsCard(palette: palette, result: controller.result!),
            const SizedBox(height: 20),
            GpaPanel(
              palette: palette,
              title: 'Semester courses',
              description: 'Choose 1, 2 or 3 credit hours for each course. F contributes zero points but still counts in GPA credits. Decimal percentages are compared directly with the grade thresholds.',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (scenario.courses.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        'No courses yet. Add your first course to begin.',
                        style: AppTypography.bodyMd(palette.textSecondary),
                      ),
                    ),
                  for (var index = 0; index < scenario.courses.length; index++)
                    GpaCourseRow(
                      key: ValueKey(
                        '${scenario.id}_${scenario.courses[index].id}',
                      ),
                      course: scenario.courses[index],
                      palette: palette,
                      number: index + 1,
                      enabled: editable,
                      onChanged: controller.updateCourse,
                      onRemove: () =>
                          controller.removeCourse(scenario.courses[index].id),
                    ),
                  const SizedBox(height: 16),
                  GpaAction(
                    palette: palette,
                    label: 'Add course',
                    icon: Icons.add,
                    primary: true,
                    onPressed: editable && scenario.courses.length < 30
                        ? controller.addCourse
                        : null,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Withdrawn, incomplete, transfer and pass/fail courses are excluded. Repeat courses need a confirmed UCP grade-replacement policy and block predictions. Up to 30 courses per scenario.',
                    style: AppTypography.bodySm(palette.textMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            GpaTargetCard(
              palette: palette,
              scenario: scenario,
              enabled: editable,
              onChanged: (value) => controller.updateScenario(
                controller.active!.copyWith(target: value),
              ),
            ),
            const SizedBox(height: 16),
            GpaPanel(
              palette: palette,
              title: 'Confirm final semester results',
              description: 'Only use this after replacing predictions with final grades. It updates your saved academic standing, locks this scenario and opens a new semester. Excluded courses do not add degree credits automatically.',
              child: GpaAction(
                palette: palette,
                label: controller.finalizing.value
                    ? 'Confirming…'
                    : 'Confirm final results',
                icon: Icons.check_circle_outline,
                onPressed: controller.canFinalize
                    ? () async {
                        final calculation = controller.result!;
                        final confirmed = await _confirm(
                          context,
                          palette,
                          'Update your academic standing?',
                          'Confirm ${calculation.credits} GPA-bearing credits and ${calculation.predictedCgpa!.toStringAsFixed(2)} cumulative GPA as final results? This scenario will be locked and these courses will not be carried into the next semester.',
                          'Confirm results',
                        );
                        if (confirmed) await controller.finalizeResults();
                      }
                    : null,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      );
    });
  }

  Future<bool> _confirm(
    BuildContext context,
    AppThemePalette palette,
    String title,
    String message,
    String action,
  ) async =>
      await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: palette.card,
          title: Text(
            title,
            style: AppTypography.headlineLg(palette.textPrimary),
          ),
          content: SizedBox(
            width: 450,
            child: Text(
              message,
              style: AppTypography.bodyMd(palette.textSecondary),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(action),
            ),
          ],
        ),
      ) ??
      false;

  void _showScale(BuildContext context, AppThemePalette palette) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: palette.card,
        title: Text(
          'UCP grading scale',
          style: AppTypography.headlineLg(palette.textPrimary),
        ),
        content: SingleChildScrollView(
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Grade')),
              DataColumn(label: Text('Points')),
              DataColumn(label: Text('Percentage')),
            ],
            rows: [
              for (var index = 0; index < UcpGrade.scale.length; index++)
                DataRow(
                  cells: [
                    DataCell(Text(UcpGrade.scale[index].letter)),
                    DataCell(
                      Text(UcpGrade.scale[index].points.toStringAsFixed(2)),
                    ),
                    DataCell(
                      Text(
                        index == 0
                            ? '86–100'
                            : index == UcpGrade.scale.length - 1
                            ? 'Below 50'
                            : '${UcpGrade.scale[index].minimum.toInt()} to <${UcpGrade.scale[index - 1].minimum.toInt()}',
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
