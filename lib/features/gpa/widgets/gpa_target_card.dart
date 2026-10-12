import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../models/gpa_scenario.dart';
import '../services/gpa_calculator.dart';
import 'gpa_components.dart';

class GpaTargetCard extends StatefulWidget {
  const GpaTargetCard({
    super.key,
    required this.palette,
    required this.scenario,
    required this.enabled,
    required this.onChanged,
  });

  final AppThemePalette palette;
  final GpaScenario scenario;
  final bool enabled;
  final ValueChanged<String> onChanged;

  @override
  State<GpaTargetCard> createState() => _GpaTargetCardState();
}

class _GpaTargetCardState extends State<GpaTargetCard> {
  GpaTargetPlan? _plan;

  @override
  void didUpdateWidget(covariant GpaTargetCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scenario != widget.scenario) _plan = null;
  }

  @override
  Widget build(BuildContext context) {
    final palette = widget.palette;
    return GpaPanel(
      palette: palette,
      title: 'Target CGPA planner',
      description: 'Find the required semester GPA and a possible grade combination for the credits above. This does not change your predicted grades.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 230,
                child: GpaField(
                  key: ValueKey('${widget.scenario.id}_target'),
                  palette: palette,
                  label: 'Target CGPA · 0.00–4.00',
                  value: widget.scenario.target,
                  numeric: true,
                  enabled: widget.enabled,
                  onChanged: widget.onChanged,
                ),
              ),
              GpaAction(
                palette: palette,
                label: 'Plan grades',
                icon: Icons.calculate_outlined,
                onPressed: () => setState(
                  () => _plan = GpaCalculator.planTarget(widget.scenario),
                ),
              ),
            ],
          ),
          if (_plan case final GpaTargetPlan plan) ...[
            const SizedBox(height: 16),
            if (plan.requiredGpa != null)
              Text(
                'Required semester GPA: ${plan.requiredGpa!.toStringAsFixed(2)}',
                style: AppTypography.headlineMd(palette.textPrimary),
              ),
            const SizedBox(height: 6),
            Text(
              plan.message,
              style: AppTypography.bodySm(palette.textSecondary),
            ),
            if (plan.grades.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final course in widget.scenario.courses.where(
                    (course) => plan.grades.containsKey(course.id),
                  ))
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: palette.cardElevated,
                        border: Border.all(color: palette.borderSubtle),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${course.name.trim().isEmpty ? 'Course ${widget.scenario.courses.indexOf(course) + 1}' : course.name} · ${course.credits} CH → ${plan.grades[course.id]!.letter}',
                        style: AppTypography.bodySm(palette.textPrimary),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }
}
