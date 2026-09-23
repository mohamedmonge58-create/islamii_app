// lib/core/audio_player_manager.dart
import 'package:audioplayers/audioplayers.dart';

class AudioPlayerManager {
  AudioPlayerManager._internal();

  static final AudioPlayerManager instance = AudioPlayerManager._internal();

  final AudioPlayer player = AudioPlayer();

  String? currentId;
  String? currentLabel; // اسم السورة أو أي وصف نعرضه في الكارت

  /// يشغّل عنصر جديد. لو نفس الـ id شغال بالفعل، يعمل toggle بس.
  Future<void> playUrl(String id, String url, {String? label}) async {
    if (currentId == id) {
      await togglePlayPause();
      return;
    }

    currentId = id;
    currentLabel = label;
    await player.stop();
    await player.play(UrlSource(url));
  }

  /// Pause/Resume للعنصر الشغال حاليًا فقط (من غير ما يغيّر currentId)
  Future<void> togglePlayPause() async {
    if (player.state == PlayerState.playing) {
      await player.pause();
    } else {
      await player.resume();
    }
  }

  Future<void> stop() async {
    currentId = null;
    currentLabel = null;
    await player.stop();
  }

  Stream<PlayerState> get onStateChanged => player.onPlayerStateChanged;
}
