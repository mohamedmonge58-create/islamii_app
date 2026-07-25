import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:islamii_app/core/app_assets.dart';
import 'package:islamii_app/core/app_color.dart';
import 'package:islamii_app/home_screen.dart';
import 'package:islamii_app/modules/sura_model.dart';

class QuranView extends StatelessWidget {
  final SuraModel sura;

  const QuranView({super.key, required this.sura});

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
            Navigator.push(
              context,

              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          },
          icon: Icon(Icons.arrow_back, color: AppColor.gold),
        ),
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 80),
          child: Text(
            sura.englishName,
            style: TextStyle(
              color: AppColor.gold,
              fontSize: 20,
              fontWeight: FontWeight.bold,
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
                      sura.arabicName,
                      style: TextStyle(
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
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: FutureBuilder<Map<String, dynamic>>(
                    future: SurahDetails.loadSurah(sura.id),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: AppColor.gold,
                          ),
                        );
                      }

                      final data = snapshot.data!;
                      Map<String, dynamic> versesMap = data['verse'] ?? {};

                      StringBuffer fullText = StringBuffer();
                      int index = 1;
                      versesMap.forEach((key, value) {
                        fullText.write("$value [$index] ");
                        index++;
                      });

                      return Text(
                        fullText.toString(),
                        style: TextStyle(
                          color: AppColor.gold,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          height: 2.5,
                        ),
                        textAlign: TextAlign.center,
                      );
                    },
                  ),
                ),
              ),
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
