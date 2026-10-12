import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../models/gpa_scenario.dart';
import 'gpa_components.dart';

class GpaCourseRow extends StatelessWidget {
  const GpaCourseRow({
    super.key,
    required this.course,
    required this.palette,
    required this.onChanged,
    required this.onRemove,
    required this.enabled,
    required this.number,
  });

  final GpaCourse course;
  final AppThemePalette palette;
  final ValueChanged<GpaCourse> onChanged;
  final VoidCallback onRemove;
  final bool enabled;
  final int number;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 16),
    decoration: BoxDecoration(
      border: Border(bottom: BorderSide(color: palette.borderSubtle)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'COURSE ${number.toString().padLeft(2, '0')}',
              style: AppTypography.monoCaption(palette.textMuted),
            ),
            const Spacer(),
            Text(
              !course.included
                  ? 'EXCLUDED'
                  : course.grade == null
                  ? 'AWAITING GRADE'
                  : '${course.grade!.letter}  ·  ${(course.grade!.points * course.credits).toStringAsFixed(2)} QUALITY POINTS',
              style: AppTypography.monoCaption(palette.textSecondary),
            ),
            IconButton(
              tooltip: 'Remove course',
              onPressed: enabled ? onRemove : null,
              icon: const Icon(Icons.close, size: 16),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 12,
          runSpacing: 14,
          children: [
            SizedBox(
              width: 220,
              child: GpaField(
                palette: palette,
                label: 'Course name · optional',
                value: course.name,
                enabled: enabled,
                onChanged: (value) => onChanged(course.copyWith(name: value)),
              ),
            ),
            SizedBox(
              width: 100,
              child: GpaDropdown<int>(
                palette: palette,
                label: 'Credits',
                value: course.credits,
                items: const {1: '1 CH', 2: '2 CH', 3: '3 CH'},
                onChanged: enabled
                    ? (value) {
                        if (value != null) {
                          onChanged(course.copyWith(credits: value));
                        }
                      }
                    : null,
              ),
            ),
            SizedBox(
              width: 160,
              child: GpaDropdown<GpaInputMode>(
                palette: palette,
                label: 'Input',
                value: course.mode,
                items: const {
                  GpaInputMode.letter: 'Letter grade',
                  GpaInputMode.percentage: 'Percentage',
                },
                onChanged: enabled && course.included
                    ? (value) {
                        if (value != null) {
                          onChanged(course.copyWith(mode: value));
                        }
                      }
                    : null,
              ),
            ),
            SizedBox(
              width: 180,
              child: course.mode == GpaInputMode.letter
                  ? GpaDropdown<String>(
                      palette: palette,
                      label: 'Predicted grade',
                      value: course.letter.isEmpty ? null : course.letter,
                      items: {
                        for (final grade in UcpGrade.scale)
                          grade.letter:
                              '${grade.letter} · ${grade.points.toStringAsFixed(2)}',
                      },
                      onChanged: enabled && course.included
                          ? (value) {
                              if (value != null) {
                                onChanged(course.copyWith(letter: value));
                              }
                            }
                          : null,
                    )
                  : GpaField(
                      key: ValueKey('${course.id}_percentage'),
                      palette: palette,
                      label: 'Percentage · 0–100',
                      value: course.percentage,
                      numeric: true,
                      enabled: enabled && course.included,
                      error: course.included && course.grade == null
                          ? 'Enter a value from 0 to 100.'
                          : null,
                      onChanged: (value) =>
                          onChanged(course.copyWith(percentage: value)),
                    ),
            ),
            SizedBox(
              width: 190,
              child: GpaDropdown<GpaCourseKind>(
                palette: palette,
                label: 'Course status',
                value: course.kind,
                items: const {
                  GpaCourseKind.regular: 'GPA-bearing',
                  GpaCourseKind.repeat: 'Repeat · needs policy',
                  GpaCourseKind.withdrawn: 'Withdrawn · excluded',
                  GpaCourseKind.incomplete: 'Incomplete · excluded',
                  GpaCourseKind.transfer: 'Transfer · excluded',
                  GpaCourseKind.passFail: 'Pass/fail · excluded',
                },
                onChanged: enabled
                    ? (value) {
                        if (value != null) {
                          onChanged(course.copyWith(kind: value));
                        }
                      }
                    : null,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
