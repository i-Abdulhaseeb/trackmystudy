import 'package:flutter/material.dart';
import '../theme/app_typography.dart';
import '../theme/app_colors.dart';

class ShortcutBadge extends StatelessWidget {
  final String shortcut;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? textColor;

  const ShortcutBadge({
    super.key,
    required this.shortcut,
    this.backgroundColor,
    this.borderColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.transparent,
        borderRadius: BorderRadius.circular(3),
        border: Border.all(
          color: borderColor ?? AppColors.darkBorderStrong,
          width: 1,
        ),
      ),
      child: Text(
        shortcut,
        style: AppTypography.monoShortcut(
          textColor ?? AppColors.darkTextMuted,
        ),
      ),
    );
  }
}
