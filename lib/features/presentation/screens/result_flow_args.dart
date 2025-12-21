import 'dart:io';

class ExtractResultArgs {
  final File imageFile;
  final String source;

  const ExtractResultArgs({
    required this.imageFile,
    this.source = 'camera',
  });
}

class TranslatePageArgs {
  final String text;
  final File? imageFile;

  const TranslatePageArgs({
    required this.text,
    this.imageFile,
  });
}
