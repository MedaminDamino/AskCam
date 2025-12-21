import 'dart:io';

import 'package:askcam/core/utils/ai_service.dart';
import 'package:askcam/core/utils/ml_kit_manager.dart';
import 'package:askcam/core/utils/translation_service.dart';
import 'package:askcam/features/presentation/settings/settings_controller.dart';
import 'package:askcam/features/presentation/widgets/theme_toggle_button.dart';
import 'package:askcam/core/services/button_feedback_service.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:provider/provider.dart';
import 'package:askcam/core/utils/l10n.dart';
import 'package:askcam/core/ui/app_button.dart';
import 'package:askcam/core/ui/app_card.dart';
import 'package:askcam/core/ui/app_radius.dart';
import 'package:askcam/core/ui/app_spacing.dart';
import 'package:askcam/core/ui/section_header.dart';

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
  late final TextRecognizer _textRecognizer;

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
    final settings = context.read<SettingsController>();
    _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    _targetLang = settings.languageCode;
    AiService.instance.setResponseLanguage(_targetLang);
    _runOcrAndTranslation();
  }

  @override
  void dispose() {
    _textRecognizer.close();
    super.dispose();
  }

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
        _errorMessage = context.l10n.ocrErrorUnableToRead;
        _isOcrLoading = false;
        _isTranslating = false;
        _translatedText = '';
      });
    }
  }

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
      final settings = context.read<SettingsController>();
      final sourceLang =
          settings.autoDetectLanguage ? 'auto' : settings.languageCode;
      final translation = await TranslationService.instance
          .translateFromArabicTo(
        _originalText,
        targetLang: _targetLang,
        sourceLang: sourceLang,
      );

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
        _translationError = context.l10n.translationUnavailableFallback;
        _isTranslating = false;
      });
    }
  }

  void _onLanguageChanged(String? code) {
    if (code == null || code == _targetLang) return;
    setState(() {
      _targetLang = code;
    });
    AiService.instance.setResponseLanguage(code);
    _translateCurrentText();
  }

  String _languageLabelForCode(BuildContext context, String code) {
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

  Future<void> _askAiAboutText() async {
    if (_translatedText.trim().isEmpty || _isAskingAi) return;

    setState(() {
      _isAskingAi = true;
      _aiAnswer = '';
    });

    try {
      final result = await AiService.instance.askQuestion(_translatedText);
      if (!mounted) return;

      setState(() {
        if (!result.ok) {
          _aiAnswer = result.message;
          return;
        }
        final cleaned = result.message.trim();
        _aiAnswer =
            cleaned.isEmpty ? context.l10n.aiNoAnswerFallback : cleaned;
      });
    } catch (error, stackTrace) {
      debugPrint('TextRecognitionScreen AI error: $error');
      debugPrint('$stackTrace');
      if (!mounted) return;
      setState(() {
        _aiAnswer = context.l10n.aiServiceUnavailable;
      });
    } finally {
      if (!mounted) return;
      setState(() => _isAskingAi = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(context.l10n.appTitle),
        actions: const [
          ThemeToggleButton(),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: AppSpacing.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildImagePreview(),
              SizedBox(height: AppSpacing.xl),
              if (_errorMessage != null) _buildErrorBanner(),
              _buildTextSection(
                title: context.l10n.ocrOriginalText,
                content: _originalText,
                isLoading: _isOcrLoading,
                hint: _errorMessage ?? context.l10n.ocrExtractingHint,
              ),
              SizedBox(height: AppSpacing.lg),
              _buildLanguageSelector(),
              SizedBox(height: AppSpacing.md),
              _buildTextSection(
                title: context.l10n.ocrTranslatedTextTitle(
                  _targetLang.toUpperCase(),
                ),
                content: _translatedText,
                isLoading: _isTranslating,
                hint: _originalText.isEmpty
                    ? context.l10n.translationWaitingForOcr
                    : context.l10n.translationInProgress(
                        _languageLabelForCode(context, _targetLang),
                      ),
                errorText: _translationError,
              ),
              SizedBox(height: AppSpacing.xl),
              _buildAskAiButton(),
              SizedBox(height: AppSpacing.lg),
              _buildAiAnswerCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    final colors = Theme.of(context).colorScheme;
    final radius = AppRadius.circular(AppRadius.lg);
    return Container(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: colors.primary.withOpacity(0.2),
            blurRadius: AppSpacing.xl,
            spreadRadius: AppSpacing.xs,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
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
    return Padding(
      padding: AppSpacing.only(bottom: AppSpacing.md),
      child: AppCard(
        child: Row(
          children: [
            Icon(Icons.warning_rounded, color: colors.error),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                _errorMessage!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colors.error,
                    ),
              ),
            ),
          ],
        ),
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
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: textTheme.titleMedium,
                ),
              ),
              if (isLoading)
                SizedBox(
                  width: AppSpacing.lg,
                  height: AppSpacing.lg,
                  child: CircularProgressIndicator(
                    strokeWidth: AppSpacing.xs,
                    color: colors.primary,
                  ),
                ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: content.isNotEmpty
                ? Container(
                    key: const ValueKey('content'),
                    constraints: const BoxConstraints(
                      minHeight: 120,
                      maxHeight: 280,
                    ),
                    decoration: BoxDecoration(
                      color: colors.surfaceVariant,
                      borderRadius: AppRadius.circular(AppRadius.md),
                    ),
                    padding: AppSpacing.all(AppSpacing.md),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: SelectableText(
                        content,
                        style: textTheme.bodyMedium,
                      ),
                    ),
                  )
                : Text(
                    hint,
                    key: const ValueKey('hint'),
                    style: textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
          ),
          if (errorText != null) ...[
            SizedBox(height: AppSpacing.sm),
            Text(
              errorText,
              style: textTheme.bodySmall?.copyWith(
                color: colors.tertiary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLanguageSelector() {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: l10n.translateInto),
        AppCard(
          padding: AppSpacing.only(
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            top: AppSpacing.sm,
            bottom: AppSpacing.sm,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _targetLang,
              iconEnabledColor: Theme.of(context).colorScheme.primary,
              onChanged: _onLanguageChanged,
              items: SettingsController.supportedLanguageCodes
                  .map(
                    (code) => DropdownMenuItem<String>(
                      value: code,
                      child: Text(_languageLabelForCode(context, code)),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
        SizedBox(height: AppSpacing.xs),
        Text(
          l10n.translationAutoReapplyHint,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }

  Widget _buildAskAiButton() {
    final l10n = context.l10n;
    return AppButton.primary(
      label: _isAskingAi ? l10n.aiAsking : l10n.aiAskAboutThis,
      onPressed: ButtonFeedbackService.wrap(
        context,
        (_translatedText.trim().isEmpty || _isAskingAi || _isTranslating)
            ? null
            : _askAiAboutText,
      ),
      icon: _isAskingAi
          ? SizedBox(
              width: AppSpacing.lg,
              height: AppSpacing.lg,
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.onPrimary,
                strokeWidth: AppSpacing.xs,
              ),
            )
          : const Icon(Icons.auto_awesome_rounded),
    );
  }

  Widget _buildAiAnswerCard() {
    final colors = Theme.of(context).colorScheme;
    final hasAnswer = _aiAnswer.trim().isNotEmpty;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.aiAnswerTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: AppSpacing.md),
          if (hasAnswer)
            SelectableText(
              _aiAnswer,
              style: Theme.of(context).textTheme.bodyMedium,
            )
          else
            Text(
              _isAskingAi
                  ? context.l10n.aiWaitingResponse
                  : context.l10n.aiEmptyHint,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
            ),
        ],
      ),
    );
  }
}
