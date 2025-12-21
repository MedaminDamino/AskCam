import 'package:flutter/material.dart';
import 'package:askcam/core/utils/l10n.dart';
import 'package:askcam/core/ui/app_card.dart';
import 'package:askcam/core/ui/app_spacing.dart';
import 'package:askcam/core/ui/section_header.dart';
import 'package:url_launcher/url_launcher.dart';

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
            // App Title
            Text(
              context.l10n.appTitle,
              style: textTheme.headlineSmall,
            ),
            SizedBox(height: AppSpacing.md),
            
            // App Description
            Text(
              context.l10n.aboutDescription,
              style: textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            SizedBox(height: AppSpacing.xl),
            
            // ML Kit Features Section
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionHeader(
                    title: context.l10n.aboutMlKitServicesTitle,
                  ),
                  SizedBox(height: AppSpacing.sm),
                  
                  // Text Recognition
                  _buildFeatureTile(
                    context,
                    icon: Icons.text_fields,
                    title: context.l10n.aboutMlKitTextRecognition,
                    description: context.l10n.aboutMlKitTextRecognitionDesc,
                    link: context.l10n.aboutMlKitTextRecognitionLink,
                    colors: colors,
                    textTheme: textTheme,
                  ),
                  SizedBox(height: AppSpacing.md),
                  
                  // Translation
                  _buildFeatureTile(
                    context,
                    icon: Icons.translate,
                    title: context.l10n.aboutMlKitTranslation,
                    description: context.l10n.aboutMlKitTranslationDesc,
                    link: context.l10n.aboutMlKitTranslationLink,
                    colors: colors,
                    textTheme: textTheme,
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSpacing.lg),
            
            // AI Service Section
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionHeader(
                    title: context.l10n.aboutAiServiceTitle,
                  ),
                  SizedBox(height: AppSpacing.sm),
                  
                  // Gemini
                  _buildFeatureTile(
                    context,
                    icon: Icons.auto_awesome,
                    title: context.l10n.aboutAiServiceGemini,
                    description: context.l10n.aboutAiServiceGeminiDesc,
                    link: context.l10n.aboutAiServiceGeminiLink,
                    colors: colors,
                    textTheme: textTheme,
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSpacing.lg),
            
            // Privacy & Security Section
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionHeader(
                    title: context.l10n.aboutPrivacyTitle,
                  ),
                  SizedBox(height: AppSpacing.sm),
                  Text(
                    context.l10n.aboutPrivacyDesc,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required String link,
    required ColorScheme colors,
    required TextTheme textTheme,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: colors.primary, size: 20),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                title,
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.onSurface,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.xs),
        Padding(
          padding: AppSpacing.only(left: 20 + AppSpacing.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                description,
                style: textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              SizedBox(height: AppSpacing.xs),
              InkWell(
                onTap: () => _launchUrl(link),
                child: Text(
                  context.l10n.aboutLearnMore,
                  style: textTheme.bodySmall?.copyWith(
                    color: colors.primary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _launchUrl(String urlString) async {
    final uri = Uri.parse(urlString);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
