import 'package:flutter/material.dart';
import 'package:askcam/core/utils/settings_storage.dart';

class LocaleController extends ChangeNotifier {
  LocaleController({required SettingsStorage storage}) : _storage = storage;

  final SettingsStorage _storage;

  Locale? _locale;
  Locale? get locale => _locale;

  static const List<String> supportedLanguageCodes = ['en', 'fr', 'ar'];

  Future<void> loadSavedLocale() async {
    final stored = await _storage.readLanguageCode();
    if (stored != null && _isSupported(stored)) {
      _locale = Locale(stored);
    } else {
      _locale = null;
    }
    notifyListeners();
  }

  Future<void> changeLocale(Locale locale) async {
    if (!_isSupported(locale.languageCode)) return;
    if (_locale?.languageCode == locale.languageCode) return;
    _locale = Locale(locale.languageCode);
    notifyListeners();
    await _storage.writeLanguageCode(locale.languageCode);
  }

  bool _isSupported(String code) => supportedLanguageCodes.contains(code);
}
