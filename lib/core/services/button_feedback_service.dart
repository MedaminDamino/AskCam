import 'dart:async';

import 'package:askcam/features/presentation/settings/settings_controller.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class ButtonFeedbackService {
  ButtonFeedbackService._();

  static final ButtonFeedbackService instance = ButtonFeedbackService._();

  static const String _assetPath = 'audio/ui_click.wav';

  final AudioPlayer _player = AudioPlayer();
  bool _isPlayerReady = false;

  static VoidCallback? wrap(BuildContext context, VoidCallback? action) {
    if (action == null) return null;
    return () {
      ButtonFeedbackService.instance.trigger(context);
      action();
    };
  }

  void trigger(BuildContext context) {
    final settings = context.read<SettingsController>();
    if (settings.silentMode) return;
    if (settings.vibrationEnabled) {
      unawaited(_playHaptic());
    }
    if (settings.soundEnabled) {
      unawaited(_playSound());
    }
  }

  Future<void> _playHaptic() async {
    try {
      await HapticFeedback.lightImpact();
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('Haptic feedback failed: $e');
        debugPrintStack(stackTrace: stackTrace);
      }
    }
  }

  Future<void> _playSound() async {
    try {
      if (!_isPlayerReady) {
        await _player.setReleaseMode(ReleaseMode.stop);
        _isPlayerReady = true;
      }
      await _player.play(
        AssetSource(_assetPath),
        volume: 0.35,
      );
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('Button sound failed: $e');
        debugPrintStack(stackTrace: stackTrace);
      }
    }
  }
}
