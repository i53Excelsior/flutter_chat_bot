import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FileViewerScreen extends StatefulWidget {
  final String fileName;
  final String content;

  const FileViewerScreen({
    super.key,
    required this.fileName,
    required this.content,
  });

  @override
  State<FileViewerScreen> createState() => _FileViewerScreenState();
}

class _FileViewerScreenState extends State<FileViewerScreen> {
  late final TextEditingController _textController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.content);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _saveFile() async {
    setState(() {
      _isSaving = true;
    });

    try {
      final file = File(widget.fileName);
      await file.writeAsString(_textController.text);

      Get.snackbar(
        '💾 File Saved',
        'Successfully updated "${widget.fileName}"',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green.shade600,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(12),
        borderRadius: 12,
        icon: const Icon(Icons.check_circle_outline_rounded, color: Colors.white),
      );
    } catch (e) {
      Get.snackbar(
        '⚠️ Save Failed',
        'Could not write to "${widget.fileName}": $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0E),
      appBar: AppBar(
        title: Text(
          widget.fileName,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            )
          else
            IconButton(
              onPressed: _saveFile,
              tooltip: 'Save changes',
              icon: const Icon(
                Icons.save_rounded,
                color: Color(0xFF48CAE4),
              ),
            ),
        ],
      ),
      body: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF151521),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF6C63FF).withValues(alpha: 0.15),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: TextField(
            controller: _textController,
            maxLines: null,
            keyboardType: TextInputType.multiline,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 14,
              color: Colors.white,
            ),
            decoration: const InputDecoration(
              hintText: 'Enter text here...',
              hintStyle: TextStyle(color: Colors.white30),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(18),
            ),
          ),
        ),
      ),
    );
  }
}
