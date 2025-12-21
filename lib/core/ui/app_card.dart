import 'package:flutter/material.dart';
import 'package:askcam/core/ui/app_radius.dart';
import 'package:askcam/core/ui/app_spacing.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final radius = AppRadius.circular(AppRadius.lg);
    final content = Padding(
      padding: padding ?? AppSpacing.all(AppSpacing.lg),
      child: child,
    );
    return Card(
      shape: RoundedRectangleBorder(borderRadius: radius),
      child: onTap == null
          ? content
          : InkWell(
              onTap: onTap,
              borderRadius: radius,
              child: content,
            ),
    );
  }
}
