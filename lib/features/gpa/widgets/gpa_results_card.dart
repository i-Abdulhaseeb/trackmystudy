import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../services/gpa_calculator.dart';

class GpaResultsCard extends StatelessWidget {
  const GpaResultsCard({
    super.key,
    required this.palette,
    required this.result,
  });

  final AppThemePalette palette;
  final GpaResult result;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth >= 760
              ? 4
              : constraints.maxWidth >= 380
              ? 2
              : 1;
          final width = (constraints.maxWidth - (columns - 1) * 12) / columns;
          final values = {
            'SEMESTER GPA': result.semesterGpa?.toStringAsFixed(2) ?? '—',
            'PREDICTED CGPA': result.predictedCgpa?.toStringAsFixed(2) ?? '—',
            'GPA CREDITS': result.credits.toString(),
            'QUALITY POINTS': result.semesterGpa == null
                ? '—'
                : result.qualityPoints.toStringAsFixed(2),
          };
          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final entry in values.entries)
                Container(
                  width: width,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: palette.card,
                    border: Border.all(color: palette.borderSubtle),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.key,
                        style: AppTypography.monoCaption(palette.textMuted),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        entry.value,
                        style: AppTypography.monoTimer(palette.textPrimary),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
      const SizedBox(height: 10),
      Text(
        result.credits == 0
            ? 'Add at least one GPA-bearing course to see a prediction.'
            : 'GPA is weighted by credit hours. Results display 2 decimals; calculations retain full precision. CGPA is an estimate when your starting CGPA is rounded.',
        style: AppTypography.bodySm(palette.textSecondary),
      ),
      if (result.errors.isNotEmpty) ...[
        const SizedBox(height: 10),
        for (final error in result.errors)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              error,
              style: AppTypography.bodySm(palette.textSecondary),
            ),
          ),
      ],
    ],
  );
}
