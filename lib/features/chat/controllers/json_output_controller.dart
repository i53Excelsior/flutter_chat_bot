import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../models/json_output_model.dart';

class JsonOutputController extends GetxController {
  final RxList<JsonOutputModel> jsonOutputs = <JsonOutputModel>[].obs;

  void addJsonOutput({required String title, required dynamic data}) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final jsonOutput = JsonOutputModel(
      id: id,
      title: title.trim().isNotEmpty ? title.trim() : 'JSON Data Output',
      data: data,
      createdAt: DateTime.now(),
    );

    // Insert at the beginning of the list so the newest is at the top
    jsonOutputs.insert(0, jsonOutput);

    Get.snackbar(
      '📋 JSON Output Captured',
      'Captured "${jsonOutput.title}" in bottom bar JSON tab',
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFF6C63FF),
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(12),
      borderRadius: 12,
      icon: const Icon(Icons.code_rounded, color: Colors.white),
    );
  }

  void deleteJsonOutput(String id) {
    jsonOutputs.removeWhere((item) => item.id == id);
  }

  void copyToClipboard(JsonOutputModel item) {
    try {
      const encoder = JsonEncoder.withIndent('  ');
      final prettyString = encoder.convert(item.data);
      Clipboard.setData(ClipboardData(text: prettyString));

      Get.snackbar(
        '📋 Copied to Clipboard',
        'JSON content copied to clipboard successfully!',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green.shade600,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(12),
        borderRadius: 12,
        icon: const Icon(Icons.check_circle_outline_rounded, color: Colors.white),
      );
    } catch (e) {
      Get.snackbar(
        '⚠️ Copy Failed',
        'Could not format or copy JSON: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
      );
    }
  }
}
