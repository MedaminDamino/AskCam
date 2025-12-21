import 'package:flutter/material.dart';
import 'package:askcam/core/utils/l10n.dart';
import 'package:askcam/core/ui/app_card.dart';
import 'package:askcam/core/ui/app_spacing.dart';
import 'package:askcam/core/ui/section_header.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(context.l10n.aboutApplication),
        iconTheme: IconThemeData(color: colors.onBackground),
      ),
      body: SafeArea(
        child: ListView(
          padding: AppSpacing.all(AppSpacing.xl),
          children: [
            Text(
              context.l10n.appTitle,
              style: textTheme.headlineSmall,
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              context.l10n.aboutDescription,
              style: textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            SizedBox(height: AppSpacing.xl),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionHeader(
                    title: context.l10n.aboutMlKitServicesTitle,
                  ),
                  ListTile(
                    contentPadding: AppSpacing.only(),
                    title: Text(context.l10n.aboutMlKitTextRecognition),
                  ),
                  ListTile(
                    contentPadding: AppSpacing.only(),
                    title: Text(context.l10n.aboutMlKitTranslation),
                  ),
                  SizedBox(height: AppSpacing.md),
                  SectionHeader(
                    title: context.l10n.aboutAiServiceTitle,
                  ),
                  ListTile(
                    contentPadding: AppSpacing.only(),
                    title: Text(context.l10n.aboutAiServiceGemini),
                  ),
                  SizedBox(height: AppSpacing.md),
                  SectionHeader(
                    title: context.l10n.aboutTargetUsersTitle,
                  ),
                  ListTile(
                    contentPadding: AppSpacing.only(),
                    title: Text(context.l10n.aboutTargetUsersStudents),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
