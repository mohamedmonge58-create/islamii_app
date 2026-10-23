
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:islamii_app/core/app_assets.dart';
import 'package:islamii_app/core/app_color.dart';
import 'package:islamii_app/core/audio_player_manager.dart';
import 'package:islamii_app/core/quran_audio_handler.dart';
import 'package:islamii_app/services/quran_api_service.dart';

import 'models/radio_model.dart';

class RadioDetails extends StatefulWidget {
  const RadioDetails({super.key});

  @override
  State<RadioDetails> createState() => _RadioDetailsState();
}

class _RadioDetailsState extends State<RadioDetails> {
  final QuranApiService _service = QuranApiService();
  final AudioPlayerManager _manager = AudioPlayerManager.instance;
  final TextEditingController _searchController = TextEditingController();

  late Future<List<RadioModel>> _future;

  String _searchQuery = '';
  String? _activeRadioId;
  String? _activeRadioName;
  bool _showVolumeSlider = false;

  @override
  void initState() {
    super.initState();
    _future = _service.getRadios();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _normalizeArabic(String text) {
    if (text.isEmpty) return text;

    var normalized = text.toLowerCase();
    normalized = normalized.replaceAll(RegExp(r'[\u064B-\u0652]'), '');
    normalized = normalized.replaceAll(RegExp(r'[أإآٱ]'), 'ا');
    normalized = normalized.replaceAll('ى', 'ي');
    normalized = normalized.replaceAll('ة', 'ه');

    return normalized;
  }

  void _onSearchChanged(String value) {
    setState(() => _searchQuery = value);
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() => _searchQuery = '');
  }

  void _selectRadio(RadioModel radio) {
    setState(() {
      _activeRadioId = 'radio_${radio.id}';
      _activeRadioName = radio.name;
      _showVolumeSlider = false;
    });
  }

