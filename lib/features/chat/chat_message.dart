// lib/features/chat/chat_message.dart
class ChatMessage {
  final String role; // 'user' or 'assistant' or 'system'
  final String text;
  final String? audioPath; // local path to TTS audio if available
  ChatMessage({required this.role, required this.text, this.audioPath});
  bool get isUser => role == 'user';
}
