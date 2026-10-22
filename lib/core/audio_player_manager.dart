import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:audioplayers/audioplayers.dart' as ap;
import 'package:flutter/material.dart';
import 'package:islamii_app/core/quran_audio_handler.dart';

class AudioPlayerManager {
  AudioPlayerManager._internal();

  static final AudioPlayerManager instance = AudioPlayerManager._internal();

  final ap.AudioPlayer _legacyPlayer = ap.AudioPlayer();
  QuranAudioHandler? _handler;
  bool _isInit = false;

  String? currentId;
  String? currentLabel;
  String? currentUrl;

  /// Returns the singleton AudioService Background Handler
  Future<QuranAudioHandler> get audioHandler async {
    if (!_isInit) {
      _handler = await AudioService.init(
        builder: () => QuranAudioHandler(),
        config: const AudioServiceConfig(
          androidNotificationChannelId: 'com.example.islamii_app.channel.audio',
          androidNotificationChannelName: 'القرآن الكريم وإذاعة القرآن',
          androidNotificationOngoing: true,
          androidStopForegroundOnPause: true,
          androidNotificationIcon: 'mipmap/ic_launcher',
          notificationColor: Color(0xFFE2BE7F),
        ),
      );
      _isInit = true;
    }
    return _handler!;
  }

  /// Plays a surah with background media session & notification
  Future<void> playSurah({
    required String reciterId,
    required String reciterName,
    required List<Map<String, dynamic>> surahs,
    required int index,
  }) async {
    await stopLegacyPlayer();
    final handler = await audioHandler;

    currentId = 'reciter_$reciterId';
    currentLabel = surahs[index]['name'];
    currentUrl = surahs[index]['url'];

    await handler.playSurah(
      reciterName: reciterName,
      surahs: surahs,
      index: index,
    );
  }

  /// Plays a general live URL (e.g. Radio)
  Future<void> playUrl(String id, String url, {String? label}) async {
    if (_handler != null) {
      await _handler!.stop();
    }

    if (currentId == id && url.isEmpty) {
      await togglePlayPause();
      return;
    }

    if (currentId == id && url.isNotEmpty && url == currentUrl) {
      await togglePlayPause();
      return;
    }

    if (url.isEmpty) return;

    currentId = id;
    currentLabel = label;
    currentUrl = url;

    await _legacyPlayer.stop();
    await _legacyPlayer.play(ap.UrlSource(url));
  }

  Future<void> togglePlayPause() async {
    if (_handler != null && _handler!.mediaItem.value != null) {
      if (_handler!.playbackState.value.playing) {
        await _handler!.pause();
      } else {
        await _handler!.play();
      }
      return;
    }

    if (_legacyPlayer.state == ap.PlayerState.playing) {
      await _legacyPlayer.pause();
    } else if (_legacyPlayer.state == ap.PlayerState.paused) {
      await _legacyPlayer.resume();
    } else if (currentUrl != null) {
      await _legacyPlayer.play(ap.UrlSource(currentUrl!));
    }
  }

  Future<void> stopLegacyPlayer() async {
    await _legacyPlayer.stop();
  }

  Future<void> stop() async {
    await _legacyPlayer.stop();
    if (_handler != null) {
      await _handler!.stop();
    }
    currentId = null;
    currentLabel = null;
    currentUrl = null;
  }

  ap.AudioPlayer get player => _legacyPlayer;
  ap.AudioPlayer get legacyPlayer => _legacyPlayer;
  Stream<ap.PlayerState> get onStateChanged =>
      _legacyPlayer.onPlayerStateChanged;
  Stream<void> get onPlayerComplete => _legacyPlayer.onPlayerComplete;
}
