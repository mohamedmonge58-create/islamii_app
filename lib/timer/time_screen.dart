// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:islamii_app/core/app_assets.dart';
import 'package:islamii_app/core/app_color.dart';
import 'package:islamii_app/timer/widgets/azkar_card.dart';
import 'package:islamii_app/timer/widgets/prayer_times_widget.dart';

import '../azkar/azkar_screen.dart';
import '../azkar/modules/azkar_data.dart';

class TimeScreen extends StatelessWidget {
  const TimeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              AppAssets.timeBackground,
            ), // نفس الخلفية بتاعة شاشة الراديو
            fit: BoxFit.cover,
            // colorFilter: ColorFilter.mode(
            //   AppColor.black.withOpacity(0.55),
            //   BlendMode.darken,
            // ),
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // الشعار
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Image.asset(
                      AppAssets.logo,
                      width: MediaQuery.of(context).size.width * .5,
                    ),
                  ),
                ),

                const PrayerTimesScreen(),

                const SizedBox(height: 20),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Azkar',
                    style: TextStyle(
                      color: AppColor.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Janna',
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: AzkarCard(
                          title: 'Evening Azkar',
                          imagePath: AppAssets.eveningAzkar,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AzkarScreen(
                                  title: "أذكار المساء",
                                  azkarList: AzkarData.eveningAzkar,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: AzkarCard(
                          title: 'Morning Azkar',
                          imagePath: AppAssets.morningAzkar,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AzkarScreen(
                                  title: "أذكار الصباح",
                                  azkarList: AzkarData.morningAzkar,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
