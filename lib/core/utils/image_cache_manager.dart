import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class ImageCacheManager {
  // Singleton pattern
  static final ImageCacheManager _instance = ImageCacheManager._internal();
  factory ImageCacheManager() => _instance;
  ImageCacheManager._internal();

  /// Clear all temporary images older than 24 hours
  Future<void> clearOldCache() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final now = DateTime.now();

      int deletedCount = 0;

      await for (var entity in tempDir.list()) {
        if (entity is File) {
          final fileName = entity.path.split('/').last;

          // Only delete our app's temp files
          if (fileName.startsWith('compressed_') ||
              fileName.startsWith('preprocessed_')) {

            final stat = await entity.stat();
            final age = now.difference(stat.modified);

            // Delete if older than 24 hours
            if (age.inHours > 24) {
              await entity.delete();
              deletedCount++;
            }
          }
        }
      }

      debugPrint('🧹 Cache cleanup: $deletedCount old files deleted');
    } catch (e) {
      debugPrint('⚠️ Cache cleanup error: $e');
    }
  }

  /// Clear ALL temporary images immediately
  Future<void> clearAllCache() async {
    try {
      final tempDir = await getTemporaryDirectory();
      int deletedCount = 0;

      await for (var entity in tempDir.list()) {
        if (entity is File) {
          final fileName = entity.path.split('/').last;

          if (fileName.startsWith('compressed_') ||
              fileName.startsWith('preprocessed_')) {
            await entity.delete();
            deletedCount++;
          }
        }
      }

      debugPrint('🧹 Full cache clear: $deletedCount files deleted');
    } catch (e) {
      debugPrint('⚠️ Full cache clear error: $e');
    }
  }

  /// Get total cache size in MB
  Future<double> getCacheSize() async {
    try {
      final tempDir = await getTemporaryDirectory();
      int totalBytes = 0;

      await for (var entity in tempDir.list()) {
        if (entity is File) {
          final fileName = entity.path.split('/').last;

          if (fileName.startsWith('compressed_') ||
              fileName.startsWith('preprocessed_')) {
            final stat = await entity.stat();
            totalBytes += stat.size;
          }
        }
      }

      return totalBytes / 1024 / 1024; // Convert to MB
    } catch (e) {
      debugPrint('⚠️ Cache size calculation error: $e');
      return 0.0;
    }
  }
}