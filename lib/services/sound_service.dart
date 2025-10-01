import 'package:audioplayers/audioplayers.dart';

class SoundService {
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Play notification sound
  Future<void> playNotification() async {
    try {
      await _audioPlayer.play(AssetSource('sounds/notification.mp3'));
    } catch (e) {
      print('Error playing notification: $e');
    }
  }

  // Play sound from asset
  Future<void> playSound(String assetPath) async {
    try {
      await _audioPlayer.play(AssetSource(assetPath));
    } catch (e) {
      print('Error playing sound: $e');
    }
  }

  // Stop sound
  Future<void> stop() async {
    await _audioPlayer.stop();
  }

  // Dispose
  void dispose() {
    _audioPlayer.dispose();
  }
}
