// lib/features/chat/chat_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'chat_provider.dart';
import 'chat_message.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _ctrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ChatProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sarvam Multilingual Chatbot'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.language),
            initialValue: provider.selectedLanguage,
            onSelected: (v) {
              provider.setLanguage(v);
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'en-IN', child: Text('English (en-IN)')),
              PopupMenuItem(value: 'hi-IN', child: Text('Hindi (hi-IN)')),
              PopupMenuItem(value: 'te-IN', child: Text('Telugu (te-IN)')),
              PopupMenuItem(value: 'ta-IN', child: Text('Tamil (ta-IN)')),
              PopupMenuItem(value: 'kn-IN', child: Text('Kannada (kn-IN)')),
              PopupMenuItem(value: 'ml-IN', child: Text('Malayalam (ml-IN)')),
              PopupMenuItem(value: 'mr-IN', child: Text('Marathi (mr-IN)')),
              PopupMenuItem(value: 'gu-IN', child: Text('Gujarati (gu-IN)')),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: () => provider.clear(),
            tooltip: 'Clear chat',
          ),
        ],
      ),
      body: Column(
        children: [
          if (provider.isProcessing)
            const LinearProgressIndicator(minHeight: 2),
          Expanded(
            child: provider.messages.isEmpty
                ? const Center(child: Text('Say hi — tap mic or type below'))
                : ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.all(12),
                    itemCount: provider.messages.length,
                    itemBuilder: (ctx, i) {
                      final ChatMessage m = provider.messages[i];
                      return Align(
                        alignment: m.isUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Card(
                          color: m.isUser
                              ? Colors.blue.shade100
                              : Colors.grey.shade100,
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(m.text),
                                if (m.audioPath != null)
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.play_arrow),
                                        onPressed: () =>
                                            provider.playAudio(m.audioPath!),
                                      ),
                                      const Text('Play audio'),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6),
              child: Row(
                children: [
                  IconButton(
                    icon: provider.isRecording
                        ? const Icon(Icons.mic_off)
                        : const Icon(Icons.mic),
                    onPressed: () async {
                      try {
                        if (!provider.isRecording) {
                          await provider.startRecording();
                        } else {
                          await provider.stopRecordingAndTranscribe();
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Recorder error: $e')),
                        );
                      }
                    },
                  ),
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (v) {
                        provider.sendText(v);
                        _ctrl.clear();
                      },
                      decoration: const InputDecoration(
                        hintText: 'Type your message here...',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () {
                      final txt = _ctrl.text.trim();
                      if (txt.isNotEmpty) {
                        provider.sendText(txt);
                        _ctrl.clear();
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }
}
