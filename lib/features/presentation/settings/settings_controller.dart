import 'package:flutter/foundation.dart';
import 'package:askcam/core/utils/settings_storage.dart';

class SettingsController extends ChangeNotifier {
  final SettingsStorage _storage;

  SettingsController({required SettingsStorage storage}) : _storage = storage;

  String _languageCode = 'en';
  bool _autoEnhanceImages = true;
  bool _autoDetectLanguage = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _silentMode = false;
  bool _isLoaded = false;

  String get languageCode => _languageCode;
  bool get autoEnhanceImages => _autoEnhanceImages;
  bool get autoDetectLanguage => _autoDetectLanguage;
  bool get soundEnabled => _soundEnabled;
  bool get vibrationEnabled => _vibrationEnabled;
  bool get silentMode => _silentMode;
  bool get isLoaded => _isLoaded;

  static const Map<String, String> supportedLanguages = {
    'en': 'English',
    'fr': 'French',
  };

  Future<void> load() async {
    final storedLanguage = await _storage.readLanguageCode();
    final storedEnhance = await _storage.readAutoEnhanceImages();
    final storedDetect = await _storage.readAutoDetectLanguage();
    final storedSound = await _storage.readSoundEnabled();
    final storedVibration = await _storage.readVibrationEnabled();
    final storedSilent = await _storage.readSilentMode();

    _languageCode = supportedLanguages.containsKey(storedLanguage)
        ? storedLanguage!
        : 'en';
    _autoEnhanceImages = storedEnhance ?? true;
    _autoDetectLanguage = storedDetect ?? true;
    _soundEnabled = storedSound ?? true;
    _vibrationEnabled = storedVibration ?? true;
    _silentMode = storedSilent ?? false;
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> setLanguageCode(String code) async {
    if (!supportedLanguages.containsKey(code)) return;
    if (_languageCode == code) return;
    _languageCode = code;
    notifyListeners();
    await _storage.writeLanguageCode(code);
  }

  Future<void> setAutoEnhanceImages(bool value) async {
    if (_autoEnhanceImages == value) return;
    _autoEnhanceImages = value;
    notifyListeners();
    await _storage.writeAutoEnhanceImages(value);
  }

  Future<void> setAutoDetectLanguage(bool value) async {
    if (_autoDetectLanguage == value) return;
    _autoDetectLanguage = value;
    notifyListeners();
    await _storage.writeAutoDetectLanguage(value);
  }

  Future<void> setSoundEnabled(bool value) async {
    if (_soundEnabled == value) return;
    _soundEnabled = value;
    notifyListeners();
    await _storage.writeSoundEnabled(value);
  }

  Future<void> setVibrationEnabled(bool value) async {
    if (_vibrationEnabled == value) return;
    _vibrationEnabled = value;
    notifyListeners();
    await _storage.writeVibrationEnabled(value);
  }

  Future<void> setSilentMode(bool value) async {
    if (_silentMode == value) return;
    _silentMode = value;
    notifyListeners();
    await _storage.writeSilentMode(value);
  }
}
