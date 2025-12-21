import 'dart:convert';
import 'package:askcam/core/config/app_runtime_config.dart';
import 'package:askcam/core/config/ai_config.dart';
import 'package:askcam/core/models/ai_result.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class AiService {
  AiService._();

  static final AiService instance = AiService._();

  List<String>? _cachedModels;
  String? _resolvedTextModel;
  String? _resolvedVisionModel;

  String _responseLanguageCode = 'en';

  void setResponseLanguage(String code) {
    _responseLanguageCode = code;
  }

  Future<AiResult> askQuestion(String text) {
    return askText(extractedText: text);
  }

  Future<AiResult> askText({
    required String extractedText,
    String? question,
  }) async {
    if (kDebugMode) {
      debugPrint(
        'AskAI mode: text, textLen=${extractedText.length}, hasQuestion=${(question ?? '').trim().isNotEmpty}',
      );
    }

    final responseLanguage =
        _responseLanguageCode == 'fr' ? 'French' : 'English';
    final prompt = '''
You are a clear, patient tutor. Use the extracted text to answer.
Respond in $responseLanguage.

Extracted text:
$extractedText

${question == null || question.trim().isEmpty ? '' : 'User question: $question'}
''';

    return _callGemini(prompt: prompt, imageBytes: null);
  }

  Future<AiResult> askVision({
    required Uint8List imageBytes,
    String? question,
  }) async {
    if (kDebugMode) {
      debugPrint(
        'AskAI mode: vision, textLen=0, hasQuestion=${(question ?? '').trim().isNotEmpty}',
      );
    }

    final responseLanguage =
        _responseLanguageCode == 'fr' ? 'French' : 'English';
    final prompt = '''
You are a clear, patient assistant.
Respond in $responseLanguage.

${question == null || question.trim().isEmpty ? '' : 'User question: $question'}
''';

    return _callGemini(prompt: prompt, imageBytes: imageBytes);
  }

  Future<AiResult> _callGemini({
    required String prompt,
    required Uint8List? imageBytes,
  }) async {
    if (!AiConfig.hasKey) {
      AppRuntimeConfig.logMissingConfig();
      return AiResult.error(
        'AI is not configured. Please run the app with the API key.',
      );
    }

    if (AiConfig.baseUrl.trim().isEmpty) {
      if (kDebugMode) {
        debugPrint('AI base URL is empty. Set AI_BASE_URL if needed.');
      }
      return AiResult.error(
        'AI base URL is missing. Please configure AI_BASE_URL.',
      );
    }

    final model = await resolveModel(vision: imageBytes != null);
    if (model.trim().isEmpty) {
      if (kDebugMode) {
        debugPrint('AI model is empty. Set AI_MODEL_TEXT/AI_MODEL_VISION.');
      }
      return AiResult.error(
        'AI model is missing. Please configure AI_MODEL_TEXT/AI_MODEL_VISION.',
      );
    }

    final parts = <Map<String, dynamic>>[
      {'text': prompt},
    ];

    if (imageBytes != null) {
      final mimeType = _detectImageMimeType(imageBytes);
      parts.add({
        'inline_data': {
          'mime_type': mimeType,
          'data': base64Encode(imageBytes),
        }
      });
    }

    final payload = {
      'contents': [
        {
          'role': 'user',
          'parts': parts,
        }
      ],
    };

    http.Response response;
    try {
      response = await _postGenerateContent(model: model, payload: payload);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('AI network error: $e');
        debugPrintStack(stackTrace: stackTrace);
      }
      return AiResult.error('AI network error. Please try again later.');
    }

    if (_isModelNotFound(response)) {
      final retryModel = await resolveModel(
        vision: imageBytes != null,
        forceRefresh: true,
        avoidModel: model,
      );
      if (retryModel.trim().isNotEmpty && retryModel != model) {
        try {
          if (kDebugMode) {
            debugPrint(
              'Gemini 404, retrying with model: $retryModel (previous: $model)',
            );
          }
          response = await _postGenerateContent(
            model: retryModel,
            payload: payload,
          );
        } catch (e, stackTrace) {
          if (kDebugMode) {
            debugPrint('AI network error on fallback: $e');
            debugPrintStack(stackTrace: stackTrace);
          }
          return AiResult.error('AI network error. Please try again later.');
        }
      }
    }

    if (response.statusCode != 200) {
      if (kDebugMode) {
        debugPrint(
          'AI request failed: ${response.statusCode} ${response.body}',
        );
      }
      final errorSuffix = kDebugMode ? ' ${response.body}' : '';
      return AiResult.error(
        'AI request failed (${response.statusCode}).$errorSuffix',
      );
    }

    try {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final candidates = data['candidates'] as List<dynamic>?;
      final content = candidates != null && candidates.isNotEmpty
          ? candidates.first['content'] as Map<String, dynamic>?
          : null;
      final partsOut = content?['parts'] as List<dynamic>?;
      final text = partsOut != null && partsOut.isNotEmpty
          ? partsOut.first['text'] as String?
          : null;
      final cleaned = text?.trim() ?? '';
      if (cleaned.isEmpty) {
        return AiResult.error('AI did not return an answer.');
      }
      return AiResult.success(cleaned);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('AI response parse error: $e');
        debugPrintStack(stackTrace: stackTrace);
      }
      return AiResult.error('AI response parsing failed.');
    }
  }

  Future<http.Response> _postGenerateContent({
    required String model,
    required Map<String, dynamic> payload,
  }) async {
    final uri = AiConfig.buildGeminiUri(model);
    if (kDebugMode) {
      debugPrint('Gemini model: $model');
      debugPrint('Gemini URL: $uri');
    }
    return http.post(
      uri,
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
    );
  }

  Future<List<String>> listModels({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedModels != null && _cachedModels!.isNotEmpty) {
      return _cachedModels!;
    }

    if (!AiConfig.hasKey || AiConfig.baseUrl.trim().isEmpty) {
      return [];
    }

    final uri = AiConfig.buildGeminiModelsUri();
    try {
      final response = await http.get(uri);
      if (kDebugMode) {
        debugPrint('Gemini ListModels URL: $uri');
        debugPrint('Gemini ListModels response: ${response.body}');
      }
      if (response.statusCode != 200) {
        return [];
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final models = data['models'] as List<dynamic>? ?? [];
      final names = <String>[];
      for (final item in models) {
        final map = item as Map<String, dynamic>;
        final supported =
            (map['supportedGenerationMethods'] as List<dynamic>?)
                ?.map((value) => value.toString())
                .toList();
        if (supported == null || !supported.contains('generateContent')) {
          continue;
        }
        final name = map['name']?.toString() ?? '';
        if (name.isEmpty) continue;
        names.add(_normalizeModelName(name));
      }
      _cachedModels = names;
      return names;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('Gemini ListModels error: $e');
        debugPrintStack(stackTrace: stackTrace);
      }
      return [];
    }
  }

  Future<String> resolveModel({
    required bool vision,
    bool forceRefresh = false,
    String? avoidModel,
  }) async {
    final cached = vision ? _resolvedVisionModel : _resolvedTextModel;
    final normalizedAvoid = _normalizeModelName(avoidModel ?? '');
    if (!forceRefresh &&
        cached != null &&
        cached.trim().isNotEmpty &&
        cached != normalizedAvoid) {
      return cached;
    }

    final models = await listModels(forceRefresh: forceRefresh);
    final preferred = _normalizeModelName(
      vision ? AiConfig.visionModel : AiConfig.textModel,
    );
    final picked = _pickModel(
      models,
      vision: vision,
      preferred: preferred,
      avoidModel: normalizedAvoid,
    );

    final resolved = picked ?? preferred;
    if (vision) {
      _resolvedVisionModel = resolved.isEmpty ? null : resolved;
    } else {
      _resolvedTextModel = resolved.isEmpty ? null : resolved;
    }
    return resolved;
  }

  String? _pickModel(
    List<String> models, {
    required bool vision,
    required String preferred,
    required String avoidModel,
  }) {
    final candidates = models
        .map(_normalizeModelName)
        .where((name) => name.isNotEmpty && name != avoidModel)
        .toList();
    if (candidates.isEmpty) return null;
    if (preferred.isNotEmpty && candidates.contains(preferred)) {
      return preferred;
    }

    final priorities = vision
        ? ['1.5-flash', 'flash', '1.5-pro', 'pro', 'vision']
        : ['1.5-flash', 'flash', '1.5-pro', 'pro'];
    for (final token in priorities) {
      final match = candidates.firstWhere(
        (name) => name.toLowerCase().contains(token),
        orElse: () => '',
      );
      if (match.isNotEmpty) {
        return match;
      }
    }
    return candidates.first;
  }

  bool _isModelNotFound(http.Response response) {
    if (response.statusCode != 404) return false;
    try {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final error = data['error'] as Map<String, dynamic>?;
      final status = error?['status']?.toString() ?? '';
      if (status == 'NOT_FOUND') return true;
      final message = (error?['message']?.toString() ?? '').toLowerCase();
      return message.contains('not found') ||
          message.contains('not supported for generatecontent');
    } catch (_) {
      return true;
    }
  }

  String _normalizeModelName(String name) {
    return name.trim().replaceFirst('models/', '');
  }

  String _detectImageMimeType(Uint8List bytes) {
    if (bytes.length >= 4 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47) {
      return 'image/png';
    }
    if (bytes.length >= 3 &&
        bytes[0] == 0xFF &&
        bytes[1] == 0xD8 &&
        bytes[2] == 0xFF) {
      return 'image/jpeg';
    }
    return 'image/jpeg';
  }
}
