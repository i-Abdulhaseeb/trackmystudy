import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class GpaPanel extends StatelessWidget {
  const GpaPanel({
    super.key,
    required this.palette,
    required this.title,
    required this.child,
    this.description,
  });

  final AppThemePalette palette;
  final String title;
  final String? description;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: palette.card,
      border: Border.all(color: palette.borderSubtle),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTypography.headlineMd(palette.textPrimary)),
        if (description != null) ...[
          const SizedBox(height: 5),
          Text(
            description!,
            style: AppTypography.bodySm(palette.textSecondary),
          ),
        ],
        const SizedBox(height: 16),
        child,
      ],
    ),
  );
}

class GpaField extends StatelessWidget {
  const GpaField({
    super.key,
    required this.palette,
    required this.label,
    required this.value,
    required this.onChanged,
    this.error,
    this.numeric = false,
    this.enabled = true,
  });

  final AppThemePalette palette;
  final String label;
  final String value;
  final ValueChanged<String> onChanged;
  final String? error;
  final bool numeric;
  final bool enabled;

  @override
  Widget build(BuildContext context) => TextFormField(
    initialValue: value,
    enabled: enabled,
    onChanged: onChanged,
    keyboardType: numeric
        ? const TextInputType.numberWithOptions(decimal: true)
        : TextInputType.text,
    style: AppTypography.bodyMd(palette.textPrimary),
    cursorColor: palette.textPrimary,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: AppTypography.bodySm(palette.textSecondary),
      errorText: error,
      errorMaxLines: 3,
      isDense: true,
      filled: true,
      fillColor: palette.cardElevated,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: palette.borderSubtle),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: palette.borderStrong),
      ),
    ),
  );
}

class GpaAction extends StatelessWidget {
  const GpaAction({
    super.key,
    required this.palette,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.primary = false,
  });

  final AppThemePalette palette;
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool primary;

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
    onPressed: onPressed,
    icon: Icon(icon, size: 15),
    label: Text(label),
    style: OutlinedButton.styleFrom(
      foregroundColor: primary ? palette.onPrimary : palette.textPrimary,
      backgroundColor: primary ? palette.primary : palette.cardElevated,
      disabledForegroundColor: palette.textMuted,
      side: BorderSide(color: palette.borderSubtle),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      textStyle: AppTypography.bodySm(palette.textPrimary),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    ),
  );
}

class GpaDropdown<T> extends StatelessWidget {
  const GpaDropdown({
    super.key,
    required this.palette,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final AppThemePalette palette;
  final String label;
  final T? value;
  final Map<T, String> items;
  final ValueChanged<T?>? onChanged;

  @override
  Widget build(BuildContext context) => InputDecorator(
    decoration: InputDecoration(
      labelText: label,
      labelStyle: AppTypography.bodySm(palette.textSecondary),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: palette.borderSubtle),
      ),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<T>(
        value: value,
        isExpanded: true,
        dropdownColor: palette.cardElevated,
        style: AppTypography.bodyMd(palette.textPrimary),
        hint: const Text('Select'),
        items: [
          for (final entry in items.entries)
            DropdownMenuItem(
              value: entry.key,
              child: Text(entry.value, overflow: TextOverflow.ellipsis),
            ),
        ],
        onChanged: onChanged,
      ),
    ),
  );
}
