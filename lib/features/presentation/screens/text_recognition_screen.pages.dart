import 'dart:io';

import 'package:askcam/core/utils/ai_service.dart';
import 'package:askcam/core/utils/ml_kit_manager.dart';
import 'package:askcam/core/utils/translation_service.dart';
import 'package:askcam/features/presentation/widgets/theme_toggle_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

/// Screen responsible for OCR + translation + AI assistance for a captured image.
class TextRecognitionScreen extends StatefulWidget {
  final File imageFile;

  const TextRecognitionScreen({
    super.key,
    required this.imageFile,
  });

  @override
  State<TextRecognitionScreen> createState() => _TextRecognitionScreenState();
}

class _TextRecognitionScreenState extends State<TextRecognitionScreen> {
  static const Map<String, String> _languageLabels = {
    'en': 'English (EN)',
    'fr': 'French (FR)',
  };

  late final TextRecognizer _textRecognizer;

  /// Selected target language for translation & AI answers.
  String _targetLang = 'en';
  String _originalText = '';
  String _translatedText = '';
  String _aiAnswer = '';

  bool _isOcrLoading = true;
  bool _isTranslating = false;
  bool _isAskingAi = false;
  String? _errorMessage;
  String? _translationError;

  @override
  void initState() {
    super.initState();
    _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    AiService.instance.setResponseLanguage(_targetLang);
    _runOcrAndTranslation();
  }

  @override
  void dispose() {
    _textRecognizer.close();
    super.dispose();
  }

  /// Runs the OCR pipeline and automatically translates the result to English.
  Future<void> _runOcrAndTranslation() async {
    setState(() {
      _isOcrLoading = true;
      _isTranslating = false;
      _errorMessage = null;
       _translationError = null;
      _originalText = '';
      _translatedText = '';
      _aiAnswer = '';
    });

    try {
      final recognizedText =
          await MLKitManager().queueOperation(() async => _textRecognizer
              .processImage(InputImage.fromFile(widget.imageFile)));

      final cleaned = _postProcess(recognizedText.text);
      if (!mounted) return;

      setState(() {
        _originalText = cleaned;
        _isOcrLoading = false;
      });

      if (cleaned.isEmpty) {
        if (!mounted) return;
        setState(() {
          _translatedText = '';
        });
        return;
      }

      await _translateCurrentText();
    } catch (error, stackTrace) {
      debugPrint('TextRecognitionScreen OCR/translation error: $error');
      debugPrint('$stackTrace');
      if (!mounted) return;
      setState(() {
        _errorMessage =
            'We could not read this photo. Please retake it in better lighting.';
        _isOcrLoading = false;
        _isTranslating = false;
        _translatedText = '';
      });
    }
  }

  /// Cleans up OCR text to remove awkward spacing.
  String _postProcess(String value) {
    final normalized = value
        .replaceAll(RegExp(r' +'), ' ')
        .replaceAll(' .', '.')
        .replaceAll(' ,', ',')
        .replaceAll(' :', ':')
        .replaceAll(' ;', ';')
        .replaceAll(' !', '!')
        .replaceAll(' ?', '?')
        .replaceAll('( ', '(')
        .replaceAll(' )', ')');

    final lines = normalized
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
    return lines.join('\n');
  }

  /// Translates [_originalText] into the selected [_targetLang].
  Future<void> _translateCurrentText() async {
    if (_originalText.trim().isEmpty) {
      setState(() {
        _translatedText = '';
        _isTranslating = false;
        _translationError = null;
      });
      return;
    }

    setState(() {
      _isTranslating = true;
      _translationError = null;
    });

    try {
      final translation = await TranslationService.instance
          .translateFromArabicTo(_originalText, targetLang: _targetLang);

      if (!mounted) return;
      setState(() {
        _translatedText = translation;
        _isTranslating = false;
      });
    } catch (error, stackTrace) {
      debugPrint('TextRecognitionScreen translation error: $error');
      debugPrint('$stackTrace');
      if (!mounted) return;
      setState(() {
        _translatedText = _originalText;
        _translationError =
            'Translation unavailable right now. Showing the detected text instead.';
        _isTranslating = false;
      });
    }
  }

  /// Handles language dropdown updates and re-runs translation when needed.
  void _onLanguageChanged(String? code) {
    if (code == null || code == _targetLang) return;
    setState(() {
      _targetLang = code;
    });
    AiService.instance.setResponseLanguage(code);
    _translateCurrentText();
  }

  String _languageLabelForCode(String code) =>
      _languageLabels[code] ?? code.toUpperCase();

