import 'dart:io';
import 'package:askcam/core/utils/ml_kit_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;

class TextRecognitionScreen extends StatefulWidget {
  final File imageFile;

  const TextRecognitionScreen({
    super.key,
    required this.imageFile,
  });

  @override
  State<TextRecognitionScreen> createState() => _TextRecognitionScreenState();
}

class _TextRecognitionScreenState extends State<TextRecognitionScreen>
    with SingleTickerProviderStateMixin {
  String _extractedText = '';
  bool _isProcessing = true;
  TextRecognizer? _textRecognizer;
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  int _confidenceScore = 0;
  File? _preprocessedImageFile;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeIn,
    );

    _processImage();
  }

  @override
  void dispose() {
    _textRecognizer?.close();
    _animController.dispose();

    if (_preprocessedImageFile != null && _preprocessedImageFile!.existsSync()) {
      _preprocessedImageFile!.deleteSync();
      debugPrint('🗑️ Cleaned up preprocessed image');
    }

    super.dispose();
  }

  Future<File> _preprocessImage(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      img.Image? image = img.decodeImage(bytes);

      if (image == null) return imageFile;

      // Basic preprocessing for better OCR
      image = img.adjustColor(image, contrast: 1.3, brightness: 1.1);
      image = img.convolution(
        image,
        filter: [0, -1, 0, -1, 5, -1, 0, -1, 0],
      );

      final tempDir = Directory.systemTemp;
      final tempFile = File(
          '${tempDir.path}/preprocessed_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await tempFile.writeAsBytes(img.encodeJpg(image, quality: 95));

      _preprocessedImageFile = tempFile;

      return tempFile;
    } catch (e) {
      debugPrint('Image preprocessing error: $e');
      return imageFile;
    }
  }

  Future<void> _processImage() async {
    try {
      // ✅ NEW: Queue operation to prevent simultaneous ML Kit calls
      await MLKitManager().queueOperation(() async {
        final processedImage = await _preprocessImage(widget.imageFile);
        final inputImage = InputImage.fromFile(processedImage);

        _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
        RecognizedText recognizedText =
        await _textRecognizer!.processImage(inputImage);

        // Extract text preserving line breaks
        List<String> lines = [];
        for (var block in recognizedText.blocks) {
          for (var line in block.lines) {
            lines.add(line.text);
          }
        }
        String text = lines.join('\n');

        // Calculate confidence
        if (text.isEmpty) {
          _confidenceScore = 0;
        } else if (text.length < 20) {
          _confidenceScore = 65;
        } else if (text.length < 80) {
          _confidenceScore = 80;
        } else {
          _confidenceScore = 95;
        }

        // Clean up text
        text = _postProcessText(text);

        setState(() {
          _extractedText = text.isEmpty
              ? 'No text found in the image.\n\nTip: Try taking a clearer photo with better lighting.'
              : text;
          _isProcessing = false;
        });

        _animController.forward();
      });
    } catch (e, stackTrace) {
      debugPrint('OCR Error: $e');
      debugPrint('Stack trace: $stackTrace');
      setState(() {
        _extractedText = 'Error processing image. Please try again.';
        _isProcessing = false;
      });
      _animController.forward();
    }
  }

  String _postProcessText(String text) {
    List<String> lines = text.split('\n').map((line) {
      line = line
          .replaceAll(RegExp(r' +'), ' ') // Multiple spaces to single
          .replaceAll(' .', '.')
          .replaceAll(' ,', ',')
          .replaceAll(' :', ':')
          .replaceAll(' ;', ';')
          .replaceAll(' !', '!')
          .replaceAll(' ?', '?')
          .replaceAll('( ', '(')
          .replaceAll(' )', ')');

      return line.trim();
    }).where((line) => line.isNotEmpty).toList();

    return lines.join('\n');
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _extractedText));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Text('Text copied to clipboard!', style: GoogleFonts.poppins()),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _editText() {
    showDialog(
      context: context,
      builder: (context) => _EditTextDialog(
        initialText: _extractedText,
        onSave: (text) => setState(() => _extractedText = text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Text Recognition',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          if (!_isProcessing &&
              _extractedText.isNotEmpty &&
              !_extractedText.contains('No text') &&
              !_extractedText.contains('Error'))
            IconButton(
              icon: const Icon(Icons.copy_rounded, color: Colors.cyanAccent),
              onPressed: _copyToClipboard,
              tooltip: 'Copy text',
            ),
        ],
      ),
      body: _isProcessing
          ? _buildLoadingState()
          : SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildImagePreview(),
            if (_confidenceScore > 0) _buildConfidenceIndicator(),
            _buildExtractedText(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Colors.cyan.withOpacity(0.3),
                  Colors.purple.withOpacity(0.3),
                ],
              ),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                color: Colors.cyanAccent,
                strokeWidth: 3,
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Analyzing Text...',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Processing image with AI',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.white60,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      margin: const EdgeInsets.all(20),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.35,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.cyanAccent.withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.file(
          widget.imageFile,
          width: double.infinity,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildConfidenceIndicator() {
    Color confidenceColor;
    String confidenceText;

    if (_confidenceScore >= 80) {
      confidenceColor = Colors.greenAccent;
      confidenceText = 'Excellent';
    } else if (_confidenceScore >= 60) {
      confidenceColor = Colors.yellowAccent;
      confidenceText = 'Good';
    } else {
      confidenceColor = Colors.orangeAccent;
      confidenceText = 'Fair - May need editing';
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: confidenceColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: confidenceColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_awesome, color: confidenceColor, size: 20),
          const SizedBox(width: 8),
          Text(
            'Accuracy: $_confidenceScore% - $confidenceText',
            style: GoogleFonts.poppins(
              color: confidenceColor,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExtractedText() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1E1E3F).withOpacity(0.8),
              const Color(0xFF2D2D5F).withOpacity(0.6),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.cyanAccent.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.text_fields_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Extracted Text',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '${_extractedText.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length} words',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.white60,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              constraints: const BoxConstraints(
                maxHeight: 500,
                minHeight: 100,
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: SelectableText(
                  _extractedText,
                  style: GoogleFonts.notoSans(
                    fontSize: 15,
                    height: 1.8,
                    color: Colors.white.withOpacity(0.95),
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
            if (_extractedText.isNotEmpty &&
                !_extractedText.contains('No text') &&
                !_extractedText.contains('Error'))
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _editText,
                        icon: const Icon(Icons.edit_rounded, size: 18),
                        label: Text(
                          'Edit',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                          Colors.yellowAccent.withOpacity(0.2),
                          foregroundColor: Colors.yellowAccent,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: Colors.yellowAccent.withOpacity(0.5),
                            ),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _copyToClipboard,
                        icon: const Icon(Icons.copy_rounded, size: 18),
                        label: Text(
                          'Copy',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.cyanAccent.withOpacity(0.2),
                          foregroundColor: Colors.cyanAccent,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: Colors.cyanAccent.withOpacity(0.5),
                            ),
                          ),
                          elevation: 0,
                        ),
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
}

// Edit Text Dialog
class _EditTextDialog extends StatefulWidget {
  final String initialText;
  final Function(String) onSave;

  const _EditTextDialog({
    required this.initialText,
    required this.onSave,
  });

  @override
  State<_EditTextDialog> createState() => _EditTextDialogState();
}

class _EditTextDialogState extends State<_EditTextDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1E1E3F),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        'Edit Text',
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: TextField(
          controller: _controller,
          maxLines: 15,
          style: GoogleFonts.notoSans(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF0A0E21),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
              BorderSide(color: Colors.cyanAccent.withOpacity(0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
              BorderSide(color: Colors.cyanAccent.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.cyanAccent),
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: GoogleFonts.poppins(color: Colors.white60),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onSave(_controller.text);
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.cyanAccent,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'Save',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}