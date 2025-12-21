import 'package:flutter/material.dart';
import 'package:askcam/core/ui/app_radius.dart';
import 'package:askcam/core/ui/app_spacing.dart';

enum AppButtonVariant { primary, secondary, destructive }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final Widget? icon;
  final bool expanded;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.expanded = true,
  });

  factory AppButton.primary({
    required String label,
    required VoidCallback? onPressed,
    Widget? icon,
    bool expanded = true,
  }) {
    return AppButton(
      label: label,
      onPressed: onPressed,
      icon: icon,
      expanded: expanded,
    );
  }

  factory AppButton.secondary({
    required String label,
    required VoidCallback? onPressed,
    Widget? icon,
    bool expanded = true,
  }) {
    return AppButton(
      label: label,
      onPressed: onPressed,
      variant: AppButtonVariant.secondary,
      icon: icon,
      expanded: expanded,
    );
  }

  factory AppButton.destructive({
    required String label,
    required VoidCallback? onPressed,
    Widget? icon,
    bool expanded = true,
  }) {
    return AppButton(
      label: label,
      onPressed: onPressed,
      variant: AppButtonVariant.destructive,
      icon: icon,
      expanded: expanded,
    );
  }

  @override
  Widget build(BuildContext context) {
    final radius = AppRadius.circular(AppRadius.md);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final buttonChild = icon == null
        ? Text(label)
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              icon!,
              SizedBox(width: AppSpacing.sm),
              Text(label),
            ],
          );

    final contentPadding = AppSpacing.only(
      left: AppSpacing.lg,
      right: AppSpacing.lg,
      top: AppSpacing.md,
      bottom: AppSpacing.md,
    );

    final button = switch (variant) {
      AppButtonVariant.secondary => OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: radius),
            side: BorderSide(color: scheme.outlineVariant),
            padding: contentPadding,
          ),
          child: buttonChild,
        ),
      AppButtonVariant.destructive => ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: scheme.error,
            foregroundColor: scheme.onError,
            shape: RoundedRectangleBorder(borderRadius: radius),
            padding: contentPadding,
          ),
          child: buttonChild,
        ),
      AppButtonVariant.primary => ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: radius),
            padding: contentPadding,
          ),
          child: buttonChild,
        ),
    };

    if (!expanded) return button;
    return SizedBox(width: double.infinity, child: button);
  }
}
