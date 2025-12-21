import 'package:askcam/core/theme/theme_controller.dart';
import 'package:askcam/core/utils/image_cache_manager.dart';
import 'package:askcam/core/services/button_feedback_service.dart';
import 'package:askcam/core/services/reminder_notification_service.dart';
import 'package:askcam/features/presentation/auth/auth_controller.dart';
import 'package:askcam/features/presentation/settings/settings_controller.dart';
import 'package:askcam/features/presentation/screens/about_page.dart';
import 'package:askcam/features/presentation/widgets/theme_toggle_button.dart';
import 'package:askcam/routes/app_routes.dart';
import 'package:askcam/core/utils/locale_controller.dart';
import 'package:askcam/core/utils/l10n.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:askcam/core/ui/app_card.dart';
import 'package:askcam/core/ui/app_button.dart';
import 'package:askcam/core/ui/app_spacing.dart';
import 'package:askcam/core/ui/section_header.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final settings = context.watch<SettingsController>();
    final themeController = context.watch<ThemeController>();
    final localeController = context.watch<LocaleController>();
    final l10n = context.l10n;
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(l10n.settingsTitle),
        iconTheme: IconThemeData(color: colors.onBackground),
        actions: const [
          ThemeToggleButton(),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: AppSpacing.all(AppSpacing.xl),
          children: [
            SectionHeader(title: l10n.settingsSectionPreferences),
            AppCard(
              padding: AppSpacing.only(),
              child: Column(
                children: [
                  SwitchListTile(
                    value: themeController.mode == ThemeMode.dark,
                    onChanged: (value) => themeController.setThemeMode(
                      value ? ThemeMode.dark : ThemeMode.light,
                    ),
                    title: Text(
                      l10n.settingsDarkMode,
                    ),
                    subtitle: Text(
                      l10n.settingsTheme,
                    ),
                  ),
                  Divider(height: AppSpacing.sm),
                  ListTile(
                    title: Text(
                      l10n.language,
                    ),
                    trailing: _LanguageDropdown(
                      value: localeController.locale?.languageCode ??
                          settings.languageCode,
                      onChanged: (value) async {
                        if (value == null) return;
                        await localeController.changeLocale(Locale(value));
                        await settings.setLanguageCode(value);
                      },
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSpacing.xl),
            SectionHeader(title: l10n.settingsSectionFeedback),
            AppCard(
              padding: AppSpacing.only(),
              child: Column(
                children: [
                  SwitchListTile(
                    value: settings.silentMode,
                    onChanged: settings.setSilentMode,
                    title: Text(
                      l10n.settingsSilentMode,
                    ),
                    subtitle: Text(
                      l10n.settingsSilentModeHint,
                    ),
                  ),
                  Divider(height: AppSpacing.sm),
                  SwitchListTile(
                    value: settings.soundEnabled,
                    onChanged: settings.silentMode
                        ? null
                        : settings.setSoundEnabled,
                    title: Text(
                      l10n.settingsSoundEnabled,
                    ),
                  ),
                  Divider(height: AppSpacing.sm),
                  SwitchListTile(
                    value: settings.vibrationEnabled,
                    onChanged: settings.silentMode
                        ? null
                        : settings.setVibrationEnabled,
                    title: Text(
                      l10n.settingsVibrationEnabled,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSpacing.xl),
            SectionHeader(title: l10n.settingsSectionReminders),
            AppCard(
              padding: AppSpacing.only(),
              child: SwitchListTile(
                value: settings.reminderEnabled,
                onChanged: (value) async {
                  if (value) {
                    final granted = await ReminderNotificationService
                        .instance
                        .scheduleReminder(
                          title: l10n.reminderTitle,
                          body: l10n.reminderBody,
                          channelName: l10n.reminderChannelName,
                          channelDescription: l10n.reminderChannelDescription,
                        );
                    if (!granted) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.reminderPermissionDenied),
                          ),
                        );
                      }
                      return;
                    }
                    await settings.setReminderEnabled(true);
                    return;
                  }

                  await ReminderNotificationService.instance.cancelAll();
                  await settings.setReminderEnabled(false);
                },
                title: Text(
                  l10n.settingsReminderToggle,
                ),
                subtitle: Text(
                  l10n.settingsReminderHint,
                ),
              ),
            ),
            SizedBox(height: AppSpacing.xl),
            SectionHeader(title: l10n.settingsSectionAbout),
            AppCard(
              padding: AppSpacing.only(),
              child: ListTile(
                title: Text(
                  l10n.aboutApplication,
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: ButtonFeedbackService.wrap(
                  context,
                  () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const AboutPage(),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: AppSpacing.xl),
            SectionHeader(title: l10n.settingsSectionOcr),
            AppCard(
              padding: AppSpacing.only(),
              child: Column(
                children: [
                  SwitchListTile(
                    value: settings.autoEnhanceImages,
                    onChanged: settings.setAutoEnhanceImages,
                    title: Text(
                      l10n.settingsAutoEnhanceImages,
                    ),
                  ),
                  Divider(height: AppSpacing.sm),
                  SwitchListTile(
                    value: settings.autoDetectLanguage,
                    onChanged: settings.setAutoDetectLanguage,
                    title: Text(
                      l10n.settingsAutoDetectLanguage,
                    ),
                    subtitle: Text(
                      l10n.settingsAutoDetectLanguageHint,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSpacing.xl),
            SectionHeader(title: l10n.settingsSectionPrivacy),
            AppCard(
              padding: AppSpacing.only(),
              child: ListTile(
                title: Text(
                  l10n.settingsClearCache,
                ),
                trailing: AppButton.secondary(
                  label: l10n.settingsClearCache,
                  expanded: false,
                  onPressed: ButtonFeedbackService.wrap(
                    context,
                    () => _clearCache(context),
                  ),
                ),
              ),
            ),
            SizedBox(height: AppSpacing.xl),
            SectionHeader(title: l10n.settingsSectionAccount),
            AppCard(
              padding: AppSpacing.only(),
              child: Column(
                children: [
                  ListTile(
                    title: Text(
                      l10n.settingsLoggedInAs,
                    ),
                    subtitle: Text(
                      user?.email ?? l10n.placeholderDash,
                    ),
                  ),
                  Divider(height: AppSpacing.sm),
                  ListTile(
                    title: Text(
                      l10n.authLogout,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: colors.error,
                      ),
                    ),
                    trailing: Icon(Icons.logout, color: colors.error),
                    onTap: ButtonFeedbackService.wrap(
                      context,
                      () => _confirmLogout(context),
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

  Future<void> _clearCache(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    try {
      if (kIsWeb) {
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.settingsClearCacheWeb)),
        );
        return;
      }
      await ImageCacheManager().clearAllCache();
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.settingsClearCacheDone)),
      );
    } catch (_) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.settingsClearCacheFail)),
      );
    }
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final l10n = context.l10n;
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.authLogout),
          content: Text(l10n.authLogoutConfirmation),
          actions: [
            TextButton(
              onPressed: ButtonFeedbackService.wrap(
                dialogContext,
                () => Navigator.of(dialogContext).pop(false),
              ),
              child: Text(l10n.actionCancel),
            ),
            TextButton(
              onPressed: ButtonFeedbackService.wrap(
                dialogContext,
                () => Navigator.of(dialogContext).pop(true),
              ),
              child: Text(l10n.authLogout),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true) return;

    final controller = context.read<AuthController>();
    final success = await controller.signOut(l10n: l10n);
    if (!context.mounted) return;

    if (success) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        Routes.login,
        (route) => false,
      );
    } else {
      final message = controller.errorMessage ?? l10n.authLogoutFailed;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }
}

class _LanguageDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String?> onChanged;

  const _LanguageDropdown({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return DropdownButton<String>(
      value: value,
      underline: const SizedBox.shrink(),
      iconEnabledColor: colors.primary,
      onChanged: onChanged,
      items: SettingsController.supportedLanguageCodes
          .map(
            (code) => DropdownMenuItem<String>(
              value: code,
              child: Text(
                _languageLabel(context, code),
              ),
            ),
          )
          .toList(),
    );
  }

  String _languageLabel(BuildContext context, String code) {
    final l10n = context.l10n;
    switch (code) {
      case 'fr':
        return l10n.languageFrench;
      case 'ar':
        return l10n.languageArabic;
      default:
        return l10n.languageEnglish;
    }
  }
}
