import 'package:askcam/core/config/ai_config.dart';
import 'package:askcam/core/config/cloudinary_config.dart';
import 'package:flutter/foundation.dart';

class AppRuntimeConfig {
  static const String keyAiApiKey = 'AI_API_KEY';
  static const String keyCloudName = 'CLOUDINARY_CLOUD_NAME';
  static const String keyCloudPreset = 'CLOUDINARY_UPLOAD_PRESET';

  static bool get isCloudinaryReady => CloudinaryConfig.hasConfig;
  static bool get isAiReady => AiConfig.hasKey;

  static List<String> get missingKeys {
    final keys = <String>[];
    if (!CloudinaryConfig.hasConfig) {
      if (CloudinaryConfig.cloudName.trim().isEmpty) {
        keys.add(keyCloudName);
      }
      if (CloudinaryConfig.uploadPreset.trim().isEmpty) {
        keys.add(keyCloudPreset);
      }
    }
    if (!AiConfig.hasKey) {
      keys.add(keyAiApiKey);
    }
    return keys;
  }

  static String buildRunArgs([List<String>? keys]) {
    final list = keys ?? missingKeys;
    if (list.isEmpty) return '';
    return list.map((key) => '--dart-define=$key=YOUR_VALUE').join(' ');
  }

  static void logMissingConfig() {
    if (!kDebugMode) return;
    final args = buildRunArgs();
    if (args.isEmpty) return;
    debugPrint('Missing runtime config. Run args: $args');
  }
}
