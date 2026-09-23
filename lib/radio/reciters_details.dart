// lib/radio/reciters_details.dart
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:islamii_app/core/app_assets.dart';
import 'package:islamii_app/core/app_color.dart';
import 'package:islamii_app/core/audio_player_manager.dart';
import 'package:islamii_app/services/quran_api_service.dart';

import '../core/bottom_sheet.dart';
import 'models/reciter_model.dart';

class RecitersDetails extends StatefulWidget {
  const RecitersDetails({super.key});

  @override
  State<RecitersDetails> createState() => _RecitersDetailsState();
}

class _RecitersDetailsState extends State<RecitersDetails> {
  final QuranApiService _service = QuranApiService();
  late Future<List<ReciterModel>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.getReciters();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ReciterModel>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.only(top: 60),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return const Padding(
            padding: EdgeInsets.only(top: 60),
            child: Center(child: Text('حدث خطأ أثناء تحميل القراء')),
          );
        }

        final reciters = snapshot.data ?? [];

        return Column(
          children: [
            SizedBox(height: 18),
            for (final reciter in reciters) ...[
              _ReciterCard(reciter: reciter),
              SizedBox(height: 18),
            ],
          ],
        );
      },
    );
  }
}

class _ReciterCard extends StatefulWidget {
  final ReciterModel reciter;

  const _ReciterCard({required this.reciter});

  @override
  State<_ReciterCard> createState() => _ReciterCardState();
}

class _ReciterCardState extends State<_ReciterCard> {
  final _manager = AudioPlayerManager.instance;
  bool _isPlaying = false;
  bool _isMuted = false;
  String? _playingSurahName;

  String get _id => 'reciter_${widget.reciter.id}';

  @override
  void initState() {
    super.initState();
    _manager.onStateChanged.listen((state) {
      if (!mounted) return;
      final isThis = _manager.currentId == _id;
      setState(() {
        _isPlaying = isThis && state == PlayerState.playing;
        _playingSurahName = isThis ? _manager.currentLabel : _playingSurahName;
      });
    });
  }

  Future<void> _openSurahPicker() async {
    final moshaf = widget.reciter.defaultMoshaf;
    if (moshaf == null) return;

    final selectedSurah = await showSurahPicker(
      context: context,
      reciterName: widget.reciter.name,
      moshaf: moshaf,
    );

    if (selectedSurah == null) return;

    final url = moshaf.surahUrl(selectedSurah.id);
    setState(() => _playingSurahName = selectedSurah.arabicName);
    _manager.playUrl(_id, url, label: selectedSurah.arabicName);
  }

  void _togglePlayPause() {
    if (_manager.currentId != _id) {
      _openSurahPicker();
    } else {
      _manager.playUrl(_id, '');
    }
  }

  void _toggleMute() {
    setState(() => _isMuted = !_isMuted);
    _manager.player.setVolume(_isMuted ? 0 : 1);
  }

  @override
  Widget build(BuildContext context) {
    final hasAudio = widget.reciter.defaultMoshaf != null;

    return Container(
      width: 390,
      height: 138,
      margin: EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: AppColor.gold,
      ),
      child: Stack(
        children: [
          if (_isPlaying)
            Positioned(
              top: 80,
              left: 1,
              right: 1,
              child: Image.asset(
                AppAssets.voice,
                width: 520,
                fit: BoxFit.cover,
              ),
            )
          else
            Align(
              alignment: Alignment.bottomCenter,
              child: Image.asset(
                AppAssets.mosqueRadio,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Text(
                  widget.reciter.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColor.black,
                    fontSize: _isPlaying ? 17 : 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Janna',
                  ),
                ),

                if (_isPlaying && _playingSurahName != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      'يقرأ الآن: سورة $_playingSurahName',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColor.black.withOpacity(0.75),
                        fontSize: 12,
                        fontFamily: 'Janna',
                      ),
                    ),
                  ),

                const Spacer(),

                Padding(
                  padding: const EdgeInsets.only(left: 50),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: hasAudio ? _togglePlayPause : null,
                        child: Icon(
                          _isPlaying ? Icons.pause : Icons.play_arrow_sharp,
                          size: 45,
                          color: hasAudio ? null : Colors.grey,
                        ),
                      ),
                      SizedBox(width: 20),
                      GestureDetector(
                        onTap: _toggleMute,
                        child: Icon(
                          _isMuted ? Icons.volume_off : Icons.volume_up,
                          size: 30,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
