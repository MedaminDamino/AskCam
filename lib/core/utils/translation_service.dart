import 'package:flutter/foundation.dart';
import 'package:translator/translator.dart';

/// Provides translation utilities for OCR results while keeping UI layers lean.
class TranslationService {
  TranslationService._private();

  /// Shared singleton instance used throughout the app.
  static final TranslationService instance = TranslationService._private();

  /// Translator client that automatically detects source language.
  final GoogleTranslator _translator = GoogleTranslator();

  /// Translates [text] into [targetLang] asynchronously to avoid blocking the UI.
  Future<String> translate(
    String text, {
    required String targetLang,
    String sourceLang = 'auto',
  }) async {
    if (text.trim().isEmpty) return '';

    try {
      final translation = await _translator.translate(
        text,
        to: targetLang,
        from: sourceLang,
      );
      return translation.text;
    } catch (error, stackTrace) {
      // Log error details and fall back to returning the original text.
      debugPrint('TranslationService.translate error: $error');
      debugPrint('$stackTrace');
      return text;
    }
  }

  /// Convenience helper to translate any input to English.
  Future<String> translateToEnglish(String text) =>
      translate(text, targetLang: 'en');

  /// Convenience helper to translate any input to French.
  Future<String> translateToFrench(String text) =>
      translate(text, targetLang: 'fr');

  /// Maintains backwards compatibility for flows expecting “Arabic to …” translation.
  ///
  /// ML Kit auto-detects the source language, so this simply proxies to [translate]
  /// with the provided [targetLang].
  Future<String> translateFromArabicTo(
    String text, {
    required String targetLang,
    String sourceLang = 'auto',
  }) =>
      translate(text, targetLang: targetLang, sourceLang: sourceLang);
}
