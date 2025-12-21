import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class MLKitManager {
  static final MLKitManager _instance = MLKitManager._internal();
  factory MLKitManager() => _instance;
  MLKitManager._internal();

  bool _isProcessing = false;
  /// Check if device is on WiFi (for model downloads)
  Future<bool> isOnWiFi() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      return connectivityResult == ConnectivityResult.wifi;
    } catch (e) {
      debugPrint('⚠️ Connectivity check failed: $e');
      return false; // Assume not on WiFi if check fails
    }
  }

  /// Queue ML operations to prevent simultaneous processing
  Future<T> queueOperation<T>(Future<T> Function() operation) async {
    // If something is processing, wait
    while (_isProcessing) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    _isProcessing = true;
    debugPrint('🔄 ML operation started');

    try {
      final result = await operation();
      debugPrint('✅ ML operation completed');
      return result;
    } finally {
      _isProcessing = false;
    }
  }

  /// Check if models should be downloaded
  Future<bool> shouldDownloadModels() async {
    // Only download on WiFi
    return await isOnWiFi();
  }
}
