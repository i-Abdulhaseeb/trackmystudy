import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class ExamPanel extends StatelessWidget {
  const ExamPanel({
    super.key,
    required this.palette,
    required this.child,
    this.padding = EdgeInsets.zero,
  });
  final AppThemePalette palette;
  final Widget child;
  final EdgeInsetsGeometry padding;
  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: palette.card,
      border: Border.all(color: palette.borderStrong),
    ),
    child: child,
  );
}

class ExamAction extends StatelessWidget {
  const ExamAction({
    super.key,
    required this.palette,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.primary = false,
    this.loading = false,
  });
  final AppThemePalette palette;
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool primary;
  final bool loading;
  @override
  Widget build(BuildContext context) {
    final color = primary ? palette.onPrimary : palette.textPrimary;
    return TextButton.icon(
      onPressed: loading ? null : onPressed,
      style: TextButton.styleFrom(
        foregroundColor: color,
        disabledForegroundColor: color.withValues(alpha: .5),
        backgroundColor: primary ? palette.primary : palette.cardElevated,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        shape: const RoundedRectangleBorder(),
        side: BorderSide(color: palette.borderStrong),
      ),
      icon: loading
          ? SizedBox(
              width: 15,
              height: 15,
              child: CircularProgressIndicator(strokeWidth: 2, color: color),
            )
          : Icon(icon, size: 16),
      label: Text(
        label,
        style: AppTypography.bodyMd(color)
            .copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}

class ExamBadge extends StatelessWidget {
  const ExamBadge({super.key, required this.palette, required this.text});
  final AppThemePalette palette;
  final String text;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(
      color: palette.background,
      border: Border.all(color: palette.borderSubtle),
    ),
    child: Text(text, style: AppTypography.monoCaption(palette.textSecondary)),
  );
}
