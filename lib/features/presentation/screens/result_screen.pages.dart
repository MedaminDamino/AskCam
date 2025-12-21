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
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:provider/provider.dart';

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
        _errorMessage =
            'We could not read this photo. Please retake it in better lighting.';
        _isOcrLoading = false;
      });
      _showSnackBar('Unable to extract text. Please try another photo.');
    }
  }

  Future<void> _uploadImageIfNeeded() async {
    if (_isUploadingImage || _uploadedImageUrl != null) return;
    if (!await _ensureOnline()) return;

    if (FirebaseAuth.instance.currentUser == null) {
      _showSnackBar('Please login to save images.');
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
          _uploadError =
              'Cloudinary is not configured. Please run the app with $args';
        } else if (_isOfflineError(e)) {
          _uploadError = 'No internet connection';
          _isOnline = false;
        } else {
          _uploadError = 'Upload failed. Please try again.';
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
      _showSnackBar('No internet connection');
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
      _showSnackBar('No text to translate yet.');
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
      _showSnackBar('No image available for AI.');
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
      _showSnackBar('No text to save yet.');
      return;
    }
    if (!_isOnline) {
      _showSnackBar('No internet connection');
      return;
    }

    final initialSelection = _getSelectedText().trim();
    final inputController = TextEditingController(text: initialSelection);
    final colors = Theme.of(context).colorScheme;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                  errorText = 'Select a word/phrase first or type one.';
                });
                return;
              }
              if (value.length < 2 || value.length > 120) {
                setModalState(() {
                  errorText =
                      'Word length must be between 2 and 120 characters.';
                });
                return;
              }

              if (FirebaseAuth.instance.currentUser == null) {
                Navigator.pop(sheetContext);
                _showSnackBar('Please login to save words.');
                return;
              }
              if (!await _ensureOnline()) {
                setModalState(() {
                  errorText = 'No internet connection';
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
                    errorText = 'Already saved.';
                  });
                  _showSnackBar('Already saved.');
                  return;
                }

                final language =
                    context.read<SettingsController>().languageCode;
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
                _showSnackBar('Saved.');
              } catch (e, stackTrace) {
                debugPrint('Failed to save word: $e');
                debugPrintStack(stackTrace: stackTrace);
                if (!mounted) return;
                setModalState(() {
                  isSaving = false;
                  errorText = 'Failed to save, try again.';
                });
                _showSnackBar('Failed to save, try again.');
              }
            }

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 16,
                bottom: 16 + media.viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Icon(Icons.bookmark_add_rounded,
                          color: colors.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Save words',
                        style: GoogleFonts.poppins(
                          color: colors.onSurface,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Select a word or phrase in the text above, or type one below.',
                    style: GoogleFonts.poppins(
                      color: colors.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    constraints: const BoxConstraints(maxHeight: 140),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1F1F3B)
                          : colors.surfaceVariant.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: colors.outlineVariant),
                    ),
                    child: SingleChildScrollView(
                      child: SelectableText(
                        extractedText,
                        style: GoogleFonts.poppins(
                          color: colors.onSurface,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: inputController,
                    maxLines: 2,
                    style: GoogleFonts.poppins(
                      color: colors.onSurface,
                      fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Type a word or phrase to save',
                      hintStyle: GoogleFonts.poppins(
                        color: colors.onSurfaceVariant,
                        fontSize: 13,
                      ),
                      filled: true,
                      fillColor: colors.surfaceVariant.withOpacity(0.5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  if (errorText != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      errorText!,
                      style: GoogleFonts.poppins(
                        color: colors.error,
                        fontSize: 12,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: ButtonFeedbackService.wrap(
                            sheetContext,
                            isSaving
                                ? null
                                : () => Navigator.pop(sheetContext),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: ButtonFeedbackService.wrap(
                            sheetContext,
                            isSaving ? null : handleSave,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colors.primary,
                            foregroundColor: colors.onPrimary,
                          ),
                          child: isSaving
                              ? SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: colors.onPrimary,
                                  ),
                                )
                              : const Text('Save'),
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
      _showSnackBar('No text to save yet.');
      return;
    }
    if (FirebaseAuth.instance.currentUser == null) {
      _showSnackBar('Please login to save history.');
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
      _showSnackBar('Saved to history.');
    } catch (e, stackTrace) {
      debugPrint('Save history failed: $e');
      debugPrintStack(stackTrace: stackTrace);
      if (!mounted) return;
      final message =
          _isOfflineError(e) ? 'No internet connection' : 'Failed to save.';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Extract Result',
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
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildImagePreview(),
              if (_isUploadingImage || _uploadError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: _buildUploadStatus(),
                ),
              const SizedBox(height: 20),
              if (_errorMessage != null) _buildErrorBanner(),
              Text(
                'Original extracted text',
                style: GoogleFonts.poppins(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: isDark
                      ? const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF1F1F3B), Color(0xFF2A2A50)],
                        )
                      : LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [colors.surface, colors.surfaceVariant],
                        ),
                  border: Border.all(color: colors.outlineVariant),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_isOcrLoading)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: colors.primary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Extracting text...',
                              style: GoogleFonts.poppins(
                                color: colors.onSurfaceVariant,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    TextField(
                      controller: _textController,
                      maxLines: null,
                      minLines: 8,
                      style: GoogleFonts.poppins(
                        color: colors.onSurface,
                        fontSize: 14,
                        height: 1.5,
                      ),
                      decoration: InputDecoration(
                        hintText: _isOcrLoading
                            ? 'OCR is running...'
                            : 'Edit the extracted text here.',
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
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: ButtonFeedbackService.wrap(
                        context,
                        (_isOcrLoading || _isSavingHistory || !_isOnline)
                            ? null
                            : _saveToHistory,
                      ),
                      icon: _isSavingHistory
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: colors.primary,
                              ),
                            )
                          : const Icon(Icons.history_rounded, size: 18),
                      label: const Text('Save history'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: ButtonFeedbackService.wrap(
                        context,
                        (_isOcrLoading || !_isOnline)
                            ? null
                            : _openSaveWordsSheet,
                      ),
                      icon: const Icon(Icons.bookmark_add_rounded, size: 18),
                      label: const Text('Save words'),
                    ),
                  ),
                ],
              ),
              Text(
                'Edit the text if OCR missed anything before translating or asking AI.',
                style: GoogleFonts.poppins(
                  color: colors.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          decoration: BoxDecoration(
            color: colors.surface,
            boxShadow: [
              BoxShadow(
                color: colors.shadow.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: ButtonFeedbackService.wrap(context, _goHome),
                  icon: const Icon(Icons.home_rounded, size: 18),
                  label: const Text('Home'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: ButtonFeedbackService.wrap(
                    context,
                    _isOcrLoading ? null : _goTranslate,
                  ),
                  icon: const Icon(Icons.translate_rounded, size: 18),
                  label: const Text('Translate'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: colors.primary,
                    foregroundColor: colors.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: ButtonFeedbackService.wrap(
                    context,
                    _isOcrLoading ? null : _goAskAi,
                  ),
                  icon: const Icon(Icons.auto_awesome_rounded, size: 18),
                  label: const Text('Ask AI'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: colors.tertiary,
                    foregroundColor: colors.onTertiary,
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
          widget.args.imageFile,
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
              _errorMessage ?? '',
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

  Widget _buildUploadStatus() {
    final colors = Theme.of(context).colorScheme;
    if (_isUploadingImage) {
      return Row(
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: colors.primary,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Uploading image to cloud...',
            style: GoogleFonts.poppins(
              color: colors.onSurfaceVariant,
              fontSize: 12,
            ),
          ),
        ],
      );
    }
    if (_uploadError != null) {
      return Row(
        children: [
          Icon(Icons.cloud_off, color: colors.error, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _uploadError!,
              style: GoogleFonts.poppins(
                color: colors.error,
                fontSize: 12,
              ),
            ),
          ),
          TextButton(
            onPressed: ButtonFeedbackService.wrap(
              context,
              _uploadImageIfNeeded,
            ),
            child: const Text('Retry'),
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