  Widget _buildSearchBar() {
    final borderAccent = AppColor.searchBarBorder(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        style: TextStyle(
          color: AppColor.primaryText(context),
          fontFamily: 'Janna',
          fontSize: 15,
        ),
        cursorColor: borderAccent,
        decoration: InputDecoration(
          hintText: 'بحث عن إذاعة...',
          hintStyle: TextStyle(
            color: AppColor.secondaryText(context),
            fontFamily: 'Janna',
            fontSize: 14,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: borderAccent,
            size: 22,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
            icon: Icon(
              Icons.clear,
              color: borderAccent,
              size: 20,
            ),
            onPressed: _clearSearch,
            tooltip: 'مسح',
          )
              : null,
          filled: true,
          fillColor: AppColor.searchBarFill(context),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 16,
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: borderAccent,
              width: 1.2,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: borderAccent,
              width: 1.8,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final isLight = AppColor.isLight(context);

    return Expanded(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColor.gold.withValues(alpha: 0.15),
                  border: Border.all(
                    color: AppColor.gold.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.radio_outlined,
                  color: AppColor.gold,
                  size: 44,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'لا توجد إذاعة بهذا الاسم',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isLight ? AppColor.black : AppColor.white,
                  fontFamily: 'Janna',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'تأكد من كتابة الاسم بشكل صحيح أو جرب كلمة بحث أخرى',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isLight
                      ? AppColor.black.withValues(alpha: 0.6)
                      : AppColor.white.withValues(alpha: 0.6),
                  fontFamily: 'Janna',
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: _clearSearch,
                icon: const Icon(
                  Icons.refresh,
                  color: AppColor.gold,
                  size: 18,
                ),
                label: const Text(
                  'إعادة عرض كل الإذاعات',
                  style: TextStyle(
                    color: AppColor.gold,
                    fontFamily: 'Janna',
                    fontSize: 13,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColor.gold),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _miniPlayerControl({
    required IconData icon,
    required String tooltip,
    required VoidCallback? onPressed,
    required bool isLight,
    bool primary = false,
  }) {
    final secondaryIconColor = isLight
        ? AppColor.lightPrimaryDark
        : AppColor.white;

    return Tooltip(
      message: tooltip,
      child: Material(
        color: primary
            ? AppColor.gold
            : (isLight
            ? AppColor.lightPrimaryEmerald.withValues(alpha: 0.12)
            : AppColor.white.withValues(alpha: 0.07)),
        shape: const CircleBorder(),
        child: IconButton(
          onPressed: onPressed,
          tooltip: tooltip,
          icon: Icon(
            icon,
            size: primary ? 29 : 24,
            color: primary
                ? AppColor.black
                : secondaryIconColor.withValues(
              alpha: onPressed == null ? 0.3 : 1,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMiniPlayer() {
    final activeRadioId = _activeRadioId;

    if (activeRadioId == null) {
      return const SizedBox.shrink();
    }

    final isLight = AppColor.isLight(context);

    final playerGradient = isLight
        ? const LinearGradient(
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
      colors: [
        Color(0xFFF0F7F2),
        Color(0xFFDCECE1),
        Color(0xFFC5DFCE),
      ],
    )
        : const LinearGradient(
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
      colors: [
        Color(0xFF173D32),
        Color(0xFF102F27),
        Color(0xFF0B241E),
      ],
    );

    final playerTextColor = isLight ? AppColor.black : AppColor.white;

    final playerSecondaryColor = isLight
        ? AppColor.lightPrimaryDark
        : AppColor.white.withValues(alpha: 0.75);

    final playerDividerColor =
    (isLight ? AppColor.black : AppColor.white)
        .withValues(alpha: 0.10);

    return FutureBuilder<QuranAudioHandler>(
      future: _manager.audioHandler,
      builder: (context, handlerSnapshot) {
        if (!handlerSnapshot.hasData) {
          return const SizedBox.shrink();
        }

        final handler = handlerSnapshot.data!;

        return StreamBuilder<MediaItem?>(
          stream: handler.mediaItem,
          builder: (context, mediaSnapshot) {
            final mediaItem = mediaSnapshot.data;

            if (_manager.currentId != activeRadioId ||
                mediaItem == null ||
                mediaItem.id != _manager.currentUrl) {
              return const SizedBox.shrink();
            }

            return StreamBuilder<PlaybackState>(
              stream: handler.playbackState,
              builder: (context, playbackSnapshot) {
                final isPlaying =
                    playbackSnapshot.data?.playing ?? false;

                return SafeArea(
                  top: false,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        margin: const EdgeInsets.fromLTRB(12, 8, 12, 10),
                        padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
                        decoration: BoxDecoration(
                          gradient: playerGradient,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: isLight
                                ? AppColor.lightPrimaryEmerald.withValues(
                              alpha: 0.45,
                            )
                                : AppColor.gold.withValues(alpha: 0.65),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColor.black.withValues(
                                alpha: isLight ? 0.08 : 0.25,
                              ),
                              blurRadius: 18,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: AppColor.gold.withValues(
                                      alpha: isLight ? 0.18 : 0.13,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Icon(
                                    Icons.graphic_eq_rounded,
                                    color: AppColor.gold,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        _activeRadioName ?? mediaItem.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: playerTextColor,
                                          fontFamily: 'Janna',
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.radio_rounded,
                                            color: AppColor.gold,
                                            size: 14,
                                          ),
                                          const SizedBox(width: 5),
                                          Flexible(
                                            child: Text(
                                              'بث مباشر',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: playerSecondaryColor,
                                                fontFamily: 'Janna',
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 48),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Container(
                              height: 1,
                              color: playerDividerColor,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _miniPlayerControl(
                                  icon: isPlaying
                                      ? Icons.pause_rounded
                                      : Icons.play_arrow_rounded,
                                  tooltip: isPlaying
                                      ? 'إيقاف مؤقت'
                                      : 'تشغيل',
                                  primary: true,
                                  isLight: isLight,
                                  onPressed: () async {
                                    if (isPlaying) {
                                      await handler.pause();
                                    } else {
                                      await handler.play();
                                    }
                                  },
                                ),
                                const SizedBox(width: 12),
                                StreamBuilder<double>(
                                  stream: handler.volumeStream,
                                  initialData: handler.volume,
                                  builder: (context, volumeSnapshot) {
                                    final volume =
                                        volumeSnapshot.data ??
                                            handler.volume;

                                    return _miniPlayerControl(
                                      icon: volume == 0
                                          ? Icons.volume_off_rounded
                                          : volume < 0.5
                                          ? Icons.volume_down_rounded
                                          : Icons.volume_up_rounded,
                                      tooltip: 'مستوى الصوت',
                                      isLight: isLight,
                                      onPressed: () {
                                        setState(() {
                                          _showVolumeSlider =
                                          !_showVolumeSlider;
                                        });
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (_showVolumeSlider)
                        Positioned(
                          right: 18,
                          bottom: 60,
                          child: Material(
                            color: Colors.transparent,
                            child: StreamBuilder<double>(
                              stream: handler.volumeStream,
                              initialData: handler.volume,
                              builder: (context, volumeSnapshot) {
                                final volume =
                                    volumeSnapshot.data ??
                                        handler.volume;
                                final volumePercent =
                                (volume * 100).round();

                                return Container(
                                  width: 52,
                                  height: 180,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isLight
                                        ? const Color(0xFFE0F0E7)
                                        : const Color(0xFF1F231F),
                                    borderRadius: BorderRadius.circular(22),
                                    border: Border.all(
                                      color: isLight
                                          ? AppColor.lightPrimaryEmerald
                                          : AppColor.gold,
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: isLight ? 0.15 : 0.3,
                                        ),
                                        blurRadius: 14,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        '$volumePercent%',
                                        style: const TextStyle(
                                          color: AppColor.gold,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Janna',
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Expanded(
                                        child: RotatedBox(
                                          quarterTurns: 3,
                                          child: SliderTheme(
                                            data: SliderTheme.of(context)
                                                .copyWith(
                                              trackHeight: 4,
                                              thumbShape:
                                              const RoundSliderThumbShape(
                                                enabledThumbRadius: 6,
                                              ),
                                              overlayShape:
                                              const RoundSliderOverlayShape(
                                                overlayRadius: 10,
                                              ),
                                              activeTrackColor:
                                              AppColor.gold,
                                              inactiveTrackColor:
                                              (isLight
                                                  ? AppColor.black
                                                  : AppColor.white)
                                                  .withValues(
                                                alpha: 0.16,
                                              ),
                                              thumbColor: AppColor.gold,
                                            ),
                                            child: Slider(
                                              min: 0,
                                              max: 1,
                                              value: volume.clamp(0.0, 1.0),
                                              onChanged: handler.setVolume,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      GestureDetector(
                                        onTap: () {
                                          handler.setVolume(
                                            volume > 0 ? 0 : 1,
                                          );
                                        },
                                        child: Icon(
                                          volume == 0
                                              ? Icons.volume_off_rounded
                                              : volume < 0.5
                                              ? Icons.volume_down_rounded
                                              : Icons.volume_up_rounded,
                                          color: AppColor.gold,
                                          size: 18,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<RadioModel>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.only(top: 60),
              child: CircularProgressIndicator(color: AppColor.gold),
            ),
          );
        }

        if (snapshot.hasError) {
          final isLight = AppColor.isLight(context);

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.cloud_off_rounded,
                    color: AppColor.gold,
                    size: 42,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'حدث خطأ أثناء تحميل الإذاعات',
                    style: TextStyle(
                      color: isLight ? AppColor.black : AppColor.white,
                      fontFamily: 'Janna',
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _future = _service.getRadios();
                      });
                    },
                    child: const Text(
                      'إعادة المحاولة',
                      style: TextStyle(fontFamily: 'Janna'),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final radios = snapshot.data ?? [];
        final query = _normalizeArabic(_searchQuery.trim());

        final filteredRadios = query.isEmpty
            ? radios
            : radios.where((radio) {
          return _normalizeArabic(radio.name).contains(query);
        }).toList();

        return Column(
          children: [
            _buildSearchBar(),
            if (filteredRadios.isEmpty)
              _buildEmptyState()
            else
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.only(
                    bottom: 12,
                    top: 6,
                  ),
                  itemCount: filteredRadios.length,
                  separatorBuilder: (_, _) =>
                  const SizedBox(height: 18),
                  itemBuilder: (context, index) {
                    final radio = filteredRadios[index];

                    return _RadioCard(
                      key: ValueKey(radio.id),
                      radio: radio,
                      onRadioSelected: _selectRadio,
                    );
                  },
                ),
              ),
            if (_activeRadioId != null) _buildMiniPlayer(),
          ],
        );
      },
    );
  }
}

class _RadioCard extends StatefulWidget {
  final RadioModel radio;
  final ValueChanged<RadioModel> onRadioSelected;

  const _RadioCard({
    super.key,
    required this.radio,
    required this.onRadioSelected,
  });

  @override
  State<_RadioCard> createState() => _RadioCardState();
}

class _RadioCardState extends State<_RadioCard> {
  final AudioPlayerManager _manager = AudioPlayerManager.instance;

  String get _id => 'radio_${widget.radio.id}';

  Future<void> _togglePlay() async {
    widget.onRadioSelected(widget.radio);

    try {
      await _manager.playUrl(
        _id,
        widget.radio.url,
        label: widget.radio.name,
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'تعذّر تشغيل الإذاعة، حاول مرة أخرى',
              style: TextStyle(fontFamily: 'Janna'),
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuranAudioHandler>(
      future: _manager.audioHandler,
      builder: (context, handlerSnapshot) {
        final handler = handlerSnapshot.data;

        return StreamBuilder<PlaybackState>(
          stream: handler?.playbackState,
          builder: (context, playbackSnapshot) {
            final isActive = _manager.currentId == _id;
            final isPlaying =
                isActive && (playbackSnapshot.data?.playing ?? false);

            final isLight = AppColor.isLight(context);
            final cardBgColor = isLight
                ? AppColor.lightPrimaryEmerald
                : AppColor.gold;
            final fgColor = isLight ? AppColor.white : AppColor.black;

            return Container(
              width: double.infinity,
              height: 138,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: cardBgColor,
                boxShadow: isLight
                    ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
                    : null,
              ),
              child: Stack(
                children: [
                  if (isPlaying)
                    Positioned(
                      top: 80,
                      left: 1,
                      right: 1,
                      child: Image.asset(
                        AppAssets.voice,
                        width: 520,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) =>
                        const SizedBox.shrink(),
                      ),
                    )
                  else
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Image.asset(
                        AppAssets.mosqueRadio,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) =>
                        const SizedBox.shrink(),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 16,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              widget.radio.name,
                              maxLines: 1,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: fgColor,
                                fontSize: 18,
                                height: 1,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Janna',
                              ),
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: _togglePlay,
                              tooltip: isPlaying ? 'إيقاف مؤقت' : 'تشغيل',
                              icon: Icon(
                                isPlaying
                                    ? Icons.pause_circle_filled
                                    : Icons.play_circle_fill,
                                size: 42,
                                color: fgColor,
                              ),
                            ),
                            const SizedBox(width: 24),
                            IconButton(
                              onPressed: () async {
                                final h =
                                    handler ?? await _manager.audioHandler;
                                final volume = h.volume;
                                await h.setVolume(volume > 0 ? 0 : 1);
                              },
                              tooltip: 'كتم الصوت / تشغيل الصوت',
                              icon: StreamBuilder<double>(
                                stream: handler?.volumeStream,
                                initialData: handler?.volume ?? 1,
                                builder: (context, volumeSnapshot) {
                                  final volume =
                                      volumeSnapshot.data ?? 1;

                                  return Icon(
                                    volume == 0
                                        ? Icons.volume_off
                                        : Icons.volume_up,
                                    size: 28,
                                    color: fgColor,
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
