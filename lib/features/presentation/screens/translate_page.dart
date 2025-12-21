import 'package:askcam/core/utils/translation_service.dart';
import 'package:askcam/features/presentation/screens/result_flow_args.dart';
import 'package:askcam/features/presentation/settings/settings_controller.dart';
import 'package:askcam/features/presentation/widgets/theme_toggle_button.dart';
import 'package:askcam/core/services/button_feedback_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

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
            'Translation unavailable right now. Showing the original text.';
        _isTranslating = false;
      });
      _showSnackBar('Unable to translate. Please try again.');
    }
  }

  void _copyTranslation() {
    if (_translatedText.trim().isEmpty) return;
    Clipboard.setData(ClipboardData(text: _translatedText));
    _showSnackBar('Translated text copied to clipboard.');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final settings = context.watch<SettingsController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Translate',
          style: GoogleFonts.poppins(
            color: colors.onBackground,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: IconThemeData(color: colors.onBackground),
        actions: [
          IconButton(
            tooltip: 'Copy',
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
            child: const Text('Back'),
          ),
          const ThemeToggleButton(),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Language',
                style: GoogleFonts.poppins(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: isDark ? const Color(0xFF1F1F3B) : colors.surface,
                  border: Border.all(color: colors.outlineVariant),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: settings.languageCode,
                    dropdownColor:
                        isDark ? const Color(0xFF1F1F3B) : colors.surface,
                    iconEnabledColor: colors.primary,
                    onChanged: (value) {
                      if (value != null) {
                        settings.setLanguageCode(value);
                      }
                    },
                    items: SettingsController.supportedLanguages.entries
                        .map(
                          (entry) => DropdownMenuItem<String>(
                            value: entry.key,
                            child: Text(
                              entry.value,
                              style: GoogleFonts.poppins(
                                color: colors.onSurface,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Text to translate',
                style: GoogleFonts.poppins(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _textController,
                minLines: 5,
                maxLines: null,
                style: GoogleFonts.poppins(
                  color: colors.onSurface,
                  fontSize: 14,
                  height: 1.5,
                ),
                decoration: InputDecoration(
                  hintText: 'Edit the text to translate...',
                  hintStyle: GoogleFonts.poppins(
                    color: colors.onSurfaceVariant,
                    fontSize: 13,
                  ),
                  filled: true,
                  fillColor: colors.surfaceVariant.withOpacity(0.5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: ButtonFeedbackService.wrap(
                    context,
                    _isTranslating ? null : _translate,
                  ),
                  icon: _isTranslating
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colors.onPrimary,
                          ),
                        )
                      : const Icon(Icons.translate_rounded),
                  label: Text(
                    _isTranslating ? 'Translating...' : 'Translate',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: colors.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Translated output',
                style: GoogleFonts.poppins(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: colors.surface,
                  border: Border.all(color: colors.outlineVariant),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Text(
                          settings.languageCode.toUpperCase(),
                          style: GoogleFonts.poppins(
                            color: colors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.copy_rounded, size: 18),
                          onPressed: ButtonFeedbackService.wrap(
                            context,
                            _translatedText.trim().isEmpty
                                ? null
                                : _copyTranslation,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SelectableText(
                      _translatedText.isEmpty
                          ? 'Translation will appear here.'
                          : _translatedText,
                      style: GoogleFonts.poppins(
                        color: colors.onSurface,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        _errorMessage!,
                        style: GoogleFonts.poppins(
                          color: colors.tertiary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: ButtonFeedbackService.wrap(
                    context,
                    () => Navigator.pop(context),
                  ),
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: const Text('Back to Extract'),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
