import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class WorkspaceBadge extends StatelessWidget {
  const WorkspaceBadge(this.label, {super.key, required this.palette});
  final String label;
  final AppThemePalette palette;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: palette.badgeBg,
      border: Border.all(color: palette.borderSubtle),
    ),
    child: Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: AppTypography.monoShortcut(palette.textSecondary),
    ),
  );
}

class WorkspaceButton extends StatelessWidget {
  const WorkspaceButton(
    this.label, {
    super.key,
    required this.icon,
    required this.onPressed,
    this.primary = false,
  });
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool primary;
  @override
  Widget build(BuildContext context) {
    final style = ButtonStyle(
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
      ),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      ),
    );
    return primary
        ? FilledButton.icon(
            style: style,
            onPressed: onPressed,
            icon: Icon(icon, size: 17),
            label: Text(label),
          )
        : OutlinedButton.icon(
            style: style,
            onPressed: onPressed,
            icon: Icon(icon, size: 17),
            label: Text(label),
          );
  }
}

class WorkspaceEmpty extends StatelessWidget {
  const WorkspaceEmpty({
    super.key,
    required this.title,
    required this.message,
    required this.palette,
    this.action,
  });
  final String title;
  final String message;
  final AppThemePalette palette;
  final Widget? action;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(32),
    decoration: BoxDecoration(border: Border.all(color: palette.borderSubtle)),
    child: Column(
      children: [
        Icon(Icons.folder_open_outlined, size: 32, color: palette.textMuted),
        const SizedBox(height: 16),
        Text(title, style: AppTypography.headlineLg(palette.textPrimary)),
        const SizedBox(height: 8),
        Text(
          message,
          textAlign: TextAlign.center,
          style: AppTypography.bodyLg(palette.textSecondary),
        ),
        if (action != null)
          Padding(padding: const EdgeInsets.only(top: 20), child: action),
      ],
    ),
  );
}

String updatedLabel(DateTime date) {
  final elapsed = DateTime.now().difference(date);
  if (elapsed.inMinutes < 1) return 'Updated just now';
  if (elapsed.inHours < 1) return 'Updated ${elapsed.inMinutes}m ago';
  if (elapsed.inDays < 1) return 'Updated ${elapsed.inHours}h ago';
  if (elapsed.inDays == 1) return 'Updated yesterday';
  return 'Updated ${elapsed.inDays} days ago';
}
