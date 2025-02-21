import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';

class Audio extends Component {
  AudioPlayer? player;
  bool isPlaying = false;
  late String sound;

  Audio(this.sound);

  @override
  Future<void> onLoad() async {
    super.onLoad();
    FlameAudio.audioCache.clear('jump.mp3'); // clear cache
    await FlameAudio.audioCache.load(sound);
  }

  // play sound once
  void playSound() async {
    FlameAudio.audioCache.load(sound); // reload

    if (!isPlaying) {
      isPlaying = true;

      // stop previous sound if it's playing
      await player?.stop();
      await player?.dispose();
      player = null;

      // play
      player = await FlameAudio.play(sound, volume: 1);
      player!.onPlayerComplete.listen((_) {
        isPlaying = false;
        player?.dispose(); // ensure resources are cleaned up
        player = null;
      });
      isPlaying = false;
    }
  }

  // stop sound
  void stopSound() async {
    await player?.stop();
    await player?.dispose();
    player = null;
    isPlaying = false;
  }
}
