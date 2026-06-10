import 'package:flutter/material.dart';
import 'package:flutter_chat_bot/features/chat/models/prompt_evulation.dart';
import 'package:get/get.dart';

import '../models/chat_message.dart';
import '../models/structured_response.dart';
import '../services/bot_engine.dart';

class ChatController extends GetxController {
  final BotEngine botEngine = BotEngine();

  final TextEditingController textController =
  TextEditingController();

  RxList<ChatMessage> messages =
      <ChatMessage>[].obs;

  RxString lastEvaluation = ''.obs;

  RxBool isLoading = false.obs;

  Future<void> sendMessage() async {
    final text = textController.text.trim();

    if (text.isEmpty) return;

    messages.add(
      ChatMessage(
        message: text,
        isUser: true,
        createdAt: DateTime.now(),
      ),
    );

    textController.clear();

    isLoading.value = true;

    try {
      await Future.delayed(
        const Duration(milliseconds: 500),
      );

      final StructuredResponse response =
      await botEngine
          .generateStructuredResponse(
        text,
      );

      final PromptEvaluation evaluation =
      botEngine.evaluateResponse(
        text,
        response,
      );

      lastEvaluation.value = '''
Score: ${evaluation.score}/10

${evaluation.feedback}
''';

      messages.add(
        ChatMessage(
          message: response.summary,
          isUser: false,
          createdAt: DateTime.now(),
          structuredResponse: response,
        ),
      );

      debugPrint(
        'Evaluation Score: ${evaluation.score}',
      );

      debugPrint(
        evaluation.feedback,
      );
    } catch (e) {
      messages.add(
        ChatMessage(
          message:
          'Something went wrong.\n$e',
          isUser: false,
          createdAt: DateTime.now(),
        ),
      );
    } finally {
      isLoading.value = false;
    }
  }
}