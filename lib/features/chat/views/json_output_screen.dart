import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/json_output_controller.dart';
import '../models/json_output_model.dart';

class JsonOutputScreen extends StatelessWidget {
  JsonOutputScreen({super.key});

  final JsonOutputController controller = Get.find<JsonOutputController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📋 JSON Outputs'),
      ),
      body: Obx(() {
        if (controller.jsonOutputs.isEmpty) {
          return _buildEmptyState();
        }
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          itemCount: controller.jsonOutputs.length,
          itemBuilder: (_, index) {
            final item = controller.jsonOutputs[index];
            return _JsonOutputCard(
              item: item,
              onDelete: () => controller.deleteJsonOutput(item.id),
              onCopy: () => controller.copyToClipboard(item),
            );
          },
        );
      }),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: const Color(0xFF6C63FF).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.code_off_rounded,
              size: 72,
              color: Color(0xFF6C63FF),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No JSON Generated Yet',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Ask the AI chatbot for any data in JSON format,\nand it will be parsed and displayed here.',
            style: TextStyle(fontSize: 14, color: Colors.white54),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _JsonOutputCard extends StatefulWidget {
  final JsonOutputModel item;
  final VoidCallback onDelete;
  final VoidCallback onCopy;

  const _JsonOutputCard({
    required this.item,
    required this.onDelete,
    required this.onCopy,
  });

  @override
  State<_JsonOutputCard> createState() => _JsonOutputCardState();
}

class _JsonOutputCardState extends State<_JsonOutputCard> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    const encoder = JsonEncoder.withIndent('  ');
    final String prettyJson = encoder.convert(widget.item.data);

    return Dismissible(
      key: Key(widget.item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.white, size: 28),
      ),
      onDismissed: (_) => widget.onDelete(),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF151521),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6C63FF).withValues(alpha: 0.05),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              leading: Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF6C63FF), Color(0xFF48CAE4)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.code_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              title: Text(
                widget.item.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    const Icon(Icons.schedule_rounded, size: 13, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      _formatDateTime(widget.item.createdAt),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              trailing: IconButton(
                icon: Icon(
                  _isExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
              ),
            ),
            if (_isExpanded) ...[
              const Divider(color: Colors.white12, height: 1),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxHeight: 300),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A0A0E),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Scrollbar(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: JsonSyntaxHighlighter(jsonString: prettyJson),
                      ),
                    ),
                  ),
                ),
              ),
            ],
            const Divider(color: Colors.white12, height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: widget.onCopy,
                    icon: const Icon(Icons.copy_rounded, size: 16, color: Color(0xFF48CAE4)),
                    label: const Text(
                      'Copy JSON',
                      style: TextStyle(color: Color(0xFF48CAE4), fontSize: 13),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () => _showSaveFileDialog(context),
                    icon: const Icon(Icons.save_alt_rounded, size: 16, color: Color(0xFF6C63FF)),
                    label: const Text(
                      'Save to File',
                      style: TextStyle(color: Color(0xFF6C63FF), fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '${dt.day}/${dt.month}/${dt.year}  $h:$m $ampm';
  }

  void _showSaveFileDialog(BuildContext context) {
    final fileNameCtrl = TextEditingController(
      text: '${widget.item.title.toLowerCase().replaceAll(RegExp(r'[^a-z0-9_]'), '_')}.json',
    );

    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF151521),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('📁 Save JSON to File', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Enter the file name to write this JSON content to:', style: TextStyle(color: Colors.white70, fontSize: 14)),
            const SizedBox(height: 16),
            TextField(
              controller: fileNameCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'File Name',
                labelStyle: const TextStyle(color: Color(0xFF6C63FF)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 2),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              final String fileName = fileNameCtrl.text.trim();
              if (fileName.isEmpty) return;

              try {
                const encoder = JsonEncoder.withIndent('  ');
                final String prettyString = encoder.convert(widget.item.data);
                final file = File(fileName);
                await file.writeAsString(prettyString);

                Get.back();
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
              } catch (e) {
                Get.snackbar(
                  '⚠️ File Creation Failed',
                  'Error writing "$fileName": $e',
                  snackPosition: SnackPosition.TOP,
                  backgroundColor: Colors.red.shade600,
                  colorText: Colors.white,
                );
              }
            },
            child: const Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class JsonSyntaxHighlighter extends StatelessWidget {
  final String jsonString;
  const JsonSyntaxHighlighter({super.key, required this.jsonString});

  @override
  Widget build(BuildContext context) {
    final spans = _highlightJson(jsonString);
    return SelectableText.rich(
      TextSpan(
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 13,
          height: 1.4,
        ),
        children: spans,
      ),
    );
  }

  List<TextSpan> _highlightJson(String json) {
    final List<TextSpan> spans = [];
    final RegExp regExp = RegExp(
      r'("(\\u[a-zA-Z0-9]{4}|\\[^u]|[^\\"])*"(?=\s*:))|' // Key (Group 1)
      r'("(\\u[a-zA-Z0-9]{4}|\\[^u]|[^\\"])*")|' // String value (Group 3)
      r'(\b(true|false|null)\b)|' // Boolean/null (Group 5)
      r'(-?\d+(?:\.\d+)?(?:[eE][+\-]?\d+)?)|' // Number (Group 7)
      r'([{}[\]:,])', // Punctuation (Group 8)
      multiLine: true,
    );

    int lastIndex = 0;
    for (final Match match in regExp.allMatches(json)) {
      if (match.start > lastIndex) {
        spans.add(TextSpan(
          text: json.substring(lastIndex, match.start),
          style: const TextStyle(color: Colors.white70),
        ));
      }

      final String text = match.group(0)!;
      if (match.group(1) != null) {
        // Key
        spans.add(TextSpan(
          text: text,
          style: const TextStyle(color: Color(0xFF6C63FF), fontWeight: FontWeight.bold),
        ));
      } else if (match.group(3) != null) {
        // String value
        spans.add(TextSpan(
          text: text,
          style: const TextStyle(color: Color(0xFF48CAE4)),
        ));
      } else if (match.group(5) != null) {
        // Boolean or null
        spans.add(TextSpan(
          text: text,
          style: const TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold),
        ));
      } else if (match.group(7) != null) {
        // Number
        spans.add(TextSpan(
          text: text,
          style: const TextStyle(color: Colors.lightGreenAccent),
        ));
      } else if (match.group(8) != null) {
        // Punctuation
        spans.add(TextSpan(
          text: text,
          style: const TextStyle(color: Colors.white54),
        ));
      }
      lastIndex = match.end;
    }

    if (lastIndex < json.length) {
      spans.add(TextSpan(
        text: json.substring(lastIndex),
        style: const TextStyle(color: Colors.white70),
      ));
    }

    return spans;
  }
}
