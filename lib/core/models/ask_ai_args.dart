import 'dart:typed_data';

class AskAiArgs {
  final Uint8List? imageBytes;
  final String? imagePath;
  final String extractedText;

  AskAiArgs({
    this.imageBytes,
    this.imagePath,
    required this.extractedText,
  });
}
