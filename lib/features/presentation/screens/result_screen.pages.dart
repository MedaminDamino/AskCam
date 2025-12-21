import 'dart:async';

import 'package:askcam/core/config/app_runtime_config.dart';
import 'package:askcam/core/services/image_upload_service.dart';
import 'package:askcam/core/services/history_service.dart';
import 'package:askcam/core/services/saved_words_service.dart';
import 'package:askcam/core/services/button_feedback_service.dart';
import 'package:askcam/features/gallery/data/gallery_repository.dart';
import 'package:askcam/features/presentation/settings/settings_controller.dart';
import 'package:askcam/core/utils/ml_kit_manager.dart';
import 'package:askcam/core/models/ask_ai_args.dart';
import 'package:askcam/features/presentation/screens/result_flow_args.dart';
import 'package:askcam/features/presentation/widgets/theme_toggle_button.dart';
import 'package:askcam/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:provider/provider.dart';
import 'package:askcam/core/utils/l10n.dart';
import 'package:askcam/core/ui/app_button.dart';
import 'package:askcam/core/ui/app_card.dart';
import 'package:askcam/core/ui/app_radius.dart';
import 'package:askcam/core/ui/app_spacing.dart';
import 'package:askcam/core/ui/app_text_field.dart';
import 'package:askcam/core/ui/section_header.dart';

class ExtractResultPage extends StatefulWidget {
  final ExtractResultArgs args;

  const ExtractResultPage({super.key, required this.args});

  @override
  State<ExtractResultPage> createState() => _ExtractResultPageState();
}

class _ExtractResultPageState extends State<ExtractResultPage> {
  late final TextRecognizer _textRecognizer;
  late final TextEditingController _textController;

