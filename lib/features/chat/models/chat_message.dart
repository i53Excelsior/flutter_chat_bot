import 'structured_response.dart';

class ChatMessage {
  final String message;
  final bool isUser;
  final DateTime createdAt;
  final StructuredResponse? structuredResponse;
  final String? createdFileName;

  ChatMessage({
    required this.message,
    required this.isUser,
    required this.createdAt,
    this.structuredResponse,
    this.createdFileName,
  });
}