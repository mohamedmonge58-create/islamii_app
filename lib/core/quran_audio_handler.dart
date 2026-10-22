import 'dart:async';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

class QuranAudioHandler extends BaseAudioHandler with SeekHandler {
  final AudioPlayer _player = AudioPlayer();

  bool _isRadio = false;
  bool _isStopped = true;

  String? _reciterName;
  List<Map<String, dynamic>> _availableSurahs = [];
  int _currentIndex = 0;

  QuranAudioHandler() {
    _init();
  }

  Future<Uri?> _getArtworkUri() async {
    try {
      final byteData = await rootBundle.load('assets/images/unnamed.png');

      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/quran_cover.png');

      await file.writeAsBytes(
        byteData.buffer.asUint8List(
          byteData.offsetInBytes,
          byteData.lengthInBytes,
        ),
        flush: true,
      );

      return file.uri;
    } catch (e) {
      debugPrint('Failed to load audio artwork: $e');
      return null;
    }
  }

  void _init() {
    _player.playerStateStream.listen((playerState) {
      final isPlaying = playerState.playing;
      final processingState = playerState.processingState;

      final controls = _isRadio
          ? <MediaControl>[
              if (isPlaying) MediaControl.pause else MediaControl.play,
            ]
          : <MediaControl>[
              MediaControl.skipToPrevious,
              if (isPlaying) MediaControl.pause else MediaControl.play,
              MediaControl.skipToNext,
            ];

      playbackState.add(
        PlaybackState(
          controls: controls,
          androidCompactActionIndices: _isRadio ? const [0] : const [0, 1, 2],
          systemActions: _isRadio
              ? const {}
              : const {
                  MediaAction.seek,
                  MediaAction.seekForward,
                  MediaAction.seekBackward,
                },
          processingState: _mapProcessingState(processingState),
          playing: isPlaying,
          updatePosition: _player.position,
          bufferedPosition: _player.bufferedPosition,
          speed: _player.speed,
          queueIndex: _currentIndex,
        ),
      );

      if (!_isRadio && processingState == ProcessingState.completed) {
        unawaited(skipToNext());
      }
    });

    _player.durationStream.listen((duration) {
      final currentItem = mediaItem.value;

      if (currentItem != null && duration != null && !_isRadio) {
        mediaItem.add(currentItem.copyWith(duration: duration));
      }
    });

    _player.positionStream.listen((position) {
      if (mediaItem.value != null) {
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

  // Volume
  double get volume => _player.volume;

  Stream<double> get volumeStream => _player.volumeStream;

  Future<void> setVolume(double value) async {
    await _player.setVolume(value.clamp(0.0, 1.0).toDouble());
  }

  // Quran Radio
  Future<void> playRadio({
    required String stationName,
    required String url,
  }) async {
    if (url.trim().isEmpty) return;

    _isRadio = true;
    _isStopped = false;
    _reciterName = null;
    _availableSurahs = [];
    _currentIndex = 0;

    final artworkUri = await _getArtworkUri();

    mediaItem.add(
      MediaItem(
        id: url,
        album: 'إذاعة القرآن الكريم',
        title: stationName,
        artist: 'بث مباشر',
        displayTitle: stationName,
        displaySubtitle: 'بث مباشر',
        displayDescription: 'إذاعة القرآن الكريم',
        artUri: artworkUri,
      ),
    );

    try {
      await _player.stop();
      await _player.setUrl(url);
      await _player.play();
    } catch (e) {
      debugPrint('Error playing radio ($url): $e');
      rethrow;
    }
  }

  // Quran Surahs
  Future<void> playSurah({
    required String reciterName,
    required List<Map<String, dynamic>> surahs,
    required int index,
  }) async {
    _isRadio = false;
    _isStopped = false;
    _reciterName = reciterName;
    _availableSurahs = List<Map<String, dynamic>>.from(surahs);

    if (_availableSurahs.isEmpty) {
      _currentIndex = 0;
      return;
    }

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
    final url = surah['url'] as String;
    final surahName = surah['name'] as String;

    if (url.trim().isEmpty) {
      debugPrint('Surah URL is empty: $surahName');
      return;
    }

    final artworkUri = await _getArtworkUri();
    final reciter = _reciterName ?? 'القارئ';

    mediaItem.add(
      MediaItem(
        id: url,
        album: 'القرآن الكريم',
        title: 'سورة $surahName',
        artist: reciter,
        displayTitle: 'سورة $surahName',
        displaySubtitle: reciter,
        displayDescription: 'القرآن الكريم',
        artUri: artworkUri,
      ),
    );

    playbackState.add(
      playbackState.value.copyWith(
        queueIndex: _currentIndex,
        updatePosition: Duration.zero,
        bufferedPosition: Duration.zero,
      ),
    );

    try {
      await _player.stop();
      await _player.setUrl(url);
      await _player.play();
    } catch (e) {
      debugPrint('Error playing surah "$surahName": $e');
      rethrow;
    }
  }

  @override
  Future<void> play() async {
    if (_isStopped) return;
    await _player.play();
  }

  @override
  Future<void> pause() async {
    await _player.pause();
  }

  @override
  Future<void> stop() async {
    _isStopped = true;

    await _player.stop();

    mediaItem.add(null);

    playbackState.add(
      playbackState.value.copyWith(
        controls: const [],
        playing: false,
        processingState: AudioProcessingState.idle,
        updatePosition: Duration.zero,
        bufferedPosition: Duration.zero,
      ),
    );

    await super.stop();
  }

  @override
  Future<void> seek(Duration position) async {
    if (_isRadio) return;
    await _player.seek(position);
  }

  @override
  Future<void> seekForward(bool begin) async {
    if (_isRadio) return;

    final target = _player.position + const Duration(seconds: 10);
    final duration = _player.duration;

    await _player.seek(
      duration != null && target > duration ? duration : target,
    );
  }

  @override
  Future<void> seekBackward(bool begin) async {
    if (_isRadio) return;

    final target = _player.position - const Duration(seconds: 10);

    await _player.seek(target < Duration.zero ? Duration.zero : target);
  }

  @override
  Future<void> skipToNext() async {
    if (_isRadio || _availableSurahs.isEmpty) return;

    if (_currentIndex < _availableSurahs.length - 1) {
      _currentIndex++;
      await _playCurrentSurah();
    } else {
      await stop();
    }
  }

  @override
  Future<void> skipToPrevious() async {
    if (_isRadio || _availableSurahs.isEmpty) return;

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

  bool get isRadio => _isRadio;
}
