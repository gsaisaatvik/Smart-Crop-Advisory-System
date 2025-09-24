// lib/services/sarvam_api.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path_provider/path_provider.dart';

class SarvamApi {
  final String apiKey;
  final bool isDemoMode;

  SarvamApi(this.apiKey) : isDemoMode = apiKey == 'demo_key';

  // Chat completion
  Future<String> chatCompletion(
    List<Map<String, dynamic>> messages, {
    String model = 'sarvam-m',
  }) async {
    if (isDemoMode) {
      // Demo response
      await Future.delayed(const Duration(seconds: 1)); // Simulate API delay
      return "Demo mode: This is a sample response. Please add your Sarvam AI API key to the .env file to use the actual AI features.";
    }

    final uri = Uri.parse('https://api.sarvam.ai/v1/chat/completions');
    final headers = {
      'Content-Type': 'application/json',
      'api-subscription-key': apiKey,
    };
    final body = jsonEncode({'model': model, 'messages': messages});
    final resp = await http.post(uri, headers: headers, body: body);
    if (resp.statusCode == 200) {
      final j = jsonDecode(resp.body);
      final choice = j['choices']?[0];
      return choice != null ? (choice['message']?['content'] ?? '') : '';
    } else {
      throw Exception('Chat API error ${resp.statusCode}: ${resp.body}');
    }
  }

  // Synchronous Speech-to-Text (multipart) - use for short audio (<30s).
  Future<String> transcribeAudio(
    File audioFile, {
    String model = 'saarika:v2.5',
    String? languageCode,
  }) async {
    if (isDemoMode) {
      await Future.delayed(const Duration(seconds: 2)); // Simulate processing
      return "Demo mode: Audio transcription would work here with a valid API key.";
    }

    final uri = Uri.parse('https://api.sarvam.ai/speech-to-text');
    final req = http.MultipartRequest('POST', uri);
    req.headers['api-subscription-key'] = apiKey;
    req.fields['model'] = model;
    if (languageCode != null) req.fields['language_code'] = languageCode;
    // Try to detect audio mime type from file extension
    final ext = audioFile.path.split('.').last.toLowerCase();
    final mimeType = ext == 'wav' ? 'wav' : (ext == 'mp3' ? 'mpeg' : 'wav');
    req.files.add(
      await http.MultipartFile.fromPath(
        'file',
        audioFile.path,
        contentType: MediaType('audio', mimeType),
      ),
    );
    final streamed = await req.send();
    final resp = await http.Response.fromStream(streamed);
    if (resp.statusCode == 200) {
      final j = jsonDecode(resp.body);
      // Sarvam returns `transcript` field for STT results
      return j['transcript'] ?? '';
    } else {
      throw Exception('STT error ${resp.statusCode}: ${resp.body}');
    }
  }

  // Text to Speech (returns saved File)
  Future<File> textToSpeech(
    String text, {
    required String targetLanguageCode,
    String model = 'bulbul:v2',
    String speaker = 'anushka',
  }) async {
    if (isDemoMode) {
      // Skip TTS in demo mode to avoid audio errors
      throw Exception(
        'TTS not available in demo mode. Please add your Sarvam AI API key to enable audio features.',
      );
    }

    final uri = Uri.parse('https://api.sarvam.ai/text-to-speech');
    final headers = {
      'Content-Type': 'application/json',
      'api-subscription-key': apiKey,
    };
    final body = jsonEncode({
      'text': text,
      'target_language_code': targetLanguageCode,
      'model': model,
      'speaker': speaker,
    });
    final resp = await http.post(uri, headers: headers, body: body);
    if (resp.statusCode == 200) {
      final j = jsonDecode(resp.body);
      final audios = j['audios'] as List<dynamic>?;
      if (audios == null || audios.isEmpty) {
        throw Exception('No TTS audio returned');
      }
      final b64 = audios.first as String;
      final bytes = base64Decode(b64);
      final dir = await getTemporaryDirectory();
      final file = File(
        '${dir.path}/sarvam_tts_${DateTime.now().millisecondsSinceEpoch}.wav',
      );
      await file.writeAsBytes(bytes);
      return file;
    } else {
      throw Exception('TTS error ${resp.statusCode}: ${resp.body}');
    }
  }
}
