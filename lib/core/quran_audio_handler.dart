import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

class QuranAudioHandler extends BaseAudioHandler with SeekHandler {
  final AudioPlayer _player = AudioPlayer();

  String? _reciterName;
  List<Map<String, dynamic>> _availableSurahs = [];
  int _currentIndex = 0;

  QuranAudioHandler() {
    _init();
  }

  void _init() {
    // Listen to player state changes and update AudioService PlaybackState
    _player.playerStateStream.listen((playerState) {
      final isPlaying = playerState.playing;
      final processingState = playerState.processingState;

      playbackState.add(
        PlaybackState(
          controls: [
            MediaControl.skipToPrevious,
            isPlaying ? MediaControl.pause : MediaControl.play,
            MediaControl.skipToNext,
          ],
          systemActions: const {
            MediaAction.seek,
            MediaAction.seekForward,
            MediaAction.seekBackward,
          },
          androidCompactActionIndices: const [0, 1, 2],
          processingState: _mapProcessingState(processingState),
          playing: isPlaying,
          updatePosition: _player.position,
          bufferedPosition: _player.bufferedPosition,
          speed: _player.speed,
          queueIndex: _currentIndex,
        ),
      );

      // Auto-advance to next surah on track completion
      if (processingState == ProcessingState.completed) {
        skipToNext();
      }
    });

    // Listen to duration changes and update MediaItem
    _player.durationStream.listen((duration) {
      if (mediaItem.value != null && duration != null) {
        mediaItem.add(mediaItem.value!.copyWith(duration: duration));
      }
    });

    // Listen to position changes for live UI updates
    _player.positionStream.listen((position) {
      final currentItem = mediaItem.value;
      if (currentItem != null) {
        playbackState.add(
          playbackState.value.copyWith(updatePosition: position),
        );
      }
    });
  }

  AudioProcessingState _mapProcessingState(ProcessingState state) {
    switch (state) {
      case ProcessingState.idle:
        return AudioProcessingState.idle;
      case ProcessingState.loading:
        return AudioProcessingState.loading;
      case ProcessingState.buffering:
        return AudioProcessingState.buffering;
      case ProcessingState.ready:
        return AudioProcessingState.ready;
      case ProcessingState.completed:
        return AudioProcessingState.completed;
    }
  }

  /// Volume getters and setters
  double get volume => _player.volume;
  Stream<double> get volumeStream => _player.volumeStream;

  Future<void> setVolume(double val) async {
    await _player.setVolume(val.clamp(0.0, 1.0));
  }

  /// Sets playlist & metadata for a reciter and starts playback at [surahIndex]
  Future<void> playSurah({
    required String reciterName,
    required List<Map<String, dynamic>> surahs,
    required int index,
  }) async {
    _reciterName = reciterName;
    _availableSurahs = surahs;
    _currentIndex = index.clamp(0, _availableSurahs.length - 1);

    await _playCurrentSurah();
  }

  Future<void> _playCurrentSurah() async {
    if (_availableSurahs.isEmpty ||
        _currentIndex < 0 ||
        _currentIndex >= _availableSurahs.length) {
      return;
    }

    final surah = _availableSurahs[_currentIndex];
    final String url = surah['url'] as String;
    final String surahName = surah['name'] as String;

    final item = MediaItem(
      id: url,
      album: 'القرآن الكريم',
      title: 'سورة $surahName',
      artist: _reciterName ?? 'القارئ',
      artUri: Uri.parse('asset:///assets/images/mosque_radio.png'),
    );

    mediaItem.add(item);

    try {
      await _player.stop();
      await _player.setUrl(url);
      await _player.play();
    } catch (e) {
      debugPrint('Error playing surah URL ($url): $e');
    }
  }

  @override
  Future<void> play() async {
    await _player.play();
  }

  @override
  Future<void> pause() async {
    await _player.pause();
  }

  @override
  Future<void> stop() async {
    await _player.stop();
    await super.stop();
  }

  @override
  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  @override
  Future<void> skipToNext() async {
    if (_currentIndex < _availableSurahs.length - 1) {
      _currentIndex++;
      await _playCurrentSurah();
    } else {
      await stop();
    }
  }

  @override
  Future<void> skipToPrevious() async {
    if (_currentIndex > 0) {
      _currentIndex--;
      await _playCurrentSurah();
    } else {
      await _player.seek(Duration.zero);
    }
  }

  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  AudioPlayer get internalPlayer => _player;
  String? get currentReciterName => _reciterName;
  int get currentSurahIndex => _currentIndex;
  List<Map<String, dynamic>> get currentSurahsList => _availableSurahs;
}
