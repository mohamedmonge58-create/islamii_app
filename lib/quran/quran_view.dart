import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:islamii_app/core/app_assets.dart';
import 'package:islamii_app/core/app_color.dart';
import 'package:islamii_app/modules/sura_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
class QuranView extends StatefulWidget {
  final SuraModel sura;

  const QuranView({super.key, required this.sura});

  @override
  State<QuranView> createState() => _QuranViewState();
}

class _QuranViewState extends State<QuranView> {
  int? _highlightedAyah;
  bool _prefsLoaded = false;
  late final Future<Map<String, dynamic>> _surahFuture;
  final ItemScrollController _itemScrollController = ItemScrollController();
  bool _restoredPosition = false;
  final ScrollController _scrollController = ScrollController();
  String get _prefsKey => 'highlighted_ayah_${widget.sura.id}';
  @override
  void initState() {
    super.initState();
    _surahFuture = SurahDetails.loadSurah(widget.sura.id);
    _loadHighlight();
  }
  void _goToHighlightedAyah() {
    final ayah = _highlightedAyah;

    if (ayah == null || !_itemScrollController.isAttached) return;

    _itemScrollController.scrollTo(
      index: ayah - 1,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }
  Future<void> _loadHighlight() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getInt(_prefsKey);

    if (!mounted) return;
    setState(() {
      _highlightedAyah = saved;
      _prefsLoaded = true;
    });
  }

  Future<void> _toggleHighlight(int ayahNumber) async {
    final newHighlight =
    _highlightedAyah == ayahNumber ? null : ayahNumber;

    setState(() {
      _highlightedAyah = newHighlight;
    });

    final prefs = await SharedPreferences.getInstance();

    if (newHighlight == null) {
      await prefs.remove(_prefsKey);
    } else {
      await prefs.setInt(_prefsKey, newHighlight);
    }
  }
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColor.black,
      appBar: AppBar(
        toolbarHeight: size.height * .1,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back, color: AppColor.gold),
        ),
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              widget.sura.englishName,
              style: const TextStyle(
                color: AppColor.gold,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Align(
                  child: Image.asset(
                    AppAssets.leftCorner,
                    width: 90,
                    height: 90,
                  ),
                ),
                SizedBox(
                  height: 80,
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Text(
                      widget.sura.arabicName,
                      style: const TextStyle(
                        color: AppColor.gold,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Image.asset(AppAssets.rightCorner, width: 90, height: 90),
              ],
            ),
          ),
          Expanded(
            child: !_prefsLoaded
                ? const Center(
                    child: CircularProgressIndicator(color: AppColor.gold),
                  )
                : FutureBuilder<Map<String, dynamic>>(
                    future: _surahFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: AppColor.gold,
                          ),
                        );
                      }

                      if (snapshot.hasError || snapshot.data == null) {
                        return const Center(
                          child: Text(
                            'تعذر تحميل السورة',
                            style: TextStyle(color: AppColor.gold),
                          ),
                        );
                      }

                      final data = snapshot.data!;
                      final Map<String, dynamic> versesMap =
                          data['verse'] ?? {};

                      final List<MapEntry<int, String>> ayahs = [];
                      int index = 1;
                      versesMap.forEach((key, value) {
                        ayahs.add(MapEntry(index, value.toString()));
                        index++;
                      });

                      return Directionality(
                        textDirection: TextDirection.rtl,
                        child: ScrollablePositionedList.builder(
                          itemScrollController: _itemScrollController,
                          initialScrollIndex: ((_highlightedAyah ?? 1) - 1)
                              .clamp(0, ayahs.length - 1),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          itemCount: ayahs.length,
                          itemBuilder: (context, i) {
                            final ayahNumber = ayahs[i].key;
                            final ayahText = ayahs[i].value;
                            final isHighlighted = _highlightedAyah == ayahNumber;

                            return GestureDetector(
                              onTap: () => _toggleHighlight(ayahNumber),
                              child: Container(
                                width: double.infinity,
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: isHighlighted
                                      ? AppColor.gold.withValues(alpha: 0.9)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: AppColor.gold,
                                    width: 1.2,
                                  ),
                                ),
                                child: Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: '$ayahText ',
                                        style: TextStyle(
                                          color: isHighlighted
                                              ? AppColor.black
                                              : AppColor.gold,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      TextSpan(
                                        text: '[$ayahNumber]',
                                        style: TextStyle(
                                          color: isHighlighted
                                              ? AppColor.black
                                              : AppColor.gold,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: Image.asset(AppAssets.bottomDecoration),
    );
  }
}

class SurahDetails {
  static Future<Map<String, dynamic>> loadSurah(int surahNumber) async {
    int index = surahNumber < 1 ? surahNumber + 1 : surahNumber;
    String formattedIndex = index.toString().padLeft(3, '0');

    String jsonString;
    try {
      jsonString = await rootBundle.loadString(
        'assets/files/surah/surah_$formattedIndex.json',
      );
    } catch (_) {
      jsonString = await rootBundle.loadString(
        'assets/files/surah/surah_$index.json',
      );
    }

    return jsonDecode(jsonString);
  }
}
