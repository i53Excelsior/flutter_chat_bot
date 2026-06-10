import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/chat_message.dart';
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

      // Get the original plain-text response from Gemini
      final String plainResponse =
          await botEngine.generatePlainResponse(text);

      messages.add(
        ChatMessage(
          message: plainResponse,
          isUser: false,
          createdAt: DateTime.now(),
        ),
      );

      debugPrint('Bot replied: $plainResponse');
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