import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:islamii_app/core/app_assets.dart';
import 'package:islamii_app/core/app_color.dart';
import 'package:islamii_app/core/audio_player_manager.dart';
import 'package:islamii_app/services/quran_api_service.dart';

import '../core/bottom_sheet.dart';
import 'models/moshaf_model.dart';
import 'models/reciter_model.dart';

class RecitersDetails extends StatefulWidget {
  const RecitersDetails({super.key});

  @override
  State<RecitersDetails> createState() => _RecitersDetailsState();
}

class _RecitersDetailsState extends State<RecitersDetails> {
  final QuranApiService _service = QuranApiService();
  final AudioPlayerManager _manager = AudioPlayerManager.instance;
  final TextEditingController _searchController = TextEditingController();

  late Future<List<ReciterModel>> _future;

  String _searchQuery = '';
  ReciterModel? _activeReciter;
  bool _isChangingSurah = false;
  bool _showVolumeSlider = false;

  static const List<String> _surahNames = [
    'الفاتحة',
    'البقرة',
    'آل عمران',
    'النساء',
    'المائدة',
    'الأنعام',
    'الأعراف',
    'الأنفال',
    'التوبة',
    'يونس',
    'هود',
    'يوسف',
    'الرعد',
    'إبراهيم',
    'الحجر',
    'النحل',
    'الإسراء',
    'الكهف',
    'مريم',
    'طه',
    'الأنبياء',
    'الحج',
    'المؤمنون',
    'النور',
    'الفرقان',
    'الشعراء',
    'النمل',
    'القصص',
    'العنكبوت',
    'الروم',
    'لقمان',
    'السجدة',
    'الأحزاب',
    'سبأ',
    'فاطر',
    'يس',
    'الصافات',
    'ص',
    'الزمر',
    'غافر',
    'فصلت',
    'الشورى',
    'الزخرف',
    'الدخان',
    'الجاثية',
    'الأحقاف',
    'محمد',
    'الفتح',
    'الحجرات',
    'ق',
    'الذاريات',
    'الطور',
    'النجم',
    'القمر',
    'الرحمن',
    'الواقعة',
    'الحديد',
    'المجادلة',
    'الحشر',
    'الممتحنة',
    'الصف',
    'الجمعة',
    'المنافقون',
    'التغابن',
    'الطلاق',
    'التحريم',
    'الملك',
    'القلم',
    'الحاقة',
    'المعارج',
    'نوح',
    'الجن',
    'المزمل',
    'المدثر',
    'القيامة',
    'الإنسان',
    'المرسلات',
    'النبأ',
    'النازعات',
    'عبس',
    'التكوير',
    'الانفطار',
    'المطففين',
    'الانشقاق',
    'البروج',
    'الطارق',
    'الأعلى',
    'الغاشية',
    'الفجر',
    'البلد',
    'الشمس',
    'الليل',
    'الضحى',
    'الشرح',
    'التين',
    'العلق',
    'القدر',
    'البينة',
    'الزلزلة',
    'العاديات',
    'القارعة',
    'التكاثر',
    'العصر',
    'الهمزة',
    'الفيل',
    'قريش',
    'الماعون',
    'الكوثر',
    'الكافرون',
    'النصر',
    'المسد',
    'الإخلاص',
    'الفلق',
    'الناس',
  ];