  bool _isOcrLoading = true;
  bool _isUploadingImage = false;
  bool _isSavingHistory = false;
  bool _isOnline = true;
  String? _errorMessage;
  String? _uploadError;
  String? _uploadedImageId;
  String? _uploadedImageUrl;
  String _pendingExtractedText = '';

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    _runOcr();
    _uploadImageIfNeeded();
  }

  @override
  void dispose() {
    _textRecognizer.close();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _runOcr() async {
    setState(() {
      _isOcrLoading = true;
      _errorMessage = null;
    });

    try {
      final recognizedText =
          await MLKitManager().queueOperation(() async => _textRecognizer
              .processImage(InputImage.fromFile(widget.args.imageFile)));

      final cleaned = _postProcess(recognizedText.text);
      if (!mounted) return;

      setState(() {
        _textController.text = cleaned;
        _isOcrLoading = false;
        _pendingExtractedText = cleaned;
      });
      _tryUpdateImageText();
    } catch (error, stackTrace) {
      debugPrint('ExtractResultPage OCR error: $error');
      debugPrint('$stackTrace');
      if (!mounted) return;
      setState(() {
        _errorMessage = context.l10n.ocrErrorUnableToRead;
        _isOcrLoading = false;
      });
      _showSnackBar(context.l10n.ocrUnableToExtract);
    }
  }

  Future<void> _uploadImageIfNeeded() async {
    if (_isUploadingImage || _uploadedImageUrl != null) return;
    if (!await _ensureOnline()) return;

    if (FirebaseAuth.instance.currentUser == null) {
      _showSnackBar(context.l10n.authLoginRequiredToSaveImages);
      return;
    }

    setState(() {
      _isUploadingImage = true;
      _uploadError = null;
    });

    try {
      final bytes = await widget.args.imageFile.readAsBytes();
      final fileName = _extractFileName(widget.args.imageFile.path);
      final url = await ImageUploadService.instance.uploadImage(
        bytes,
        fileName: fileName,
      );
      final docId = await GalleryRepository.instance.addImage(
        url: url,
        fileName: fileName,
        size: bytes.length,
        source: widget.args.source,
      );
      if (!mounted) return;
      setState(() {
        _uploadedImageUrl = url;
        _uploadedImageId = docId;
        _isUploadingImage = false;
        _uploadError = null;
      });
      _tryUpdateImageText();
    } catch (e, stackTrace) {
      debugPrint('Upload image failed: $e');
      debugPrintStack(stackTrace: stackTrace);
      if (!mounted) return;
      setState(() {
        _isUploadingImage = false;
        if (_isConfigError(e)) {
          final args = AppRuntimeConfig.buildRunArgs([
            AppRuntimeConfig.keyCloudName,
            AppRuntimeConfig.keyCloudPreset,
          ]);
          _uploadError = context.l10n.cloudinaryNotConfigured(args);
        } else if (_isOfflineError(e)) {
          _uploadError = context.l10n.errorNoInternetConnection;
          _isOnline = false;
        } else {
          _uploadError = context.l10n.uploadFailedTryAgain;
        }
      });
      _showSnackBar(_uploadError!);
    }
  }

  Future<void> _tryUpdateImageText() async {
    final text = _pendingExtractedText.trim();
    if (text.isEmpty) return;
    final imageId = _uploadedImageId;
    if (imageId == null) return;
    try {
      await GalleryRepository.instance.updateImageText(
        docId: imageId,
        extractedText: text,
      );
    } catch (_) {}
  }

  Future<bool> _ensureOnline() async {
    final result = await Connectivity().checkConnectivity();
    final online = result != ConnectivityResult.none;
    if (mounted) {
      setState(() {
        _isOnline = online;
      });
    }
    if (!online) {
      _showSnackBar(context.l10n.errorNoInternetConnection);
    }
    return online;
  }

  bool _isOfflineError(Object error) {
    if (error is FirebaseException) {
      return error.code == 'unavailable' ||
          error.code == 'network-request-failed';
    }
    if (error is StateError) {
      return error.message.toLowerCase().contains('internet');
    }
    return false;
  }

  bool _isConfigError(Object error) {
    if (error is StateError) {
      return error.message.toLowerCase().contains('cloudinary');
    }
    return false;
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

  void _goHome() {
    Navigator.of(context).pushNamedAndRemoveUntil(
      Routes.home,
      (route) => false,
    );
  }

  void _goTranslate() {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      _showSnackBar(context.l10n.translationNoText);
      return;
    }
    Navigator.pushNamed(
      context,
      Routes.translate,
      arguments: TranslatePageArgs(
        text: text,
        imageFile: widget.args.imageFile,
      ),
    );
  }

  Future<void> _goAskAi() async {
    final text = _textController.text.trim();
    Uint8List? imageBytes;
    try {
      imageBytes = await widget.args.imageFile.readAsBytes();
    } catch (e, stackTrace) {
      debugPrint('Failed to read image bytes for Ask AI: $e');
      debugPrintStack(stackTrace: stackTrace);
    }

    final args = AskAiArgs(
      imageBytes: imageBytes,
      imagePath: kIsWeb ? null : widget.args.imageFile.path,
      extractedText: text,
    );

    if (args.imageBytes == null && args.imagePath == null) {
      _showSnackBar(context.l10n.aiNoImageAvailable);
      return;
    }

    if (!mounted) return;
    Navigator.pushNamed(
      context,
      Routes.askAi,
      arguments: args,
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _getSelectedText() {
    final selection = _textController.selection;
    if (!selection.isValid || selection.isCollapsed) return '';
    final text = _textController.text;
    final start = selection.start;
    final end = selection.end;
    if (start < 0 || end > text.length || start >= end) return '';
    return text.substring(start, end);
  }

  Future<void> _openSaveWordsSheet() async {
    if (_isOcrLoading) return;
    final extractedText = _textController.text.trim();
    if (extractedText.isEmpty) {
      _showSnackBar(context.l10n.saveWordsNoText);
      return;
    }
    if (!_isOnline) {
      _showSnackBar(context.l10n.errorNoInternetConnection);
      return;
    }

    final initialSelection = _getSelectedText().trim();
    final inputController = TextEditingController(text: initialSelection);
    final colors = Theme.of(context).colorScheme;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.xl),
        ),
      ),
      builder: (sheetContext) {
        bool isSaving = false;
        String? errorText;

        return StatefulBuilder(
          builder: (context, setModalState) {
            final media = MediaQuery.of(context);
            final isDark = Theme.of(context).brightness == Brightness.dark;

            Future<void> handleSave() async {
              if (isSaving) return;
              final value = inputController.text.trim();
              if (value.isEmpty) {
                setModalState(() {
                  errorText = context.l10n.saveWordsSelectOrTypeError;
                });
                return;
              }
              if (value.length < 2 || value.length > 120) {
                setModalState(() {
                  errorText = context.l10n.saveWordsLengthError;
                });
                return;
              }

              if (FirebaseAuth.instance.currentUser == null) {
                Navigator.pop(sheetContext);
                _showSnackBar(context.l10n.authLoginRequiredToSaveWords);
                return;
              }
              if (!await _ensureOnline()) {
                setModalState(() {
                  errorText = context.l10n.errorNoInternetConnection;
                });
                return;
              }

              final normalized = SavedWordsService.normalizeInput(value);
              setModalState(() {
                isSaving = true;
                errorText = null;
              });

              try {
                final service = SavedWordsService.instance;
                final exists = await service.existsNormalized(normalized);
                if (exists) {
                  setModalState(() {
                    isSaving = false;
                    errorText = context.l10n.saveWordsAlreadySaved;
                  });
                  _showSnackBar(context.l10n.saveWordsAlreadySaved);
                  return;
                }

                final language = context.read<SettingsController>().languageCode;
                await service.saveWord(
                  text: value,
                  imageId: _uploadedImageId,
                  language: language,
                );
                if (!sheetContext.mounted) return;
                setModalState(() {
                  isSaving = false;
                });
                Navigator.pop(sheetContext);
                if (!mounted) return;
                _showSnackBar(context.l10n.saveWordsSaved);
              } catch (e, stackTrace) {
                debugPrint('Failed to save word: $e');
                debugPrintStack(stackTrace: stackTrace);
                if (!mounted) return;
                setModalState(() {
                  isSaving = false;
                  errorText = context.l10n.saveWordsFailed;
                });
                _showSnackBar(context.l10n.saveWordsFailed);
              }
            }

            return Padding(
              padding: AppSpacing.only(
                left: AppSpacing.xl,
                right: AppSpacing.xl,
                top: AppSpacing.lg,
                bottom: AppSpacing.lg + media.viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Icon(Icons.bookmark_add_rounded, color: colors.primary),
                      SizedBox(width: AppSpacing.sm),
                      Text(
                        context.l10n.saveWordsTitle,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.sm),
                  Text(
                    context.l10n.saveWordsInstruction,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                  ),
                  SizedBox(height: AppSpacing.md),
                  Container(
                    constraints: BoxConstraints(
                      maxHeight: AppSpacing.xxl +
                          AppSpacing.xxl +
                          AppSpacing.xxl +
                          AppSpacing.xxl,
                    ),
                    padding: AppSpacing.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: isDark ? colors.surfaceVariant : colors.surfaceVariant,
                      borderRadius: AppRadius.circular(AppRadius.md),
                      border: Border.all(color: colors.outlineVariant),
                    ),
                    child: SingleChildScrollView(
                      child: SelectableText(
                        extractedText,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ),
                  SizedBox(height: AppSpacing.md),
                  AppTextField(
                    controller: inputController,
                    maxLines: 2,
                    hintText: context.l10n.saveWordsHint,
                  ),
                  if (errorText != null) ...[
                    SizedBox(height: AppSpacing.sm),
                    Text(
                      errorText!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colors.error,
                          ),
                    ),
                  ],
                  SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      Expanded(
                        child: AppButton.secondary(
                          label: context.l10n.actionCancel,
                          onPressed: ButtonFeedbackService.wrap(
                            sheetContext,
                            isSaving ? null : () => Navigator.pop(sheetContext),
                          ),
                          expanded: true,
                        ),
                      ),
                      SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: AppButton.primary(
                          label: context.l10n.actionSave,
                          onPressed: ButtonFeedbackService.wrap(
                            sheetContext,
                            isSaving ? null : handleSave,
                          ),
                          icon: isSaving
                              ? SizedBox(
                                  width: AppSpacing.lg,
                                  height: AppSpacing.lg,
                                  child: CircularProgressIndicator(
                                    strokeWidth: AppSpacing.xs,
                                    color: colors.onPrimary,
                                  ),
                                )
                              : null,
                          expanded: true,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _saveToHistory() async {
    if (_isSavingHistory || _isOcrLoading) return;
    final text = _textController.text.trim();
    if (text.isEmpty) {
      _showSnackBar(context.l10n.historyNoText);
      return;
    }
    if (FirebaseAuth.instance.currentUser == null) {
      _showSnackBar(context.l10n.authLoginRequiredToSaveHistory);
      return;
    }
    if (!await _ensureOnline()) return;

    setState(() {
      _isSavingHistory = true;
    });

    try {
      await HistoryService.instance.saveExtractionToHistory(
        extractedText: text,
        source: widget.args.source,
        imageId: _uploadedImageId,
        imageUrl: _uploadedImageUrl,
      );
      if (!mounted) return;
      _showSnackBar(context.l10n.historySaved);
    } catch (e, stackTrace) {
      debugPrint('Save history failed: $e');
      debugPrintStack(stackTrace: stackTrace);
      if (!mounted) return;
      final message = _isOfflineError(e)
          ? context.l10n.errorNoInternetConnection
          : context.l10n.historySaveFailed;
      _showSnackBar(message);
    } finally {
      if (!mounted) return;
      setState(() {
        _isSavingHistory = false;
      });
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
        title: Text(context.l10n.ocrExtractResultTitle),
        iconTheme: IconThemeData(color: colors.onBackground),
        actions: const [
          ThemeToggleButton(),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.only(
            left: AppSpacing.xl,
            right: AppSpacing.xl,
            top: AppSpacing.lg,
            bottom: AppSpacing.xl, // ✅ clean padding (no hack)
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildImagePreview(),
              if (_isUploadingImage || _uploadError != null)
                Padding(
                  padding: AppSpacing.only(top: AppSpacing.md),
                  child: _buildUploadStatus(),
                ),
              SizedBox(height: AppSpacing.xl),
              if (_errorMessage != null) _buildErrorBanner(),
              SectionHeader(title: context.l10n.ocrOriginalExtractedText),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_isOcrLoading)
                      Padding(
                        padding: AppSpacing.only(bottom: AppSpacing.md),
                        child: Row(
                          children: [
                            SizedBox(
                              width: AppSpacing.lg,
                              height: AppSpacing.lg,
                              child: CircularProgressIndicator(
                                strokeWidth: AppSpacing.xs,
                                color: colors.primary,
                              ),
                            ),
                            SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                context.l10n.ocrExtractingText,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: colors.onSurfaceVariant,
                                    ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    AppTextField(
                      controller: _textController,
                      maxLines: null,
                      minLines: 8,
                      hintText: _isOcrLoading
                          ? context.l10n.ocrRunning
                          : context.l10n.ocrEditHint,
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: AppButton.secondary(
                      label: context.l10n.historySaveAction,
                      onPressed: ButtonFeedbackService.wrap(
                        context,
                        (_isOcrLoading || _isSavingHistory || !_isOnline)
                            ? null
                            : _saveToHistory,
                      ),
                      icon: _isSavingHistory
                          ? SizedBox(
                              width: AppSpacing.lg,
                              height: AppSpacing.lg,
                              child: CircularProgressIndicator(
                                strokeWidth: AppSpacing.xs,
                                color: colors.primary,
                              ),
                            )
                          : const Icon(Icons.history_rounded),
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AppButton.secondary(
                      label: context.l10n.saveWordsAction,
                      onPressed: ButtonFeedbackService.wrap(
                        context,
                        (_isOcrLoading || !_isOnline) ? null : _openSaveWordsSheet,
                      ),
                      icon: const Icon(Icons.bookmark_add_rounded),
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.sm),
              Text(
                context.l10n.ocrEditInstruction,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ),

      // ✅ FIX: responsive bottom bar => NO OVERFLOW on small phones / large text
      bottomNavigationBar: SafeArea(
  top: false,
  child: LayoutBuilder(
    builder: (context, constraints) {
      final textScale = MediaQuery.textScalerOf(context).scale(1);
      final tightWidth = constraints.maxWidth < 420;
      final largeText = textScale >= 1.05;
      final useTwoRows = tightWidth || largeText;

      final colors = Theme.of(context).colorScheme;

      return Container(
        padding: AppSpacing.only(
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          top: AppSpacing.sm,
          bottom: AppSpacing.lg,
        ),
        decoration: BoxDecoration(
          color: colors.surface,
          boxShadow: [
            BoxShadow(
              color: colors.shadow.withOpacity(0.08),
              blurRadius: AppSpacing.md,
              offset: Offset(0, -AppSpacing.xs),
            ),
          ],
        ),
        child: useTwoRows
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: AppButton.secondary(
                          label: context.l10n.actionHome,
                          onPressed: ButtonFeedbackService.wrap(context, _goHome),
                          icon: const Icon(Icons.home_rounded),
                        ),
                      ),
                      SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: AppButton.primary(
                          label: context.l10n.actionTranslate,
                          onPressed: ButtonFeedbackService.wrap(
                            context,
                            _isOcrLoading ? null : _goTranslate,
                          ),
                          icon: const Icon(Icons.translate_rounded),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.sm),
                  AppButton.primary(
                    label: context.l10n.actionAskAi,
                    onPressed: ButtonFeedbackService.wrap(
                      context,
                      _isOcrLoading ? null : () => _goAskAi(),
                    ),
                    icon: const Icon(Icons.auto_awesome_rounded),
                  ),
                ],
              )
            : Row(
                children: [
                  Expanded(
                    child: AppButton.secondary(
                      label: context.l10n.actionHome,
                      onPressed: ButtonFeedbackService.wrap(context, _goHome),
                      icon: const Icon(Icons.home_rounded),
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: AppButton.primary(
                      label: context.l10n.actionTranslate,
                      onPressed: ButtonFeedbackService.wrap(
                        context,
                        _isOcrLoading ? null : _goTranslate,
                      ),
                      icon: const Icon(Icons.translate_rounded),
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: AppButton.primary(
                      label: context.l10n.actionAskAi,
                      onPressed: ButtonFeedbackService.wrap(
                        context,
                        _isOcrLoading ? null : () => _goAskAi(),
                      ),
                      icon: const Icon(Icons.auto_awesome_rounded),
                    ),
                  ),
                ],
              ),
      );
    },
  ),
),

    );
  }

  Widget _buildImagePreview() {
    final colors = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        borderRadius: AppRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withOpacity(0.2),
            blurRadius: AppSpacing.xl,
            spreadRadius: AppSpacing.xs,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: AppRadius.circular(AppRadius.lg),
        child: Image.file(
          widget.args.imageFile,
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
                _errorMessage ?? '',
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

  Widget _buildUploadStatus() {
    final colors = Theme.of(context).colorScheme;
    if (_isUploadingImage) {
      return Row(
        children: [
          SizedBox(
            width: AppSpacing.lg,
            height: AppSpacing.lg,
            child: CircularProgressIndicator(
              strokeWidth: AppSpacing.xs,
              color: colors.primary,
            ),
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              context.l10n.uploadingImage,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }
    if (_uploadError != null) {
      return Row(
        children: [
          Icon(Icons.cloud_off, color: colors.error),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              _uploadError!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.error,
                  ),
            ),
          ),
          TextButton(
            onPressed: ButtonFeedbackService.wrap(
              context,
              _uploadImageIfNeeded,
            ),
            child: Text(context.l10n.actionRetry),
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  String _extractFileName(String path) {
    final normalized = path.replaceAll('\\', '/');
    final parts = normalized.split('/');
    final name = parts.isNotEmpty ? parts.last : '';
    if (name.trim().isEmpty) {
      return 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';
    }
    return name;
  }
}

/// ✅ Responsive bottom bar that avoids overflow on small phones / large text.
class _ResponsiveBottomBar extends StatelessWidget {
  final VoidCallback onHome;
  final VoidCallback? onTranslate;
  final VoidCallback? onAskAi;

  const _ResponsiveBottomBar({
    required this.onHome,
    required this.onTranslate,
    required this.onAskAi,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textScale = MediaQuery.textScalerOf(context).scale(1);

    return LayoutBuilder(
      builder: (context, constraints) {
        final tightWidth = constraints.maxWidth < 380;
        final largeText = textScale >= 1.15;

        // If screen is narrow OR user has large font => use 2 rows
        final useTwoRows = tightWidth || largeText;

        return Container(
          padding: AppSpacing.only(
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            top: AppSpacing.sm,
            bottom: AppSpacing.lg,
          ),
          decoration: BoxDecoration(
            color: colors.surface,
            boxShadow: [
              BoxShadow(
                color: colors.shadow.withOpacity(0.08),
                blurRadius: AppSpacing.md,
                offset: Offset(0, -AppSpacing.xs),
              ),
            ],
          ),
          child: useTwoRows
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: AppButton.secondary(
                            label: context.l10n.actionHome,
                            onPressed: ButtonFeedbackService.wrap(context, onHome),
                            icon: const Icon(Icons.home_rounded),
                          ),
                        ),
                        SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: AppButton.primary(
                            label: context.l10n.actionTranslate,
                            onPressed: ButtonFeedbackService.wrap(
                              context,
                              onTranslate,
                            ),
                            icon: const Icon(Icons.translate_rounded),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSpacing.sm),
                    AppButton.primary(
                      label: context.l10n.actionAskAi,
                      onPressed: ButtonFeedbackService.wrap(context, onAskAi),
                      icon: const Icon(Icons.auto_awesome_rounded),
                      expanded: true,
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(
                      child: AppButton.secondary(
                        label: context.l10n.actionHome,
                        onPressed: ButtonFeedbackService.wrap(context, onHome),
                        icon: const Icon(Icons.home_rounded),
                      ),
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: AppButton.primary(
                        label: context.l10n.actionTranslate,
                        onPressed: ButtonFeedbackService.wrap(
                          context,
                          onTranslate,
                        ),
                        icon: const Icon(Icons.translate_rounded),
                      ),
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: AppButton.primary(
                        label: context.l10n.actionAskAi,
                        onPressed: ButtonFeedbackService.wrap(context, onAskAi),
                        icon: const Icon(Icons.auto_awesome_rounded),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}
