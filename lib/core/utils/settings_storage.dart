import 'package:shared_preferences/shared_preferences.dart';

class SettingsStorage {
  static const String _languageCodeKey = 'settings_language_code';
  static const String _autoEnhanceImagesKey = 'settings_auto_enhance_images';
  static const String _autoDetectLanguageKey = 'settings_auto_detect_language';
  static const String _soundEnabledKey = 'settings_sound_enabled';
  static const String _vibrationEnabledKey = 'settings_vibration_enabled';
  static const String _silentModeKey = 'settings_silent_mode';

  Future<String?> readLanguageCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageCodeKey);
  }

  Future<bool?> readAutoEnhanceImages() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_autoEnhanceImagesKey);
  }

  Future<bool?> readAutoDetectLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_autoDetectLanguageKey);
  }

  Future<bool?> readSoundEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_soundEnabledKey);
  }

  Future<bool?> readVibrationEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_vibrationEnabledKey);
  }

  Future<bool?> readSilentMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_silentModeKey);
  }

  Future<void> writeLanguageCode(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageCodeKey, code);
  }

  Future<void> writeAutoEnhanceImages(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoEnhanceImagesKey, value);
  }

  Future<void> writeAutoDetectLanguage(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoDetectLanguageKey, value);
  }

  Future<void> writeSoundEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_soundEnabledKey, value);
  }

  Future<void> writeVibrationEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_vibrationEnabledKey, value);
  }

  Future<void> writeSilentMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_silentModeKey, value);
  }
}
