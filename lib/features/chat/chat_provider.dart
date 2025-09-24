// lib/features/chat/chat_provider.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../services/sarvam_api.dart';
import 'chat_message.dart';

class ChatProvider extends ChangeNotifier {
  final SarvamApi api;
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();

  List<ChatMessage> messages = [];
  bool isRecording = false;
  bool isProcessing = false;
  String selectedLanguage = 'en-IN'; // default (BCP-47)

  ChatProvider(String apiKey) : api = SarvamApi(apiKey);

  Future<void> sendText(String text) async {
    if (text.trim().isEmpty) return;
    messages.insert(0, ChatMessage(role: 'user', text: text));
    isProcessing = true;
    notifyListeners();

    try {
      // system prompt to maintain language consistency
      final system = {
        'role': 'system',
        'content':
            'Respond in the same language as the user. If user language is $selectedLanguage, reply in that language.',
      };
      final userMsg = {'role': 'user', 'content': text};

      final resp = await api.chatCompletion([system, userMsg]);

      // add assistant message
      messages.insert(0, ChatMessage(role: 'assistant', text: resp));
      notifyListeners();

      // Generate TTS + play (skip in demo mode)
      try {
        final ttsFile = await api.textToSpeech(
          resp,
          targetLanguageCode: selectedLanguage,
        );

        // update last assistant message with audio path
        messages[0] = ChatMessage(
          role: 'assistant',
          text: resp,
          audioPath: ttsFile.path,
        );
        notifyListeners();

        await _player.play(DeviceFileSource(ttsFile.path));
      } catch (e) {
        // TTS failed (likely demo mode), just update message without audio
        messages[0] = ChatMessage(role: 'assistant', text: resp);
        notifyListeners();
      }
    } catch (e) {
      messages.insert(0, ChatMessage(role: 'assistant', text: 'Error: $e'));
      notifyListeners();
    } finally {
      isProcessing = false;
      notifyListeners();
    }
  }

  // Start recording with record 5.x
  Future<void> startRecording() async {
    if (await _recorder.hasPermission()) {
      final dir = await Directory.systemTemp.createTemp();
      final path =
          '${dir.path}/record_${DateTime.now().millisecondsSinceEpoch}.wav';

      await _recorder.start(
        const RecordConfig(encoder: AudioEncoder.wav),
        path: path,
      );

      isRecording = true;
      notifyListeners();
    } else {
      throw Exception('No microphone permission');
    }
  }

  // Stop recording + send transcript
  Future<void> stopRecordingAndTranscribe() async {
    final path = await _recorder.stop();
    isRecording = false;
    notifyListeners();

    if (path == null) return; // ✅ null safety

    final file = File(path);
    isProcessing = true;
    notifyListeners();

    try {
      final transcript = await api.transcribeAudio(
        file,
        model: 'saarika:v2.5',
        languageCode: selectedLanguage,
      );

      await sendText(transcript);
    } catch (e) {
      messages.insert(0, ChatMessage(role: 'assistant', text: 'STT error: $e'));
      notifyListeners();
    } finally {
      isProcessing = false;
      notifyListeners();
    }
  }

  Future<void> playAudio(String path) async {
    await _player.play(DeviceFileSource(path));
  }

  void setLanguage(String language) {
    selectedLanguage = language;
    notifyListeners();
  }

  void clear() {
    messages.clear();
    notifyListeners();
  }
}