  /// Sends the translated text to the AI assistant for contextual help.
  Future<void> _askAiAboutText() async {
    if (_translatedText.trim().isEmpty || _isAskingAi) return;

    setState(() {
      _isAskingAi = true;
      _aiAnswer = '';
    });

    try {
      final response = await AiService.instance.askQuestion(_translatedText);
      if (!mounted) return;

      setState(() {
        _aiAnswer = response.trim().isEmpty
            ? 'The AI could not come up with an answer. Please try again.'
            : response.trim();
      });
    } catch (error, stackTrace) {
      debugPrint('TextRecognitionScreen AI error: $error');
      debugPrint('$stackTrace');
      if (!mounted) return;
      setState(() {
        _aiAnswer =
            'We could not reach the AI service right now. Please try again later.';
      });
    } finally {
      if (!mounted) return;
      setState(() => _isAskingAi = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'AskCam',
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
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildImagePreview(),
              const SizedBox(height: 24),
              if (_errorMessage != null) _buildErrorBanner(),
              _buildTextSection(
                title: 'Original text',
                content: _originalText,
                isLoading: _isOcrLoading,
                hint: _errorMessage ??
                    'We are extracting text from the photo. Please hold tight.',
              ),
              const SizedBox(height: 18),
              _buildLanguageSelector(),
              const SizedBox(height: 12),
              _buildTextSection(
                title: 'Translated text (${_targetLang.toUpperCase()})',
                content: _translatedText,
                isLoading: _isTranslating,
                hint: _originalText.isEmpty
                    ? 'Translation will appear once OCR completes.'
                    : 'Translating to ${_languageLabelForCode(_targetLang)}...',
                errorText: _translationError,
              ),
              const SizedBox(height: 24),
              _buildAskAiButton(),
              const SizedBox(height: 16),
              _buildAiAnswerCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.cyanAccent.withOpacity(0.25),
            blurRadius: 18,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Image.file(
          widget.imageFile,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildErrorBanner() {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: colors.error.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.error.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_rounded, color: colors.error),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage!,
              style: GoogleFonts.poppins(
                color: colors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextSection({
    required String title,
    required String content,
    required bool isLoading,
    required String hint,
    String? errorText,
  }) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sectionGradient = isDark
        ? const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1F1F3B), Color(0xFF2A2A50)],
          )
        : LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [colors.surface, colors.surfaceVariant],
          );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: sectionGradient,
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 12),
              if (isLoading)
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colors.primary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (content.isNotEmpty)
            Container(
              constraints: const BoxConstraints(minHeight: 100, maxHeight: 260),
              decoration: BoxDecoration(
                color: colors.surfaceVariant.withOpacity(0.6),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(12),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: SelectableText(
                  content,
                  style: GoogleFonts.poppins(
                    color: colors.onSurface,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ),
            )
          else
            Text(
              hint,
              style: GoogleFonts.poppins(
                color: colors.onSurfaceVariant,
                fontSize: 13,
              ),
            ),
          if (errorText != null) ...[
            const SizedBox(height: 10),
            Text(
              errorText,
              style: GoogleFonts.poppins(
                color: colors.tertiary,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// UI dropdown letting users pick the target translation language.
  Widget _buildLanguageSelector() {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Translate into:',
          style: GoogleFonts.poppins(
            color: colors.onSurface,
            fontWeight: FontWeight.w600,
            fontSize: 14,
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
              value: _targetLang,
              dropdownColor: isDark ? const Color(0xFF1F1F3B) : colors.surface,
              iconEnabledColor: colors.primary,
              onChanged: _onLanguageChanged,
              items: _languageLabels.entries
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
        const SizedBox(height: 6),
        Text(
          'Changing this option re-translates the detected text automatically.',
          style: GoogleFonts.poppins(
            color: colors.onSurfaceVariant,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildAskAiButton() {
    final colors = Theme.of(context).colorScheme;
    return SizedBox(
      height: 54,
      child: ElevatedButton(
        onPressed: (_translatedText.trim().isEmpty || _isAskingAi || _isTranslating)
            ? null
            : _askAiAboutText,
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          disabledBackgroundColor: colors.surfaceVariant,
          foregroundColor: colors.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isAskingAi
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      color: colors.onPrimary,
                      strokeWidth: 2,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Asking AI...',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            : Text(
                'Ask AI about this',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildAiAnswerCard() {
    final colors = Theme.of(context).colorScheme;
    final hasAnswer = _aiAnswer.trim().isNotEmpty;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: colors.surface,
        border: Border.all(color: colors.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AI Answer',
            style: GoogleFonts.poppins(
              color: colors.onSurface,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          if (hasAnswer)
            SelectableText(
              _aiAnswer,
              style: GoogleFonts.poppins(
                color: colors.onSurface,
                fontSize: 14,
                height: 1.5,
              ),
            )
          else
            Text(
              _isAskingAi
                  ? 'Waiting for the AI assistant to respond...'
                  : 'Ask AI to see step-by-step explanations or hints here.',
              style: GoogleFonts.poppins(
                color: colors.onSurfaceVariant,
                fontSize: 13,
              ),
            ),
        ],
      ),
    );
  }
}
