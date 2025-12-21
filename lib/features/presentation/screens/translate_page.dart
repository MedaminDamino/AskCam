import 'package:askcam/core/utils/translation_service.dart';
import 'package:askcam/features/presentation/screens/result_flow_args.dart';
import 'package:askcam/features/presentation/settings/settings_controller.dart';
import 'package:askcam/features/presentation/widgets/theme_toggle_button.dart';
import 'package:askcam/core/services/button_feedback_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:askcam/core/utils/l10n.dart';
import 'package:askcam/core/ui/app_button.dart';
import 'package:askcam/core/ui/app_card.dart';
import 'package:askcam/core/ui/app_spacing.dart';
import 'package:askcam/core/ui/app_text_field.dart';
import 'package:askcam/core/ui/section_header.dart';

class TranslatePage extends StatefulWidget {
  final TranslatePageArgs args;

  const TranslatePage({super.key, required this.args});

  @override
  State<TranslatePage> createState() => _TranslatePageState();
}

class _TranslatePageState extends State<TranslatePage> {
  late final TextEditingController _textController;
  bool _isTranslating = false;
  String _translatedText = '';
  String? _errorMessage;
  String _currentLang = '';
  bool _didInit = false;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.args.text);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final settings = context.watch<SettingsController>();
    if (!_didInit) {
      _didInit = true;
      _currentLang = settings.languageCode;
      _translate();
      return;
    }
    if (_currentLang != settings.languageCode) {
      _currentLang = settings.languageCode;
      _translate();
    }
  }

  Future<void> _translate() async {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      setState(() {
        _translatedText = '';
        _errorMessage = null;
      });
      return;
    }

    setState(() {
      _isTranslating = true;
      _errorMessage = null;
    });

    try {
      final settings = context.read<SettingsController>();
      final sourceLang =
          settings.autoDetectLanguage ? 'auto' : settings.languageCode;
      final translation = await TranslationService.instance.translate(
        text,
        targetLang: settings.languageCode,
        sourceLang: sourceLang,
      );

      if (!mounted) return;
      setState(() {
        _translatedText = translation;
        _isTranslating = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _translatedText = text;
        _errorMessage =
            context.l10n.translationUnavailableOriginal;
        _isTranslating = false;
      });
      _showSnackBar(context.l10n.translationFailedTryAgain);
    }
  }

  void _copyTranslation() {
    if (_translatedText.trim().isEmpty) return;
    Clipboard.setData(ClipboardData(text: _translatedText));
    _showSnackBar(context.l10n.translationCopied);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
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

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final settings = context.watch<SettingsController>();
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(l10n.translateTitle),
        iconTheme: IconThemeData(color: colors.onBackground),
        actions: [
          IconButton(
            tooltip: l10n.actionCopy,
            onPressed: ButtonFeedbackService.wrap(
              context,
              _translatedText.trim().isEmpty ? null : _copyTranslation,
            ),
            icon: Icon(Icons.copy_rounded, color: colors.onBackground),
          ),
          TextButton(
            onPressed: ButtonFeedbackService.wrap(
              context,
              () => Navigator.pop(context),
            ),
            child: Text(l10n.actionBack),
          ),
          const ThemeToggleButton(),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SectionHeader(title: l10n.language),
              AppCard(
                padding: AppSpacing.only(
                  left: AppSpacing.lg,
                  right: AppSpacing.lg,
                  top: AppSpacing.sm,
                  bottom: AppSpacing.sm,
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: settings.languageCode,
                    dropdownColor: colors.surface,
                    iconEnabledColor: colors.primary,
                    onChanged: (value) {
                      if (value != null) {
                        settings.setLanguageCode(value);
                      }
                    },
                    items: SettingsController.supportedLanguageCodes
                        .map(
                          (code) => DropdownMenuItem<String>(
                            value: code,
                            child: Text(_languageLabel(context, code)),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.xl),
              SectionHeader(title: l10n.translateInputTitle),
              AppTextField(
                controller: _textController,
                minLines: 5,
                maxLines: null,
                hintText: l10n.translateInputHint,
              ),
              SizedBox(height: AppSpacing.md),
              AppButton.primary(
                label: _isTranslating
                    ? l10n.translationInProgressShort
                    : l10n.translateAction,
                onPressed: ButtonFeedbackService.wrap(
                  context,
                  _isTranslating ? null : _translate,
                ),
                icon: _isTranslating
                    ? SizedBox(
                        width: AppSpacing.lg,
                        height: AppSpacing.lg,
                        child: CircularProgressIndicator(
                          strokeWidth: AppSpacing.xs,
                          color: colors.onPrimary,
                        ),
                      )
                    : const Icon(Icons.translate_rounded),
              ),
              SizedBox(height: AppSpacing.xl),
              SectionHeader(title: l10n.translateOutputTitle),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Text(
                          settings.languageCode.toUpperCase(),
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: colors.primary,
                              ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.copy_rounded),
                          onPressed: ButtonFeedbackService.wrap(
                            context,
                            _translatedText.trim().isEmpty
                                ? null
                                : _copyTranslation,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSpacing.sm),
                    SelectableText(
                      _translatedText.isEmpty
                          ? l10n.translationOutputPlaceholder
                          : _translatedText,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    if (_errorMessage != null) ...[
                      SizedBox(height: AppSpacing.sm),
                      Text(
                        _errorMessage!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colors.tertiary,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(height: AppSpacing.xl),
              AppButton.secondary(
                label: l10n.actionBackToExtract,
                onPressed: ButtonFeedbackService.wrap(
                  context,
                  () => Navigator.pop(context),
                ),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
