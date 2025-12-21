import 'package:flutter/foundation.dart';

class CloudinaryConfig {
  static const String cloudName =
      String.fromEnvironment('CLOUDINARY_CLOUD_NAME');
  static const String uploadPreset =
      String.fromEnvironment('CLOUDINARY_UPLOAD_PRESET');

  static bool get hasConfig =>
      cloudName.trim().isNotEmpty && uploadPreset.trim().isNotEmpty;

  static void logMissingConfig() {
    if (!kDebugMode) return;
    debugPrint(
      'Missing Cloudinary config. Run with: '
      'flutter run --dart-define=CLOUDINARY_CLOUD_NAME=dncfxydui'
      '--dart-define=CLOUDINARY_UPLOAD_PRESET=itjfaoc8',
    );
  }
}
