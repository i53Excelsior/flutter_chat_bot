import 'package:flutter/material.dart';
import 'package:flutter_chat_bot/features/chat/widgets/stuctured_response_card.dart';
import 'package:get/get.dart';
import '../controllers/chat_controller.dart';

class ChatScreen extends StatelessWidget {
  ChatScreen({super.key});

  final ChatController controller =
  Get.put(ChatController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Offline AI Chatbot',
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Obx(
                    () => ListView.builder(
                  padding:
                  const EdgeInsets.symmetric(
                    vertical: 10,
                  ),
                  itemCount:
                  controller.messages.length,
                  itemBuilder: (_, index) {
                    final msg =
                    controller.messages[index];

                    return Align(
                      alignment:
                      msg.isUser
                          ? Alignment
                          .centerRight
                          : Alignment
                          .centerLeft,
                      child: Container(
                        margin:
                        const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        constraints: BoxConstraints(
                          maxWidth:
                          MediaQuery.of(context).size.width * 0.8,
                        ),
                        child:
                        !msg.isUser &&
                            msg.structuredResponse != null
                            ? StructuredResponseCard(
                          response: msg.structuredResponse!,
                        )
                            : Container(
                          padding:
                          const EdgeInsets.all(
                            12,
                          ),
                          decoration:
                          BoxDecoration(
                            color:
                            msg.isUser
                                ? Colors
                                .blue
                                : Colors
                                .grey
                                .shade300,
                            borderRadius:
                            BorderRadius.circular(
                              12,
                            ),
                          ),
                          child: Text(
                            msg.message,
                            style:
                            TextStyle(
                              color:
                              msg.isUser
                                  ? Colors
                                  .white
                                  : Colors
                                  .black,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            Container(
              margin:
              const EdgeInsets.only(
                bottom: 10,
              ),
              decoration: BoxDecoration(
                borderRadius:
                BorderRadius.circular(
                  20,
                ),
                border: Border.all(
                  color: Colors.black12,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller:
                      controller
                          .textController,
                      decoration:
                      const InputDecoration(
                        hintText:
                        'Type a message...',
                        border:
                        InputBorder.none,
                        contentPadding:
                        EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                      ),
                      onSubmitted:
                          (_) =>
                          controller
                              .sendMessage(),
                    ),
                  ),
                  IconButton(
                    onPressed:
                    controller
                        .sendMessage,
                    icon: const Icon(
                      Icons.send,
                    ),
                  ),
                ],
              ).paddingSymmetric(
                horizontal: 10,
                vertical: 6,
              ),
            ),
          ],
        ).paddingSymmetric(
          horizontal: 16,
        ),
      ),
    );
  }
}