import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
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
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadHadithData();
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
          fit: BoxFit.fill,
        ),
      ),

      child: Column(
        children: [
          SizedBox(height: 20),

          IImage.asset(
            AppAssets.logo,
            width: size.width * .7,
          ),
          SizedBox(height: 20,),

          SafeArea(
            child: CarouselSlider(
                items:
                _hadithList
                    .map((data) => HadithCard(hadithModel: data,))
                    .toList()
                ,
                options: CarouselOptions(
                  height: size.height * .62,
                  aspectRatio: 16 / 9,
                  viewportFraction: 0.8,
                  initialPage: 0,
                  enableInfiniteScroll: true,
                  reverse: false,
                  autoPlay: false,
                  autoPlayInterval: Duration(seconds: 800),
                  autoPlayAnimationDuration: Duration(milliseconds: 800),
                  autoPlayCurve: Curves.fastOutSlowIn,
                  enlargeCenterPage: true,
                  enlargeFactor: 0.3,
                  scrollDirection: Axis.horizontal,
                )
            ),
          )

        ],
      ),
    );
  }

  List<HadithModel> _hadithList = [];

  Future<void> _loadHadithData() async {
    for (int i = 1; i <= 50; i++) {
      final content = await rootBundle.loadString(
          "assets/files/hadith/h$i.txt");
      final titleLength = content.indexOf("\n");
      final hadithTitle = content.substring(0, titleLength);
      final titleContent = content.substring(titleLength);

      final hadithData = HadithModel(
          hadithTitle: hadithTitle,
          hadithContent: titleContent
      );
      _hadithList.add(hadithData);
    }
    setState(() {

    });
  }


}
