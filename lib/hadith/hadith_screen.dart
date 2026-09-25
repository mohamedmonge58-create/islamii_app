import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:islamii_app/core/app_assets.dart';
import 'package:islamii_app/hadith/hadith_card.dart';
import 'package:islamii_app/modules/hadith_model.dart';

class HadithScreen extends StatefulWidget {
  const HadithScreen({super.key});

  @override
  State<HadithScreen> createState() => _HadithScreenState();
}

class _HadithScreenState extends State<HadithScreen> {
  List<HadithModel> _hadithList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHadithData();
  }

  Future<void> _loadHadithData() async {
    final List<HadithModel> loaded = [];

    for (int i = 1; i <= 50; i++) {
      try {
        final content = await rootBundle.loadString(
          "assets/files/hadith/h$i.txt",
        );
        final titleLength = content.indexOf("\n");
        if (titleLength == -1) continue; // ملف بدون سطر جديد، تجاهله بأمان

        final hadithTitle = content.substring(0, titleLength);
        final titleContent = content.substring(titleLength);

        loaded.add(
          HadithModel(hadithTitle: hadithTitle, hadithContent: titleContent),
        );
      } catch (e) {
        debugPrint('Failed to load hadith file h$i.txt: $e');
        // كمّل باقي الملفات حتى لو واحد فشل
      }
    }

    if (!mounted) return;
    setState(() {
      _hadithList = loaded;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(AppAssets.hadithBackground),
          fit: BoxFit.cover,
        ),
      ),
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              children: [
                SizedBox(height: constraints.maxHeight * 0.02),

                Image.asset(
                  AppAssets.logo,
                  width: size.width * .7,
                  fit: BoxFit.contain,
                ),

                SizedBox(height: constraints.maxHeight * 0.02),

                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _hadithList.isEmpty
                      ? const Center(
                    child: Text(
                      'لا توجد أحاديث متاحة حاليًا',
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                      : CarouselSlider(
                    items: _hadithList
                        .map((data) => HadithCard(hadithModel: data))
                        .toList(),
                    options: CarouselOptions(
                      height: double.infinity,
                      viewportFraction: 0.8,
                      initialPage: 0,
                      enableInfiniteScroll: true,
                      reverse: false,
                      autoPlay: false,
                      autoPlayInterval: const Duration(seconds: 800),
                      autoPlayAnimationDuration:
                      const Duration(milliseconds: 800),
                      autoPlayCurve: Curves.fastOutSlowIn,
                      enlargeCenterPage: true,
                      enlargeFactor: 0.3,
                      scrollDirection: Axis.horizontal,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}