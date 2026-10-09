import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class ViewerButton extends StatelessWidget {
  const ViewerButton({
    super.key,
    required this.icon,
    required this.label,
    required this.palette,
    this.onPressed,
    this.active = false,
    this.text,
  });
  final IconData icon;
  final String label;
  final AppThemePalette palette;
  final VoidCallback? onPressed;
  final bool active;
  final String? text;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: label,
    child: TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: palette.textPrimary,
        disabledForegroundColor: palette.textMuted,
        backgroundColor: active ? palette.selected : Colors.transparent,
        minimumSize: const Size(34, 32),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 17),
          if (text != null) ...[
            const SizedBox(width: 7),
            Text(
              text!,
              style: AppTypography.bodySm(
                onPressed == null ? palette.textMuted : palette.textPrimary,
              ),
            ),
          ],
        ],
      ),
    ),
  );
}

class ViewerPanel extends StatelessWidget {
  const ViewerPanel({
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
      color: palette.sidebar,
      border: Border.all(color: palette.borderSubtle),
    ),
    child: child,
  );
}
