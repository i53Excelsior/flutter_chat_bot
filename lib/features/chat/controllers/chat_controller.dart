import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/chat_message.dart';
import '../services/bot_engine.dart';
import '../../reminder/controllers/reminder_controller.dart';

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

      // Get the JSON response from Gemini
      final String jsonResponse =
          await botEngine.generatePlainResponse(text);

      String displayReply = jsonResponse;
      Map<String, dynamic>? parsedJson;
      try {
        parsedJson = jsonDecode(jsonResponse) as Map<String, dynamic>;
        displayReply = parsedJson['reply']?.toString() ?? jsonResponse;
      } catch (e) {
        debugPrint('Failed to parse response as JSON: $e. Using raw string.');
      }

      // Add bot reply to chat messages list
      messages.add(
        ChatMessage(
          message: displayReply,
          isUser: false,
          createdAt: DateTime.now(),
        ),
      );

      // Check if a reminder was parsed and need to be scheduled
      if (parsedJson != null && parsedJson['reminder'] != null) {
        final reminderData = parsedJson['reminder'] as Map<String, dynamic>;
        final String title = reminderData['title']?.toString() ?? 'Reminder';
        final String note = reminderData['note']?.toString() ?? '';
        final String? scheduledAtIso = reminderData['scheduledAtIso']?.toString();

        if (scheduledAtIso != null) {
          final DateTime scheduledAt = DateTime.parse(scheduledAtIso);
          
          // Schedule the reminder using ReminderController
          final reminderController = Get.find<ReminderController>();
          reminderController.addReminder(
            title: title,
            note: note,
            scheduledAt: scheduledAt,
          );
        }
      }

      // Check if a file creation was parsed and need to be created
      if (parsedJson != null && parsedJson['fileCreation'] != null) {
        final fileData = parsedJson['fileCreation'] as Map<String, dynamic>;
        final String? fileName = fileData['fileName']?.toString();
        final String content = fileData['content']?.toString() ?? '';

        if (fileName != null && fileName.trim().isNotEmpty) {
          try {
            final File file = File(fileName.trim());
            await file.writeAsString(content);
            
            Get.snackbar(
              '📁 File Created',
              'Successfully created "$fileName"',
              snackPosition: SnackPosition.TOP,
              backgroundColor: Colors.blue.shade600,
              colorText: Colors.white,
              duration: const Duration(seconds: 3),
              margin: const EdgeInsets.all(12),
              borderRadius: 12,
              icon: const Icon(Icons.file_copy_rounded, color: Colors.white),
            );
          } catch (fileErr) {
            debugPrint('Failed to create file: $fileErr');
            Get.snackbar(
              '⚠️ File Creation Failed',
              'Error writing "$fileName": $fileErr',
              snackPosition: SnackPosition.TOP,
              backgroundColor: Colors.red.shade600,
              colorText: Colors.white,
            );
          }
        }
      }

      debugPrint('Bot replied: $displayReply');
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