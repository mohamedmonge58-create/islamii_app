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
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

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

  /// Normalizes Arabic text for search matching (diacritics, hamzas, etc.)
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
    setState(() {
      _searchQuery = value;
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
    });
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        style: const TextStyle(
          color: AppColor.white,
          fontFamily: 'Janna',
          fontSize: 15,
        ),
        cursorColor: AppColor.gold,
        decoration: InputDecoration(
          hintText: "بحث عن إذاعة...",
          hintStyle: TextStyle(
            color: AppColor.white.withValues(alpha: 0.5),
            fontFamily: 'Janna',
            fontSize: 14,
          ),
          prefixIcon: const Icon(Icons.search, color: AppColor.gold, size: 22),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: AppColor.gold, size: 20),
                  onPressed: _clearSearch,
                  tooltip: 'مسح',
                )
              : null,
          filled: true,
          fillColor: AppColor.black.withValues(alpha: 0.55),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 16,
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: AppColor.gold, width: 1.2),
            borderRadius: BorderRadius.circular(16),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: AppColor.gold, width: 1.8),
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
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
              const Text(
                'لا توجد إذاعة بهذا الاسم',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColor.white,
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
                  color: AppColor.white.withValues(alpha: 0.6),
                  fontFamily: 'Janna',
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: _clearSearch,
                icon: const Icon(Icons.refresh, color: AppColor.gold, size: 18),
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
          return const Center(
            child: Padding(
              padding: EdgeInsets.only(top: 60),
              child: Text(
                'حدث خطأ أثناء تحميل الإذاعات',
                style: TextStyle(color: AppColor.white, fontFamily: 'Janna'),
              ),
            ),
          );
        }

        final radios = snapshot.data ?? [];
        final query = _normalizeArabic(_searchQuery.trim());
        final filteredRadios = query.isEmpty
            ? radios
            : radios.where((radio) {
                final name = _normalizeArabic(radio.name);
                return name.contains(query);
              }).toList();

        return Column(
          children: [
            _buildSearchBar(),
            if (filteredRadios.isEmpty)
              _buildEmptyState()
            else
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.only(bottom: 20, top: 6),
                  itemCount: filteredRadios.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 18),
                  itemBuilder: (context, index) {
                    return _RadioCard(radio: filteredRadios[index]);
                  },
                ),
              ),
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
      width: double.infinity,
      height: 138,
      margin: const EdgeInsets.symmetric(horizontal: 20),
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
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
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
                      style: const TextStyle(
                        color: AppColor.black,
                        fontSize: 18,
                        height: 1.0,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Janna',
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: _togglePlay,
                      child: Icon(
                        _isPlaying
                            ? Icons.pause_circle_filled
                            : Icons.play_circle_fill,
                        size: 42,
                        color: AppColor.black,
                      ),
                    ),
                    const SizedBox(width: 24),
                    GestureDetector(
                      onTap: _toggleMute,
                      child: Icon(
                        _isMuted ? Icons.volume_off : Icons.volume_up,
                        size: 28,
                        color: AppColor.black,
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
  }
}
