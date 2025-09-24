// lib/features/chat/chat_provider.dart
import 'dart:io';
import 'dart:async';
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

  // Recording timer
  Timer? _maxTimer;
  static const Duration _maxRecordingTime = Duration(
    seconds: 30,
  ); // Max 30s recording

  ChatProvider(String apiKey) : api = SarvamApi(apiKey);

  /// Truncate response to 1-2 sentences for farmer-friendly brevity
  String _truncateResponse(String text) {
    // Remove extra whitespace and normalize
    text = text.trim();

    // Find first 1-2 sentences
    final sentences = text.split(RegExp(r'[.!?]+'));
    if (sentences.length >= 2) {
      // Take first 2 sentences
      final firstTwo = sentences.take(2).join('.');
      return firstTwo.endsWith('.') ? firstTwo : '$firstTwo.';
    } else if (sentences.length == 1) {
      // Single sentence - limit to ~40 words
      final words = text.split(' ');
      if (words.length > 40) {
        return '${words.take(40).join(' ')}...';
      }
      return text.endsWith('.') ? text : '$text.';
    }

    // Fallback: limit by characters if no clear sentences
    if (text.length > 200) {
      return '${text.substring(0, 200)}...';
    }

    return text;
  }

  Future<void> sendText(String text) async {
    if (text.trim().isEmpty) return;
    messages.insert(0, ChatMessage(role: 'user', text: text));
    isProcessing = true;
    notifyListeners();

    try {
      // system prompt for concise farmer-friendly responses
      final system = {
        'role': 'system',
        'content':
            'You are an agricultural assistant for small farmers. Respond in the SAME language as the user. Keep the answer concise: ONE short paragraph (1–2 short sentences). Use simple words suitable for small and marginal farmers. Max ~40 words. Give at most one clear actionable step. Do NOT use lists or long explanations.',
      };
      final userMsg = {'role': 'user', 'content': text};

      final resp = await api.chatCompletion([system, userMsg]);

      // Truncate response for farmer-friendly brevity
      final truncatedResp = _truncateResponse(resp);

      // add assistant message
      messages.insert(0, ChatMessage(role: 'assistant', text: truncatedResp));
      notifyListeners();

      // Generate TTS + play (skip in demo mode)
      try {
        final ttsFile = await api.textToSpeech(
          truncatedResp, // Use truncated response for TTS
          targetLanguageCode: selectedLanguage,
        );

        // update last assistant message with audio path
        messages[0] = ChatMessage(
          role: 'assistant',
          text: truncatedResp,
          audioPath: ttsFile.path,
        );
        notifyListeners();

        await _player.play(DeviceFileSource(ttsFile.path));
      } catch (e) {
        // TTS failed (likely demo mode), just update message without audio
        messages[0] = ChatMessage(role: 'assistant', text: truncatedResp);
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

  // Start recording with 30s max timer
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

      // Start 30-second maximum timer
      _maxTimer = Timer(_maxRecordingTime, () {
        if (isRecording) {
          _stopRecordingAndTranscribe();
        }
      });
    } else {
      throw Exception('No microphone permission');
    }
  }

  // Stop recording + send transcript
  Future<void> stopRecordingAndTranscribe() async {
    await _stopRecordingAndTranscribe();
  }

  // Internal method to stop recording and transcribe
  Future<void> _stopRecordingAndTranscribe() async {
    if (!isRecording) return;

    // Cancel timer
    _maxTimer?.cancel();
    _maxTimer = null;

    final path = await _recorder.stop();
    isRecording = false;
    notifyListeners();

    if (path == null) return;

    final file = File(path);
    isProcessing = true;
    notifyListeners();

    try {
      final transcript = await api.transcribeAudio(
        file,
        model: 'saarika:v2.5',
        languageCode: selectedLanguage,
      );

      if (transcript.trim().isNotEmpty) {
        await sendText(transcript);
      } else {
        messages.insert(
          0,
          ChatMessage(
            role: 'assistant',
            text: 'No speech detected. Please try again.',
          ),
        );
        notifyListeners();
      }
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

  @override
  void dispose() {
    _maxTimer?.cancel();
    _recorder.dispose();
    _player.dispose();
    super.dispose();
  }
}
