import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends ChangeNotifier {
  static const String _storageKey = 'theme_mode';

  ThemeMode _mode = ThemeMode.light;

  ThemeMode get mode => _mode;

  Future<void> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_storageKey);
    if (stored == null) {
      _mode = ThemeMode.light;
      return;
    }

    if (stored == 'system') {
      final platformBrightness =
          WidgetsBinding.instance.platformDispatcher.platformBrightness;
      _mode = platformBrightness == Brightness.dark
          ? ThemeMode.dark
          : ThemeMode.light;
      await prefs.setString(_storageKey, _serializeThemeMode(_mode));
      return;
    }

    _mode = _parseThemeMode(stored);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (mode == ThemeMode.system) {
      final platformBrightness =
          WidgetsBinding.instance.platformDispatcher.platformBrightness;
      mode = platformBrightness == Brightness.dark
          ? ThemeMode.dark
          : ThemeMode.light;
    }

    if (_mode == mode) return;
    _mode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, _serializeThemeMode(mode));
  }

  static ThemeMode _parseThemeMode(String? value) {
    switch (value) {
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.light;
    }
  }

  static String _serializeThemeMode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.dark:
        return 'dark';
      default:
        return 'light';
    }
  }
}
