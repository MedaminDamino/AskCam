import 'package:askcam/core/utils/locale_controller.dart';
import 'package:askcam/core/services/button_feedback_service.dart';
import 'package:askcam/core/utils/l10n.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LanguageSelectorButton extends StatelessWidget {
  const LanguageSelectorButton({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return IconButton(
      icon: Icon(Icons.language, color: colors.onBackground),
      tooltip: context.l10n.language,
      onPressed: ButtonFeedbackService.wrap(
        context,
        () => _showLanguageSelector(context),
      ),
    );
  }

  void _showLanguageSelector(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final localeController = context.read<LocaleController>();
    final currentLocale = localeController.locale?.languageCode ?? 'en';

    showModalBottomSheet(
      context: context,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Text(
                    context.l10n.language,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                const Divider(),
                _LanguageOption(
                  label: 'English',
                  languageCode: 'en',
                  isSelected: currentLocale == 'en',
                  onTap: () {
                    localeController.changeLocale(const Locale('en'));
                    Navigator.pop(sheetContext);
                  },
                ),
                _LanguageOption(
                  label: 'Français',
                  languageCode: 'fr',
                  isSelected: currentLocale == 'fr',
                  onTap: () {
                    localeController.changeLocale(const Locale('fr'));
                    Navigator.pop(sheetContext);
                  },
                ),
                _LanguageOption(
                  label: 'العربية',
                  languageCode: 'ar',
                  isSelected: currentLocale == 'ar',
                  onTap: () {
                    localeController.changeLocale(const Locale('ar'));
                    Navigator.pop(sheetContext);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String label;
  final String languageCode;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.label,
    required this.languageCode,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ListTile(
      title: Text(
        label,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
      ),
      trailing: isSelected
          ? Icon(Icons.check, color: colors.primary)
          : null,
      onTap: ButtonFeedbackService.wrap(context, onTap),
    );
  }
}
