import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:islamii_app/core/app_assets.dart';
import 'package:islamii_app/core/app_color.dart';
import 'package:islamii_app/screens/sura_model.dart';

class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> {
  final List<SuraModel> suraList = SuraModel.suraList;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // 1. الخلفية تفضل ثابته في الشاشة كلها مبتتحركش
          Positioned.fill(
            child: Image.asset(
              AppAssets.backgroundNative,
              fit: BoxFit.cover,
            ),
          ),

          // 2. المحتوى فقط هو اللي يسكرول فوق الخلفية
          SafeArea(
            child: SingleChildScrollView(
              child: SizedBox(
                // ارتفاع الـ Stack الممتد ليغطي قائمة السور كاملة مع إمكانية السكرول
                height: 470 + (suraList.length * 70.0),
                child: Stack(
                  children: [
                    Positioned(
                      top: 40,
                      left: 0,
                      right: 0,
                      child: Image.asset(
                        AppAssets.logo,
                        width: size.width * .8,
                        height: size.height * .15,
                      ),
                    ),
                    Positioned(
                      top: 170,
                      left: 20,
                      right: 20,
                      child: TextFormField(
                        decoration: InputDecoration(
                          hintText: "Surah Name",
                          hintStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: SvgPicture.asset(
                              AppAssets.quranSvgIcon,
                              width: 5,
                              height: 5,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: AppColor.gold),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: AppColor.gold),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    Positioned(
                      top: 250,
                      left: 20,
                      right: 20,
                      child: const Text(
                        "Most Recently",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 280,
                      left: 20,
                      right: 0,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: AppColor.gold,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.all(17.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment
                                          .start,
                                      children: [
                                        Text(
                                          "Al-Anbiya",
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 24,
                                          ),
                                        ),
                                        SizedBox(height: 10),
                                        Text(
                                          "الأنبياء",
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 24,
                                          ),
                                        ),
                                        SizedBox(height: 10),
                                        Text(
                                          "112 Verses",
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: 130,
                                    height: 130,
                                    child: Image.asset(
                                      AppAssets.moshafSvgIcon,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Container(
                              decoration: BoxDecoration(
                                color: AppColor.gold,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.all(17.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment
                                          .start,
                                      children: [
                                        Text(
                                          "Al-Fatiha",
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 24,
                                          ),
                                        ),
                                        SizedBox(height: 10),
                                        Text(
                                          "الفاتحه",
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 24,
                                          ),
                                        ),
                                        SizedBox(height: 10),
                                        Text(
                                          "7 Verses",
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: 150,
                                    height: 150,
                                    child: Image.asset(
                                      AppAssets.moshafSvgIcon,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 440,
                      left: 20,
                      right: 20,
                      child: const Text(
                        "Surahs List",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    // قائمة السور المترقمة بالكامل تحت عنوان Surahs List
                    Positioned(
                      top: 470,
                      left: 20,
                      right: 20,
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        // تعطيل السكرول الداخلي للست
                        padding: EdgeInsets.zero,
                        itemCount: suraList.length,
                        separatorBuilder: (context, index) =>
                            Divider(
                              color: AppColor.white,
                              thickness: .5,
                              indent: 30,
                              endIndent: 30,
                            ),
                        itemBuilder: (context, index) {
                          final sura = suraList[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 50,
                                  height: 50,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Image.asset(
                                        AppAssets.surNumberIcon,
                                        width: 50,
                                        height: 50,
                                      ),
                                      Positioned(
                                        top: 13,
                                        child: Text(
                                          "${sura.id}",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      sura.englishName,
                                      style: const TextStyle(
                                        color: AppColor.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      sura.versesCount,
                                      style: const TextStyle(
                                        color: AppColor.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                Text(
                                  sura.arabicName,
                                  style: const TextStyle(
                                    color: AppColor.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}