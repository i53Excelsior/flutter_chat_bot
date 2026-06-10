import 'dart:convert';

import '../models/prompt_evulation.dart';
import '../models/structured_response.dart';
import 'ai_service.dart';

class BotEngine {
  final AiService _aiService = AiService();

  /// Returns a JSON string containing "reply" and an optional "reminder" object.
  Future<String> generatePlainResponse(String input) async {
    final String currentTimeStr = DateTime.now().toLocal().toString();
    final String systemPrompt = '''
You are a helpful AI Assistant that can chat with the user, set reminders, and create files on the system.

The current local date and time is: $currentTimeStr.

IMPORTANT: Return ONLY a valid JSON object.
Do NOT use markdown code blocks like ```json.
Do NOT include any explanations or extra text outside the JSON object.

JSON Schema:
{
  "reply": "Your natural language response to the user. Acknowledge and confirm if you set a reminder or created a file.",
  "reminder": {
    "title": "A short, descriptive title for the reminder",
    "note": "Optional details or note",
    "scheduledAtIso": "ISO 8601 string of when the reminder should fire. Compute this date and time accurately based on the current local time provided."
  },
  "fileCreation": {
    "fileName": "The name of the file to create, e.g. notes.txt",
    "content": "The text content to write inside the file"
  }
}

Rules:
- If the user did NOT request to set a reminder, set the "reminder" field to null.
- If the user did NOT request to create a file, set the "fileCreation" field to null.

User Input:
$input
''';

    final result = await _aiService.askGemini(systemPrompt);
    final String cleanJson = result
        .replaceAll('```json', '')
        .replaceAll('```', '')
        .trim();
    return cleanJson;
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