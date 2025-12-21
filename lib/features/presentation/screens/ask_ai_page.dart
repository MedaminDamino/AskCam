import 'package:askcam/core/models/ask_ai_args.dart';
import 'package:askcam/core/models/ai_result.dart';
import 'package:askcam/core/services/ai_service.dart';
import 'package:askcam/core/services/button_feedback_service.dart';
import 'package:askcam/core/utils/image_bytes_loader.dart';
import 'package:askcam/core/config/app_runtime_config.dart';
import 'package:askcam/features/presentation/settings/settings_controller.dart';
import 'package:askcam/features/presentation/widgets/theme_toggle_button.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:askcam/core/utils/l10n.dart';
import 'package:askcam/core/ui/app_button.dart';
import 'package:askcam/core/ui/app_card.dart';
import 'package:askcam/core/ui/app_radius.dart';
import 'package:askcam/core/ui/app_spacing.dart';
import 'package:askcam/core/ui/app_text_field.dart';
import 'package:askcam/core/ui/section_header.dart';
import 'package:askcam/core/ui/empty_state_widget.dart';

class AskAiPage extends StatefulWidget {
  final AskAiArgs args;

  const AskAiPage({super.key, required this.args});

  @override
  State<AskAiPage> createState() => _AskAiPageState();
}

class _AskAiPageState extends State<AskAiPage> {
  late final TextEditingController _questionController;
  bool _isAsking = false;
  String _answer = '';
  String _currentLang = '';
  Uint8List? _previewBytes;
  bool _isConfigMissing = false;

