import 'package:audioplayers/audioplayers.dart';

class PrayerSoundService {
  PrayerSoundService._();
  static final PrayerSoundService instance = PrayerSoundService._();
  final AudioPlayer _player = AudioPlayer();

  Future<void> playPrayerCompleted() async {
    try {
      await _player.stop();
      await _player.play(AssetSource('sounds/destination_reached.mp3'));
    } catch (_) {
      // Audio is optional; prayer completion must continue if playback fails.
    }
  }
}
