import 'package:askcam/core/theme/theme_controller.dart';
import 'package:askcam/core/utils/image_cache_manager.dart';
import 'package:askcam/core/services/button_feedback_service.dart';
import 'package:askcam/features/presentation/auth/auth_controller.dart';
import 'package:askcam/features/presentation/settings/settings_controller.dart';
import 'package:askcam/features/presentation/widgets/theme_toggle_button.dart';
import 'package:askcam/routes/app_routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  static const Map<String, Map<String, String>> _labels = {
    'en': {
      'title': 'Settings',
      'preferences': 'Preferences',
      'theme': 'Theme',
      'darkMode': 'Dark mode',
      'language': 'Language',
      'feedback': 'Sound & Haptics',
      'silentMode': 'Silent mode',
      'silentHint': 'Silent mode disables sound and vibration.',
      'soundEnabled': 'Button sounds',
      'vibrationEnabled': 'Vibration',
      'ocrSettings': 'OCR & ML',
      'autoEnhance': 'Auto-enhance images before OCR',
      'autoDetectLanguage': 'Auto-detect language',
      'autoDetectHint': 'When disabled, the app assumes the selected language.',
      'privacy': 'Privacy & Cache',
      'clearCache': 'Clear cache',
      'clearCacheWeb': 'Cache cleanup skipped on web.',
      'clearCacheDone': 'Cache cleared successfully.',
      'clearCacheFail': 'Unable to clear cache. Please try again.',
      'account': 'Account',
      'loggedInAs': 'Signed in as',
      'logout': 'Logout',
      'logoutTitle': 'Log out',
      'logoutMessage': 'Are you sure you want to log out?',
      'cancel': 'Cancel',
    },
    'fr': {
      'title': 'Parametres',
      'preferences': 'Preferences',
      'theme': 'Theme',
      'darkMode': 'Mode sombre',
      'language': 'Langue',
      'feedback': 'Son & vibration',
      'silentMode': 'Mode silencieux',
      'silentHint': 'Le mode silencieux desactive le son et la vibration.',
      'soundEnabled': 'Sons des boutons',
      'vibrationEnabled': 'Vibration',
      'ocrSettings': 'OCR & ML',
      'autoEnhance': 'Ameliorer les images avant OCR',
      'autoDetectLanguage': 'Detecter la langue automatiquement',
      'autoDetectHint': 'Si desactive, la langue choisie est utilisee.',
      'privacy': 'Confidentialite & Cache',
      'clearCache': 'Vider le cache',
      'clearCacheWeb': 'Nettoyage du cache ignore sur le web.',
      'clearCacheDone': 'Cache vide avec succes.',
      'clearCacheFail': 'Impossible de vider le cache.',
      'account': 'Compte',
      'loggedInAs': 'Connecte en tant que',
      'logout': 'Se deconnecter',
      'logoutTitle': 'Deconnexion',
      'logoutMessage': 'Voulez-vous vous deconnecter ?',
      'cancel': 'Annuler',
    },
  };

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final settings = context.watch<SettingsController>();
    final themeController = context.watch<ThemeController>();
    final languageCode = settings.languageCode;
    final labels = _labels[languageCode] ?? _labels['en']!;
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          labels['title']!,
          style: GoogleFonts.poppins(
            color: colors.onBackground,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: IconThemeData(color: colors.onBackground),
        actions: const [
          ThemeToggleButton(),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _SectionHeader(title: labels['preferences']!),
            _SettingsCard(
              child: Column(
                children: [
                  SwitchListTile(
                    value: themeController.mode == ThemeMode.dark,
                    onChanged: (value) => themeController.setThemeMode(
                      value ? ThemeMode.dark : ThemeMode.light,
                    ),
                    title: Text(
                      labels['darkMode']!,
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      labels['theme']!,
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: Text(
                      labels['language']!,
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                    trailing: _LanguageDropdown(
                      value: languageCode,
                      onChanged: (value) {
                        if (value != null) {
                          settings.setLanguageCode(value);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _SectionHeader(title: labels['feedback']!),
            _SettingsCard(
              child: Column(
                children: [
                  SwitchListTile(
                    value: settings.silentMode,
                    onChanged: settings.setSilentMode,
                    title: Text(
                      labels['silentMode']!,
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      labels['silentHint']!,
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    value: settings.soundEnabled,
                    onChanged: settings.silentMode
                        ? null
                        : settings.setSoundEnabled,
                    title: Text(
                      labels['soundEnabled']!,
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    value: settings.vibrationEnabled,
                    onChanged: settings.silentMode
                        ? null
                        : settings.setVibrationEnabled,
                    title: Text(
                      labels['vibrationEnabled']!,
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _SectionHeader(title: labels['ocrSettings']!),
            _SettingsCard(
              child: Column(
                children: [
                  SwitchListTile(
                    value: settings.autoEnhanceImages,
                    onChanged: settings.setAutoEnhanceImages,
                    title: Text(
                      labels['autoEnhance']!,
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    value: settings.autoDetectLanguage,
                    onChanged: settings.setAutoDetectLanguage,
                    title: Text(
                      labels['autoDetectLanguage']!,
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      labels['autoDetectHint']!,
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _SectionHeader(title: labels['privacy']!),
            _SettingsCard(
              child: ListTile(
                title: Text(
                  labels['clearCache']!,
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                trailing: OutlinedButton(
                  onPressed: ButtonFeedbackService.wrap(
                    context,
                    () => _clearCache(context, labels),
                  ),
                  child: Text(labels['clearCache']!),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _SectionHeader(title: labels['account']!),
            _SettingsCard(
              child: Column(
                children: [
                  ListTile(
                    title: Text(
                      labels['loggedInAs']!,
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      user?.email ?? '-',
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: Text(
                      labels['logout']!,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: colors.error,
                      ),
                    ),
                    trailing: Icon(Icons.logout, color: colors.error),
                    onTap: ButtonFeedbackService.wrap(
                      context,
                      () => _confirmLogout(context, labels),
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

  Future<void> _clearCache(
    BuildContext context,
    Map<String, String> labels,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      if (kIsWeb) {
        messenger.showSnackBar(
          SnackBar(content: Text(labels['clearCacheWeb']!)),
        );
        return;
      }
      await ImageCacheManager().clearAllCache();
      messenger.showSnackBar(
        SnackBar(content: Text(labels['clearCacheDone']!)),
      );
    } catch (_) {
      messenger.showSnackBar(
        SnackBar(content: Text(labels['clearCacheFail']!)),
      );
    }
  }

  Future<void> _confirmLogout(
    BuildContext context,
    Map<String, String> labels,
  ) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(labels['logoutTitle']!),
          content: Text(labels['logoutMessage']!),
          actions: [
            TextButton(
              onPressed: ButtonFeedbackService.wrap(
                dialogContext,
                () => Navigator.of(dialogContext).pop(false),
              ),
              child: Text(labels['cancel']!),
            ),
            TextButton(
              onPressed: ButtonFeedbackService.wrap(
                dialogContext,
                () => Navigator.of(dialogContext).pop(true),
              ),
              child: Text(labels['logout']!),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true) return;

    final controller = context.read<AuthController>();
    final success = await controller.signOut();
    if (!context.mounted) return;

    if (success) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        Routes.login,
        (route) => false,
      );
    } else {
      final message = controller.errorMessage ?? 'Logout failed.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: colors.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final Widget child;

  const _SettingsCard({required this.child});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      elevation: 8,
      shadowColor: colors.shadow.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: child,
      ),
    );
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
      items: SettingsController.supportedLanguages.entries
          .map(
            (entry) => DropdownMenuItem<String>(
              value: entry.key,
              child: Text(
                entry.value,
                style: GoogleFonts.poppins(fontSize: 13),
              ),
            ),
          )
          .toList(),
    );
  }
}
