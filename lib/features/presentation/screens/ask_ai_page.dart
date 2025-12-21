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
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

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
          'AI is not configured. Please run the app with $args';
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
          _showSnackBar('No image available for AI analysis.');
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
        final message = result.message;
        setState(() {
          _answer = message;
          _isConfigMissing = _isConfigErrorMessage(message);
        });
        _showSnackBar(message);
        return;
      }
      setState(() {
        final cleaned = result.message.trim();
        _answer = _isUnhelpfulAnswer(cleaned)
            ? "I couldn't detect readable text or a clear question in this image. Please try another image or crop the area you want."
            : cleaned;
      });
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('AskAiPage error: $e');
        debugPrintStack(stackTrace: stackTrace);
      }
      if (!mounted) return;
      const message =
          'We could not reach the AI service right now. Please try again later.';
      setState(() {
        _answer = message;
      });
      _showSnackBar(message);
    } finally {
      if (!mounted) return;
      setState(() => _isAsking = false);
    }
  }

  void _copyAnswer() {
    if (_answer.trim().isEmpty) return;
    Clipboard.setData(ClipboardData(text: _answer));
    _showSnackBar('AI answer copied to clipboard.');
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
        title: Text(
          'Ask AI',
          style: GoogleFonts.poppins(
            color: colors.onBackground,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: IconThemeData(color: colors.onBackground),
        actions: [
          IconButton(
            tooltip: 'Copy answer',
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
            child: const Text('Back'),
          ),
          const ThemeToggleButton(),
        ],
      ),
      body: SafeArea(
        child: hasImage
            ? SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildImagePreview(colors),
                    const SizedBox(height: 20),
                    Text(
                      'Ask a question',
                      style: GoogleFonts.poppins(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _questionController,
                      minLines: 2,
                      maxLines: 4,
                      style: GoogleFonts.poppins(
                        color: colors.onSurface,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        hintText:
                            'Optional: ask AI about the extracted text / image...',
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
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: ButtonFeedbackService.wrap(
                          context,
                          (_isAsking || _isConfigMissing) ? null : _askAi,
                        ),
                        icon: _isAsking
                            ? SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: colors.onPrimary,
                                ),
                              )
                            : const Icon(Icons.auto_awesome_rounded),
                        label: Text(_isAsking ? 'Asking AI...' : 'Ask AI'),
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
                      'AI answer',
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
                                'Response',
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
                                  _answer.trim().isEmpty ? null : _copyAnswer,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _answer.isEmpty
                                ? 'AI response will appear here.'
                                : _answer,
                            style: GoogleFonts.poppins(
                              color: colors.onSurface,
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
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
              )
            : Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.image_not_supported,
                          size: 48, color: colors.onSurfaceVariant),
                      const SizedBox(height: 12),
                      Text(
                        'No image provided',
                        style: GoogleFonts.poppins(
                          color: colors.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: ButtonFeedbackService.wrap(
                          context,
                          () => Navigator.pop(context),
                        ),
                        icon: const Icon(Icons.arrow_back_rounded),
                        label: const Text('Back to Extract'),
                      ),
                    ],
                  ),
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
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withOpacity(0.15),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
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
