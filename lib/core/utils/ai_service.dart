import 'package:flutter/foundation.dart';

/// Centralizes access to AI-generated answers for OCR workflows.
class AiService {
  AiService._();

  /// Singleton instance exposed to the presentation layer.
  static final AiService instance = AiService._();

  String _responseLanguageCode = 'en';

  /// Updates the language the AI should respond with (ex: "en" / "fr").
  void setResponseLanguage(String code) {
    _responseLanguageCode = code;
  }

  /// Sends [prompt] to the configured AI provider and returns the answer.
  Future<String> askQuestion(String text) async {
    final responseLanguage =
        _responseLanguageCode == 'fr' ? 'French' : 'English';

    final prompt = '''
You are a clear, patient tutor. A learner scanned the following exercise and needs help.
Explain what the exercise is asking, outline the reasoning, and provide a concise solution.
Respond in $responseLanguage.

Exercise text:
$text
''';

    debugPrint('AiService.askQuestion prompt:\n$prompt');

    // Replace this stub with a call to your preferred AI provider.
    return 'Simulated $responseLanguage AI response:\n\n$text';
  }
}