  @override
  void initState() {
    super.initState();
    _questionController = TextEditingController();
    _previewBytes = widget.args.imageBytes;
    if (_previewBytes == null &&
        widget.args.imagePath != null &&
        widget.args.imagePath!.trim().isNotEmpty) {
      _loadPreviewBytes();
    }
  }

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final settings = context.watch<SettingsController>();
    if (_currentLang != settings.languageCode) {
      _currentLang = settings.languageCode;
      AiService.instance.setResponseLanguage(_currentLang);
    }
  }

  Future<void> _askAi() async {
    if (_isAsking) return;
    if (!AppRuntimeConfig.isAiReady) {
      final args = AppRuntimeConfig.buildRunArgs(
        [AppRuntimeConfig.keyAiApiKey],
      );
      final message =
          context.l10n.aiNotConfigured(args);
      setState(() {
        _answer = message;
        _isConfigMissing = true;
      });
      _showSnackBar(message);
      return;
    }
    final question = _questionController.text.trim();
    final extractedText = widget.args.extractedText.trim();
    final hasText = extractedText.length >= 15;
    final imageBytes = await _resolveImageBytes();

    setState(() {
      _isAsking = true;
      _answer = '';
      _isConfigMissing = false;
    });

    try {
      AiResult result;
      if (hasText) {
        result = await AiService.instance.askText(
          extractedText: extractedText,
          question: question.isEmpty ? null : question,
        );
      } else {
        if (imageBytes == null || imageBytes.isEmpty) {
          _showSnackBar(context.l10n.aiNoImageAvailable);
          setState(() => _isAsking = false);
          return;
        }
        final defaultPrompt =
            'Analyze this image and answer what can be answered. '
            'If there is no meaningful question or text, explain that professionally.';
        result = await AiService.instance.askVision(
          imageBytes: imageBytes,
          question: question.isEmpty ? defaultPrompt : question,
        );
      }
      if (!mounted) return;
      if (!result.ok) {
        final isConfigError = _isConfigErrorMessage(result.message);
        final message = _localizeAiError(result.message);
        setState(() {
          _answer = message;
          _isConfigMissing = isConfigError;
        });
        _showSnackBar(message);
        return;
      }
      setState(() {
        final cleaned = result.message.trim();
        _answer = _isUnhelpfulAnswer(cleaned)
            ? context.l10n.aiUnclearImage
            : cleaned;
      });
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('AskAiPage error: $e');
        debugPrintStack(stackTrace: stackTrace);
      }
      if (!mounted) return;
      setState(() {
        _answer = context.l10n.aiServiceUnavailable;
      });
      _showSnackBar(context.l10n.aiServiceUnavailable);
    } finally {
      if (!mounted) return;
      setState(() => _isAsking = false);
    }
  }

  void _copyAnswer() {
    if (_answer.trim().isEmpty) return;
    Clipboard.setData(ClipboardData(text: _answer));
    _showSnackBar(context.l10n.aiAnswerCopied);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final hasImage = _previewBytes != null && _previewBytes!.isNotEmpty;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(context.l10n.aiAskTitle),
        iconTheme: IconThemeData(color: colors.onBackground),
        actions: [
          IconButton(
            tooltip: context.l10n.actionCopy,
            onPressed: ButtonFeedbackService.wrap(
              context,
              _answer.trim().isEmpty ? null : _copyAnswer,
            ),
            icon: Icon(Icons.copy_rounded, color: colors.onBackground),
          ),
          TextButton(
            onPressed: ButtonFeedbackService.wrap(
              context,
              () => Navigator.pop(context),
            ),
            child: Text(context.l10n.actionBack),
          ),
          const ThemeToggleButton(),
        ],
      ),
      body: SafeArea(
        child: hasImage
            ? SingleChildScrollView(
                padding: AppSpacing.all(AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildImagePreview(colors),
                    SizedBox(height: AppSpacing.xl),
                    SectionHeader(title: context.l10n.aiAskQuestionTitle),
                    AppTextField(
                      controller: _questionController,
                      minLines: 2,
                      maxLines: 4,
                      hintText: context.l10n.aiAskQuestionHint,
                    ),
                    SizedBox(height: AppSpacing.lg),
                    AppButton.primary(
                      label:
                          _isAsking ? context.l10n.aiAsking : context.l10n.aiAsk,
                      onPressed: ButtonFeedbackService.wrap(
                        context,
                        (_isAsking || _isConfigMissing) ? null : _askAi,
                      ),
                      icon: _isAsking
                          ? SizedBox(
                              width: AppSpacing.lg,
                              height: AppSpacing.lg,
                              child: CircularProgressIndicator(
                                strokeWidth: AppSpacing.xs,
                                color: colors.onPrimary,
                              ),
                            )
                          : const Icon(Icons.auto_awesome_rounded),
                    ),
                    SizedBox(height: AppSpacing.xl),
                    SectionHeader(title: context.l10n.aiAnswerTitle),
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Text(
                                context.l10n.aiResponseLabel,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge
                                    ?.copyWith(color: colors.primary),
                              ),
                              const Spacer(),
                              IconButton(
                                icon: const Icon(Icons.copy_rounded, size: 18),
                                onPressed: ButtonFeedbackService.wrap(
                                  context,
                                  _answer.trim().isEmpty ? null : _copyAnswer,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: AppSpacing.sm),
                          Text(
                            _answer.isEmpty
                                ? context.l10n.aiResponsePlaceholder
                                : _answer,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: AppSpacing.xl),
                    AppButton.secondary(
                      label: context.l10n.actionBackToExtract,
                      onPressed: ButtonFeedbackService.wrap(
                        context,
                        () => Navigator.pop(context),
                      ),
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                  ],
                ),
              )
            : EmptyStateWidget(
                icon: Icons.image_not_supported,
                title: context.l10n.aiNoImageProvided,
                message: context.l10n.aiEmptyHint,
                action: AppButton.secondary(
                  label: context.l10n.actionBackToExtract,
                  onPressed: ButtonFeedbackService.wrap(
                    context,
                    () => Navigator.pop(context),
                  ),
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
              ),
      ),
    );
  }

  Widget _buildImagePreview(ColorScheme colors) {
    final bytes = _previewBytes;
    if (bytes == null || bytes.isEmpty) {
      final path = widget.args.imagePath;
      if (path == null || path.trim().isEmpty || kIsWeb) {
        return const SizedBox.shrink();
      }
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: AppRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withOpacity(0.15),
            blurRadius: AppSpacing.xl,
            offset: Offset(0, AppSpacing.sm),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: AppRadius.circular(AppRadius.lg),
        child: Image.memory(
          bytes,
          fit: BoxFit.cover,
          width: double.infinity,
        ),
      ),
    );
  }

  bool _isUnhelpfulAnswer(String text) {
    final lower = text.toLowerCase();
    if (text.trim().isEmpty) return true;
    if (text.trim().length < 12) return true;
    if (lower.contains('cannot') || lower.contains("can't")) return true;
    if (lower.contains('no meaningful') || lower.contains('no clear')) {
      return true;
    }
    return false;
  }

  bool _isConfigErrorMessage(String message) {
    final lower = message.toLowerCase();
    return lower.contains('ai is not configured') ||
        lower.contains('ai base url is missing') ||
        lower.contains('ai model is missing') ||
        lower.contains('ai_api_key');
  }

  String _localizeAiError(String message) {
    final lower = message.toLowerCase();
    if (_isConfigErrorMessage(message)) {
      final args = AppRuntimeConfig.buildRunArgs(
        [AppRuntimeConfig.keyAiApiKey],
      );
      return context.l10n.aiNotConfigured(args);
    }
    if (lower.contains('did not return') || lower.contains('no answer')) {
      return context.l10n.aiNoAnswerFallback;
    }
    if (lower.contains('network error') ||
        lower.contains('request failed') ||
        lower.contains('response parsing')) {
      return context.l10n.aiServiceUnavailable;
    }
    return context.l10n.aiServiceUnavailable;
  }

  Future<Uint8List?> _resolveImageBytes() async {
    final bytes = _previewBytes ?? widget.args.imageBytes;
    if (bytes != null && bytes.isNotEmpty) return bytes;
    final path = widget.args.imagePath;
    if (path == null || path.trim().isEmpty || kIsWeb) return null;
    try {
      final loaded = await loadImageBytes(path);
      if (loaded != null && loaded.isNotEmpty && mounted) {
        setState(() {
          _previewBytes = loaded;
        });
      }
      return loaded;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('Failed to read image bytes from path: $e');
        debugPrintStack(stackTrace: stackTrace);
      }
      return null;
    }
  }

  Future<void> _loadPreviewBytes() async {
    final path = widget.args.imagePath;
    if (path == null || path.trim().isEmpty || kIsWeb) return;
    final bytes = await loadImageBytes(path);
    if (!mounted || bytes == null || bytes.isEmpty) return;
    setState(() {
      _previewBytes = bytes;
    });
  }
}
