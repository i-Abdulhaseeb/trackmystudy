import 'package:flutter/material.dart';
import '../theme/app_typography.dart';
import '../theme/app_colors.dart';

class MonoBadge extends StatelessWidget {
  final String text;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? textColor;
  final double fontSize;
  final FontWeight fontWeight;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final VoidCallback? onTap;

  const MonoBadge({
    super.key,
    required this.text,
    this.backgroundColor,
    this.borderColor,
    this.textColor,
    this.fontSize = 11,
    this.fontWeight = FontWeight.w400,
    this.padding = const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    this.borderRadius = 3,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.darkBadgeBg,
        borderRadius: BorderRadius.circular(borderRadius),
        border: borderColor != null ? Border.all(color: borderColor!, width: 1) : null,
      ),
      child: Text(
        text,
        style: AppTypography.monoCaption(
          textColor ?? AppColors.darkTextSecondary,
          fontWeight: fontWeight,
        ).copyWith(fontSize: fontSize),
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: content,
      );
    }
    return content;
  }
}
