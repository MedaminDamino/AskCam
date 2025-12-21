class AiConfig {
  static const String apiKey = String.fromEnvironment('AI_API_KEY');
  static const String baseUrl = String.fromEnvironment(
    'AI_BASE_URL',
    defaultValue: 'https://generativelanguage.googleapis.com/v1beta',
  );
  static const String textModel = String.fromEnvironment(
    'AI_MODEL_TEXT',
    defaultValue: 'gemini-1.5-flash',
  );
  static const String visionModel = String.fromEnvironment(
    'AI_MODEL_VISION',
    defaultValue: 'gemini-1.5-flash',
  );

  static bool get hasKey => apiKey.trim().isNotEmpty;

  static Uri buildGeminiUri(String model, {String? key}) {
    final trimmedBase = baseUrl.trim().replaceAll(RegExp(r'\/+$'), '');
    final apiKeyValue = (key ?? apiKey).trim();
    return Uri.parse(
      '$trimmedBase/models/$model:generateContent?key=$apiKeyValue',
    );
  }

  static Uri buildGeminiModelsUri({String? key}) {
    final trimmedBase = baseUrl.trim().replaceAll(RegExp(r'\/+$'), '');
    final apiKeyValue = (key ?? apiKey).trim();
    return Uri.parse('$trimmedBase/models?key=$apiKeyValue');
  }
}
