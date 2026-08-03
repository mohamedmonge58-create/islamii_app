import 'package:flutter/material.dart';
import 'package:islamii_app/core/app_assets.dart';
import 'package:islamii_app/core/app_color.dart';

class RecitersDetails extends StatelessWidget {
  const RecitersDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Column(
          children: [
            SizedBox(height: 18),
            Container(
              width: 390,
              height: 133,

              margin: EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: AppColor.gold,
              ),
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Image.asset(
                      AppAssets.mosqueRadio,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),

                  Column(
                    children: [
                      SizedBox(height: 20),

                      Text(
                        "Ibrahim Al-Akdar",
                        style: TextStyle(
                          color: AppColor.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Janna',
                        ),
                      ),

                      Spacer(),

                      Padding(
                        padding: const EdgeInsets.only(left: 50, top: 19),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.play_arrow_sharp, size: 45),

                            SizedBox(width: 20),

                            Icon(Icons.volume_up, size: 30),
                          ],
                        ),
                      ),

                      SizedBox(height: 20),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 18),
            Container(
              width: 390,
              height: 133,

              margin: EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: AppColor.gold,
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 80,
                    left: 1,
                    right: 1,
                    child: Image.asset(
                      AppAssets.voice,
                      width: 520,
                      fit: BoxFit.cover,
                    ),
                  ),

                  Column(
                    children: [
                      SizedBox(height: 20),

                      Text(
                        "Akram Alalaqmi",
                        style: TextStyle(
                          color: AppColor.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Janna',
                        ),
                      ),

                      // Spacer(),
                      Padding(
                        padding: const EdgeInsets.only(left: 50, top: 19),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.pause, size: 45),

                            SizedBox(width: 20),

                            Icon(Icons.volume_off_sharp, size: 30),
                          ],
                        ),
                      ),

                      SizedBox(height: 20),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 18),
            Container(
              width: 390,
              height: 133,

              margin: EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: AppColor.gold,
              ),
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Image.asset(
                      AppAssets.mosqueRadio,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),

                  Column(
                    children: [
                      SizedBox(height: 20),

                      Text(
                        "Majed Al-Enezi",
                        style: TextStyle(
                          color: AppColor.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Janna',
                        ),
                      ),

                      Spacer(),

                      Padding(
                        padding: const EdgeInsets.only(left: 50, top: 19),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.play_arrow_sharp, size: 45),

                            SizedBox(width: 20),

                            Icon(Icons.volume_up, size: 30),
                          ],
                        ),
                      ),

                      SizedBox(height: 20),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 18),
            Container(
              width: 390,
              height: 133,

              margin: EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: AppColor.gold,
              ),
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Image.asset(
                      AppAssets.mosqueRadio,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),

                  Column(
                    children: [
                      SizedBox(height: 20),

                      Text(
                        "Malik shaibat Alhamed",
                        style: TextStyle(
                          color: AppColor.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Janna',
                        ),
                      ),

                      Spacer(),

                      Padding(
                        padding: const EdgeInsets.only(left: 50, top: 19),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.play_arrow_sharp, size: 45),

                            SizedBox(width: 20),

                            Icon(Icons.volume_up, size: 30),
                          ],
                        ),
                      ),

                      SizedBox(height: 20),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
