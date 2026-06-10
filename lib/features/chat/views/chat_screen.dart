import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:get/get.dart';
import '../controllers/chat_controller.dart';

class ChatScreen extends StatelessWidget {
  ChatScreen({super.key});

  final ChatController controller = Get.put(ChatController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Chatbot'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Obx(
                () => ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  itemCount: controller.messages.length,
                  itemBuilder: (_, index) {
                    final msg = controller.messages[index];

                    return Align(
                      alignment: msg.isUser
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.82,
                        ),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: msg.isUser
                              ? const Color(0xFF6C63FF)
                              : const Color(0xFF1E1E2C),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: msg.isUser
                            ? Text(
                                msg.message,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14.5,
                                ),
                              )
                            : MarkdownBody(
                                data: msg.message,
                                styleSheet: MarkdownStyleSheet(
                                  p: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14.5,
                                    height: 1.4,
                                  ),
                                  code: const TextStyle(
                                    backgroundColor: Color(0xFF2D2D3D),
                                    color: Color(0xFF48CAE4),
                                    fontFamily: 'monospace',
                                    fontSize: 13,
                                  ),
                                  codeblockPadding: const EdgeInsets.all(8),
                                  codeblockDecoration: BoxDecoration(
                                    color: const Color(0xFF2D2D3D),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  listBullet: const TextStyle(
                                    color: Color(0xFF48CAE4),
                                  ),
                                ),
                              ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Loading indicator
            Obx(
              () => controller.isLoading.value
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          SizedBox(width: 16),
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF6C63FF),
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'AI is thinking...',
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),

            // Input bar
            Container(
              margin: const EdgeInsets.only(bottom: 12, top: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E2C),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: const Color(0xFF6C63FF).withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller.textController,
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                      decoration: const InputDecoration(
                        hintText: 'Ask AI or set a reminder...',
                        hintStyle: TextStyle(color: Colors.white38),
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16),
                      ),
                      onSubmitted: (_) => controller.sendMessage(),
                    ),
                  ),
                  Obx(
                    () => IconButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : controller.sendMessage,
                      icon: const Icon(
                        Icons.send_rounded,
                        color: Color(0xFF6C63FF),
                      ),
                    ),
                  ),
                ],
              ).paddingSymmetric(horizontal: 6, vertical: 4),
            ),
          ],
        ).paddingSymmetric(horizontal: 16),
      ),
    );
  }
}