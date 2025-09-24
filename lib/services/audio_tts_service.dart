import 'package:audioplayers/audioplayers.dart';

class AudioTtsService {
  final AudioPlayer _player = AudioPlayer();

  Future<void> playFromUrl(String url) async {
    await _player.play(UrlSource(url));
  }

  Future<void> stop() async {
    await _player.stop();
  }

  void dispose() {
    _player.dispose();
  }
}
