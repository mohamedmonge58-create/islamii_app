import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:islamii_app/core/app_assets.dart';
import 'package:islamii_app/core/app_color.dart';
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
        if (titleLength == -1) continue;

        final hadithTitle = content.substring(0, titleLength);
        final titleContent = content.substring(titleLength);

        loaded.add(
          HadithModel(hadithTitle: hadithTitle, hadithContent: titleContent),
        );
      } catch (e) {
        debugPrint('Failed to load hadith file h$i.txt: $e');
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
    final isLight = AppColor.isLight(context);

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: AppColor.background(context),
        image: DecorationImage(
          image: const AssetImage(AppAssets.hadithBackground),
          fit: BoxFit.cover,
          colorFilter: isLight
              ? ColorFilter.mode(
                  AppColor.lightBackgroundWarmIvory.withValues(alpha: 0.88),
                  BlendMode.screen,
                )
              : null,
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
                      ? Center(
                          child: CircularProgressIndicator(
                            color: AppColor.primary(context),
                          ),
                        )
                      : _hadithList.isEmpty
                      ? Center(
                          child: Text(
                            'لا توجد أحاديث متاحة حاليًا',
                            style: TextStyle(
                              color: AppColor.primaryText(context),
                              fontFamily: 'Janna',
                            ),
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
                            autoPlayAnimationDuration: const Duration(
                              milliseconds: 800,
                            ),
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
