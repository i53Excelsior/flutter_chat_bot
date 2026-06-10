import 'dart:convert';

import '../models/prompt_evulation.dart';
import '../models/structured_response.dart';
import 'ai_service.dart';

class BotEngine {
  final AiService _aiService = AiService();

  /// Returns the raw Gemini response as plain text (no JSON forcing).
  Future<String> generatePlainResponse(String input) async {
    return await _aiService.askGemini(input);
  }

  Future<StructuredResponse> generateStructuredResponse(
      String input,
      ) async {
    final String systemPrompt = '''
You are an AI Assistant.

Return ONLY valid JSON.

Rules:
- Do NOT use markdown.
- Do NOT wrap JSON in ```json.
- Do NOT add explanations.
- Return valid JSON only.

Format:

{
  "title": "",
  "summary": "",
  "category": "",
  "keywords": []
}

User Input:
$input
''';

    try {
      final result = await _aiService.askGemini(
        systemPrompt,
      );

      print('========================');
      print('RAW GEMINI RESPONSE');
      print(result);
      print('========================');

      final String cleanJson = result
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();

      print('========================');
      print('CLEAN JSON');
      print(cleanJson);
      print('========================');

      final Map<String, dynamic> json =
      jsonDecode(cleanJson);

      return StructuredResponse(
        title: json['title']?.toString() ?? '',
        summary: json['summary']?.toString() ?? '',
        category: json['category']?.toString() ?? '',
        keywords:
        (json['keywords'] as List?)
            ?.map(
              (e) => e.toString(),
        )
            .toList() ??
            [],
      );
    } catch (e, stackTrace) {
      print('========================');
      print('BOT ENGINE ERROR');
      print(e);
      print(stackTrace);
      print('========================');

      return StructuredResponse(
        title: 'Error',
        summary:
        'Failed to generate response.\n\n$e',
        category: 'System',
        keywords: [],
      );
    }
  }

  PromptEvaluation evaluateResponse(
      String prompt,
      StructuredResponse response,
      ) {
    int score = 0;

    final List<String> feedback = [];

    if (response.title.isNotEmpty) {
      score += 2;
      feedback.add(
        '✓ Title generated',
      );
    }

    if (response.summary.isNotEmpty) {
      score += 3;
      feedback.add(
        '✓ Response generated',
      );
    }

    if (response.summary.length > 50) {
      score += 2;
      feedback.add(
        '✓ Detailed response',
      );
    }

    if (response.keywords.isNotEmpty) {
      score += 3;
      feedback.add(
        '✓ Keywords extracted',
      );
    }

    return PromptEvaluation(
      score: score,
      feedback: feedback.join('\n'),
    );
  }
}