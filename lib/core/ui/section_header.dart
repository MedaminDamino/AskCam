import 'package:flutter/material.dart';
import 'package:askcam/core/ui/app_spacing.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: AppSpacing.only(bottom: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: textTheme.titleMedium),
          if (subtitle != null)
            Padding(
              padding: AppSpacing.only(top: AppSpacing.xs),
              child: Text(
                subtitle!,
                style: textTheme.bodySmall,
              ),
            ),
        ],
      ),
    );
  }
}
