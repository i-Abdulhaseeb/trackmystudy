import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../controllers/gpa_controller.dart';
import '../services/gpa_calculator.dart';
import 'gpa_components.dart';

class GpaBaselineCard extends StatelessWidget {
  const GpaBaselineCard({
    super.key,
    required this.controller,
    required this.palette,
  });

  final GpaController controller;
  final AppThemePalette palette;

  @override
  Widget build(BuildContext context) {
    final scenario = controller.active!;
    return GpaPanel(
      palette: palette,
      title: 'Academic baseline',
      description: 'Use credits included in your current CGPA, including failed attempts. Degree credits are tracked separately and never used as the GPA denominator. For your first semester, enter 0 prior credits.',
      child: Wrap(
        spacing: 14,
        runSpacing: 14,
        children: [
          SizedBox(
            width: 230,
            child: GpaField(
              key: ValueKey('${scenario.id}_${scenario.baselineRevision}_cgpa'),
              palette: palette,
              label: 'Current CGPA · 0.00–4.00',
              value: scenario.cgpa,
              numeric: true,
              enabled: controller.editable,
              error: GpaCalculator.cgpaError(scenario),
              onChanged: (value) => controller.updateScenario(
                controller.active!.copyWith(cgpa: value),
              ),
            ),
          ),
          SizedBox(
            width: 230,
            child: GpaField(
              key: ValueKey(
                '${scenario.id}_${scenario.baselineRevision}_credits',
              ),
              palette: palette,
              label: 'Prior GPA-bearing credits',
              value: scenario.priorCredits,
              numeric: true,
              enabled: controller.editable,
              error: GpaCalculator.creditsError(scenario.priorCredits),
              onChanged: (value) => controller.updateScenario(
                controller.active!.copyWith(priorCredits: value),
              ),
            ),
          ),
          SizedBox(
            width: 250,
            child: GpaField(
              key: ValueKey(
                '${scenario.id}_${scenario.baselineRevision}_degree',
              ),
              palette: palette,
              label: 'Accepted degree credits · optional',
              value: scenario.degreeCredits,
              numeric: true,
              enabled: controller.editable,
              error: scenario.degreeCredits.trim().isEmpty
                  ? null
                  : GpaCalculator.creditsError(scenario.degreeCredits),
              onChanged: (value) => controller.updateScenario(
                controller.active!.copyWith(degreeCredits: value),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
