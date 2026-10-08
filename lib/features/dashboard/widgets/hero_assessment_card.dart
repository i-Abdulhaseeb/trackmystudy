import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../core/widgets/mono_badge.dart';
import '../controllers/dashboard_controller.dart';

class HeroAssessmentCard extends StatelessWidget {
  const HeroAssessmentCard({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();
    final DashboardController dashboardController = Get.find<DashboardController>();

    return Obx(() {
      final palette = themeController.palette;
      final days = dashboardController.days.value.toString().padLeft(2, '0');
      final hours = dashboardController.hours.value.toString().padLeft(2, '0');
      final minutes = dashboardController.minutes.value.toString().padLeft(2, '0');
      final seconds = dashboardController.seconds.value.toString().padLeft(2, '0');

      return Container(
        decoration: BoxDecoration(
          color: palette.card,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: palette.borderSubtle, width: 1),
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        '[UPCOMING ASSESSMENT]',
                        style: AppTypography.monoCaption(
                          palette.textMuted,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '•',
                        style: AppTypography.monoCaption(palette.textMuted),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'STATUS: ',
                        style: AppTypography.monoCaption(
                          palette.textMuted,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      MonoBadge(
                        text: 'CONFIRMED',
                        backgroundColor: palette.cardElevated,
                        borderColor: palette.borderStrong,
                        textColor: palette.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Calculus',
                    style: AppTypography.headlineXl(palette.textPrimary).copyWith(
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 14,
                        color: palette.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Midterm Examination • 15 October 2026 • 9:00 AM • Room C-204',
                          style: AppTypography.bodySm(palette.textSecondary),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  InkWell(
                    onTap: dashboardController.noOp,
                    borderRadius: BorderRadius.circular(4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'View complete datesheet',
                          style: AppTypography.bodySm(palette.textPrimary).copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          Icons.arrow_forward,
                          size: 14,
                          color: palette.textPrimary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: palette.cardElevated,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: palette.borderSubtle, width: 1),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildTimerDigit(days, palette),
                      _buildTimerSeparator(palette),
                      _buildTimerDigit(hours, palette),
                      _buildTimerSeparator(palette),
                      _buildTimerDigit(minutes, palette),
                      _buildTimerSeparator(palette),
                      _buildTimerDigit(seconds, palette),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildTimerLabel('DAYS', palette),
                      _buildLabelSeparator(palette),
                      _buildTimerLabel('HOURS', palette),
                      _buildLabelSeparator(palette),
                      _buildTimerLabel('MIN', palette),
                      _buildLabelSeparator(palette),
                      _buildTimerLabel('SEC', palette),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildTimerDigit(String value, dynamic palette) {
    return SizedBox(
      width: 40,
      child: Center(
        child: Text(
          value,
          style: AppTypography.monoTimer(palette.textPrimary).copyWith(fontSize: 28),
        ),
      ),
    );
  }

  Widget _buildTimerSeparator(dynamic palette) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Text(
        ':',
        style: AppTypography.monoTimer(palette.textMuted).copyWith(fontSize: 28),
      ),
    );
  }

  Widget _buildTimerLabel(String label, dynamic palette) {
    return SizedBox(
      width: 40,
      child: Center(
        child: Text(
          label,
          style: AppTypography.monoCaption(
            palette.textMuted,
            fontWeight: FontWeight.w700,
          ).copyWith(fontSize: 9),
        ),
      ),
    );
  }

  Widget _buildLabelSeparator(dynamic palette) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Text(
        '|',
        style: AppTypography.monoCaption(palette.borderStrong).copyWith(fontSize: 9),
      ),
    );
  }
}
