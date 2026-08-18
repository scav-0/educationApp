import 'package:audioplayers/audioplayers.dart';

class GameAudio {
  static final AudioPlayer _player = AudioPlayer();

  static Future<void> correct() async {
    await _player.play(
      AssetSource('sounds/right.mp3'),
    );
  }

  static Future<void> incorrect() async {
    await _player.play(
      AssetSource('sounds/wrong.mp3'),
    );
  }
}