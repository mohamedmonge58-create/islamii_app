// lib/radio/radio_details.dart
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:islamii_app/core/app_assets.dart';
import 'package:islamii_app/core/app_color.dart';
import 'package:islamii_app/core/audio_player_manager.dart';
import 'package:islamii_app/services/quran_api_service.dart';

import 'models/radio_model.dart';

class RadioDetails extends StatefulWidget {
  const RadioDetails({super.key});

  @override
  State<RadioDetails> createState() => _RadioDetailsState();
}

class _RadioDetailsState extends State<RadioDetails> {
  final QuranApiService _service = QuranApiService();
  late Future<List<RadioModel>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.getRadios();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<RadioModel>>(
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
            child: Center(child: Text('حدث خطأ أثناء تحميل الإذاعات')),
          );
        }

        final radios = snapshot.data ?? [];

        return Column(
          children: [
            SizedBox(height: 18),
            for (final radio in radios) ...[
              _RadioCard(radio: radio),
              SizedBox(height: 18),
            ],
          ],
        );
      },
    );
  }
}

class _RadioCard extends StatefulWidget {
  final RadioModel radio;

  const _RadioCard({required this.radio});

  @override
  State<_RadioCard> createState() => _RadioCardState();
}

class _RadioCardState extends State<_RadioCard> {
  final _manager = AudioPlayerManager.instance;
  bool _isPlaying = false;
  bool _isMuted = false;

  String get _id => 'radio_${widget.radio.id}';

  @override
  void initState() {
    super.initState();
    _manager.onStateChanged.listen((state) {
      if (!mounted) return;
      final isThis = _manager.currentId == _id;
      setState(() {
        _isPlaying = isThis && state == PlayerState.playing;
      });
    });
  }

  void _togglePlay() => _manager.playUrl(_id, widget.radio.url);

  void _toggleMute() {
    setState(() => _isMuted = !_isMuted);
    _manager.player.setVolume(_isMuted ? 0 : 1);
  }

  @override
  Widget build(BuildContext context) {
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
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // النص يتقلص تلقائيًا لو أطول من المساحة المتاحة
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      widget.radio.name,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColor.black,
                        fontSize: 18,
                        height: 1.0,
                        // نتحكم في ارتفاع السطر يدويًا
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Janna',
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 50),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: _togglePlay,
                        child: Icon(
                          _isPlaying ? Icons.pause : Icons.play_arrow_sharp,
                          size: 40,
                        ),
                      ),
                      SizedBox(width: 20),
                      GestureDetector(
                        onTap: _toggleMute,
                        child: Icon(
                          _isMuted ? Icons.volume_off : Icons.volume_up,
                          size: 28,
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