  @override
  void initState() {
    super.initState();
    _future = _service.getReciters();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    final hours = duration.inHours;
    if (hours > 0) {
      return '$hours:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  String _surahName(int number) {
    if (number < 1 || number > _surahNames.length) {
      return 'السورة رقم $number';
    }
    return _surahNames[number - 1];
  }

  List<int> _parseSurahList(MoshafModel moshaf) {
    final values = moshaf.surahList
        .split(',')
        .map((value) => int.tryParse(value.trim()))
        .whereType<int>()
        .where((number) => number >= 1 && number <= 114)
        .toList();
    return values.toSet().toList();
  }

  List<Map<String, dynamic>> _buildSurahsList(
    MoshafModel moshaf,
    List<int> numbers,
  ) {
    return numbers.map((surahNum) {
      return {
        'id': surahNum,
        'name': _surahName(surahNum),
        'url': moshaf.surahUrl(surahNum),
      };
    }).toList();
  }

  String _normalizeArabic(String text) {
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
          hintText: 'بحث عن قارئ...',
          hintStyle: TextStyle(
            color: AppColor.secondaryText(context),
            fontFamily: 'Janna',
            fontSize: 14,
          ),
          prefixIcon: Icon(Icons.search_rounded, color: borderAccent),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  onPressed: _clearSearch,
                  icon: Icon(Icons.close_rounded, color: borderAccent),
                )
              : null,
          filled: true,
          fillColor: AppColor.searchBarFill(context),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 16,
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: borderAccent.withValues(alpha: 0.6)),
            borderRadius: BorderRadius.circular(18),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: borderAccent, width: 1.5),
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final accentColor = AppColor.primary(context);

    return Expanded(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.person_search_rounded,
                color: accentColor.withValues(alpha: 0.8),
                size: 58,
              ),
              const SizedBox(height: 16),
              Text(
                'لا يوجد قارئ بهذا الاسم',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColor.primaryText(context),
                  fontFamily: 'Janna',
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'جرّب البحث باستخدام اسم آخر',
                style: TextStyle(
                  color: AppColor.secondaryText(context),
                  fontFamily: 'Janna',
                ),
              ),
              const SizedBox(height: 18),
              OutlinedButton.icon(
                onPressed: _clearSearch,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('عرض كل القراء'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: accentColor,
                  side: BorderSide(color: accentColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _chooseSurah(ReciterModel reciter) async {
    final moshaf = reciter.defaultMoshaf;
    if (moshaf == null || !mounted) return;

    final selectedSurah = await showSurahPicker(
      context: context,
      reciterName: reciter.name,
      moshaf: moshaf,
    );

    if (selectedSurah == null || !mounted) return;

    final availableNumbers = _parseSurahList(moshaf);
    final selectedNumber = selectedSurah.id;
    final index = availableNumbers.indexOf(selectedNumber);

    if (index == -1) {
      _showMessage('السورة المختارة غير موجودة في قائمة هذا المصحف');
      return;
    }

    final surahsList = _buildSurahsList(moshaf, availableNumbers);

    setState(() {
      _activeReciter = reciter;
      _isChangingSurah = true;
    });

    try {
      await _manager.playSurah(
        reciterId: reciter.id.toString(),
        reciterName: reciter.name,
        surahs: surahsList,
        index: index,
      );
    } catch (_) {
      if (mounted) _showMessage('تعذّر تشغيل السورة، حاول مرة أخرى');
    } finally {
      if (mounted) {
        setState(() {
          _isChangingSurah = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message, style: const TextStyle(fontFamily: 'Janna')),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
  }

  Widget _roundControl({
    required IconData icon,
    required String tooltip,
    required VoidCallback? onPressed,
    bool primary = false,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: primary ? AppColor.gold : AppColor.white.withValues(alpha: 0.07),
        shape: const CircleBorder(),
        child: IconButton(
          onPressed: onPressed,
          icon: Icon(
            icon,
            size: primary ? 29 : 24,
            color: primary
                ? AppColor.black
                : AppColor.white.withValues(alpha: onPressed == null ? 0.3 : 1),
          ),
        ),
      ),
    );
  }

  Widget _buildMiniPlayer() {
    final reciter = _activeReciter;
    if (reciter == null) return const SizedBox.shrink();

    return FutureBuilder(
      future: _manager.audioHandler,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        final handler = snapshot.data!;

        return StreamBuilder<MediaItem?>(
          stream: handler.mediaItem,
          builder: (context, mediaSnapshot) {
            final mediaItem = mediaSnapshot.data;
            final surahName = mediaItem?.title ?? 'جاري التحميل...';

            return StreamBuilder<PlaybackState>(
              stream: handler.playbackState,
              builder: (context, playbackSnapshot) {
                final playbackState = playbackSnapshot.data;
                final isPlaying = playbackState?.playing ?? false;
                final position = playbackState?.position ?? Duration.zero;
                final duration = mediaItem?.duration ?? Duration.zero;
                final handler = snapshot.data!;
                final hasPrevious = handler.currentSurahIndex > 0;
                final hasNext =
                    handler.currentSurahIndex <
                    handler.currentSurahsList.length - 1;
                final isLight = AppColor.isLight(context);

                final playerTextColor = isLight ? AppColor.black : AppColor.white;
                final playerSecondaryColor = isLight
                    ? AppColor.lightPrimaryDark
                    : AppColor.white.withValues(alpha: 0.75);

                final playerDividerColor = (isLight ? AppColor.black : AppColor.white)
                    .withValues(alpha: 0.10);
                return SafeArea(
                  top: false,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        margin: const EdgeInsets.fromLTRB(12, 8, 12, 10),
                        padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
                        decoration: BoxDecoration(
                          gradient: AppColor.isLight(context)
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
                          ),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: AppColor.gold.withValues(alpha: 0.65),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColor.black.withValues(alpha: 0.25),
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
                                        reciter.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: AppColor.white,
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
                                            Icons.menu_book_rounded,
                                            color: AppColor.gold,
                                            size: 14,
                                          ),
                                          const SizedBox(width: 5),
                                          Flexible(
                                            child: Text(
                                              surahName,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: AppColor.gold.withValues(
                                                  alpha: 0.95,
                                                ),
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
                                IconButton(
                                  tooltip: 'اختيار سورة',
                                  onPressed: _isChangingSurah
                                      ? null
                                      : () => _chooseSurah(reciter),
                                  icon: const Icon(
                                    Icons.queue_music_rounded,
                                    color: AppColor.gold,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                trackHeight: 3,
                                thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 5,
                                ),
                                overlayShape: const RoundSliderOverlayShape(
                                  overlayRadius: 10,
                                ),
                                activeTrackColor: AppColor.gold,
                                inactiveTrackColor: AppColor.white.withValues(
                                  alpha: 0.2,
                                ),
                                thumbColor: AppColor.gold,
                              ),
                              child: Slider(
                                min: 0,
                                max: duration.inMilliseconds > 0
                                    ? duration.inMilliseconds.toDouble()
                                    : 1,
                                value: position.inMilliseconds
                                    .clamp(
                                      0,
                                      duration.inMilliseconds > 0
                                          ? duration.inMilliseconds
                                          : 1,
                                    )
                                    .toDouble(),
                                onChanged: duration.inMilliseconds > 0
                                    ? (value) => handler.seek(
                                        Duration(milliseconds: value.round()),
                                      )
                                    : null,
                              ),
                            ),

                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _formatDuration(position),
                                    style: const TextStyle(
                                      color: AppColor.white,
                                      fontSize: 11,
                                      fontFamily: 'Janna',
                                    ),
                                  ),
                                  Text(
                                    '-${_formatDuration(Duration(milliseconds: (duration.inMilliseconds - position.inMilliseconds).clamp(0, duration.inMilliseconds)))}',
                                    style: TextStyle(
                                      color: AppColor.white.withValues(
                                        alpha: 0.65,
                                      ),
                                      fontSize: 11,
                                      fontFamily: 'Janna',
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 12),
                            Container(
                              height: 1,
                              color: AppColor.white.withValues(alpha: 0.09),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _roundControl(
                                  icon: Icons.skip_previous_rounded,
                                  tooltip: 'السورة السابقة',
                                  onPressed: hasPrevious
                                      ? () => handler.skipToPrevious()
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                _roundControl(
                                  icon: isPlaying
                                      ? Icons.pause_rounded
                                      : Icons.play_arrow_rounded,
                                  tooltip: isPlaying ? 'إيقاف مؤقت' : 'تشغيل',
                                  onPressed: () {
                                    if (isPlaying) {
                                      handler.pause();
                                    } else {
                                      handler.play();
                                    }
                                  },
                                  primary: true,
                                ),
                                const SizedBox(width: 12),
                                _roundControl(
                                  icon: Icons.skip_next_rounded,
                                  tooltip: 'السورة التالية',
                                  onPressed: hasNext
                                      ? () => handler.skipToNext()
                                      : null,
                                ),
                                const SizedBox(width: 10),
                                StreamBuilder<double>(
                                  stream: handler.volumeStream,
                                  initialData: handler.volume,
                                  builder: (context, volSnapshot) {
                                    final currentVol =
                                        volSnapshot.data ?? handler.volume;
                                    return _roundControl(
                                      icon: currentVol == 0
                                          ? Icons.volume_off_rounded
                                          : currentVol < 0.5
                                          ? Icons.volume_down_rounded
                                          : Icons.volume_up_rounded,
                                      tooltip: 'مستوى الصوت',
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

                      // Floating Vertical Volume Slider Panel
                      if (_showVolumeSlider)
                        Positioned(
                          right: 18,
                          bottom: 60,
                          child: Material(
                            color: Colors.transparent,
                            child: StreamBuilder<double>(
                              stream: handler.volumeStream,
                              initialData: handler.volume,
                              builder: (context, volSnapshot) {
                                final currentVol =
                                    volSnapshot.data ?? handler.volume;
                                final volPercent = (currentVol * 100).round();

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
                                        : const Color(0xFF1F231F),                                    borderRadius: BorderRadius.circular(22),
                                    border: Border.all(
                                      color: isLight ? AppColor.lightPrimaryEmerald : AppColor.gold,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.5,
                                        ),
                                        blurRadius: 14,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        '$volPercent%',
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
                                          quarterTurns:
                                              3, // Rotates horizontal slider vertically (0% bottom, 100% top)
                                          child: SliderTheme(
                                            data: SliderTheme.of(context).copyWith(
                                              trackHeight: 4,
                                              thumbShape:
                                                  const RoundSliderThumbShape(
                                                    enabledThumbRadius: 6,
                                                  ),
                                              overlayShape:
                                                  const RoundSliderOverlayShape(
                                                    overlayRadius: 10,
                                                  ),
                                              activeTrackColor: AppColor.gold,
                                              inactiveTrackColor: (isLight ? AppColor.black : AppColor.white)
                                                  .withValues(alpha: 0.16),
                                              thumbColor: AppColor.gold,
                                            ),
                                            child: Slider(
                                              min: 0.0,
                                              max: 1.0,
                                              value: currentVol.clamp(0.0, 1.0),
                                              onChanged: (val) {
                                                handler.setVolume(val);
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      GestureDetector(
                                        onTap: () {
                                          if (currentVol > 0) {
                                            handler.setVolume(0.0);
                                          } else {
                                            handler.setVolume(1.0);
                                          }
                                        },
                                        child: Icon(
                                          currentVol == 0
                                              ? Icons.volume_off_rounded
                                              : currentVol < 0.5
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
    return FutureBuilder<List<ReciterModel>>(
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
                  const Text(
                    'حدث خطأ أثناء تحميل القراء',
                    style: TextStyle(
                      color: AppColor.white,
                      fontFamily: 'Janna',
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _future = _service.getReciters();
                      });
                    },
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            ),
          );
        }

        final reciters = snapshot.data ?? [];
        final query = _normalizeArabic(_searchQuery.trim());

        final filteredReciters = query.isEmpty
            ? reciters
            : reciters.where((reciter) {
                return _normalizeArabic(reciter.name).contains(query);
              }).toList();

        return Column(
          children: [
            _buildSearchBar(),
            if (filteredReciters.isEmpty)
              _buildEmptyState()
            else
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.only(top: 6, bottom: 12),
                  itemCount: filteredReciters.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final reciter = filteredReciters[index];
                    final isActive = _activeReciter?.id == reciter.id;

                    return FutureBuilder(
                      future: _manager.audioHandler,
                      builder: (context, snapshot) {
                        final handler = snapshot.data;
                        return StreamBuilder<PlaybackState>(
                          stream: handler?.playbackState,
                          builder: (context, stateSnapshot) {
                            final isPlaying =
                                isActive &&
                                (stateSnapshot.data?.playing ?? false);

                            return _ReciterCard(
                              reciter: reciter,
                              isActive: isActive,
                              isPlaying: isPlaying,
                              onChooseSurah: () => _chooseSurah(reciter),
                              onPlayPause: () async {
                                if (!isActive) {
                                  await _chooseSurah(reciter);
                                } else {
                                  if (isPlaying) {
                                    await handler?.pause();
                                  } else {
                                    await handler?.play();
                                  }
                                }
                              },
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            if (_activeReciter != null) _buildMiniPlayer(),
          ],
        );
      },
    );
  }
}

class _ReciterCard extends StatelessWidget {
  final ReciterModel reciter;
  final bool isActive;
  final bool isPlaying;
  final VoidCallback onChooseSurah;
  final VoidCallback onPlayPause;

  const _ReciterCard({
    required this.reciter,
    required this.isActive,
    required this.isPlaying,
    required this.onChooseSurah,
    required this.onPlayPause,
  });

  @override
  Widget build(BuildContext context) {
    final hasAudio = reciter.defaultMoshaf != null;
    final isLight = AppColor.isLight(context);
    final cardBg = isLight ? AppColor.lightPrimaryEmerald : AppColor.gold;
    final fgColor = isLight ? AppColor.white : AppColor.black;
    final iconColor = hasAudio ? fgColor : Colors.grey;

    return Container(
      height: 140,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: cardBg,
        border: Border.all(
          color: isActive
              ? (isLight ? AppColor.lightGoldAccent : AppColor.gold)
              : cardBg,
          width: isActive ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColor.black.withValues(alpha: isLight ? 0.1 : 0.16),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: isActive ? 90 : 140,
            child: Image.asset(
              isActive ? AppAssets.voice : AppAssets.mosqueRadio,
              fit: BoxFit.cover,
              alignment: Alignment.bottomCenter,
              errorBuilder: (_, _, _) => const SizedBox.shrink(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Center(
                        child: Text(
                          reciter.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: fgColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Janna',
                          ),
                        ),
                      ),
                    ),
                    if (isActive)
                      Icon(Icons.graphic_eq_rounded, color: fgColor, size: 22),
                  ],
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: hasAudio ? onPlayPause : null,
                      tooltip: isPlaying ? 'إيقاف مؤقت' : 'تشغيل',
                      icon: Icon(
                        isPlaying
                            ? Icons.pause_circle_filled_rounded
                            : Icons.play_circle_fill_rounded,
                        size: 43,
                        color: iconColor,
                      ),
                    ),
                    const SizedBox(width: 14),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
