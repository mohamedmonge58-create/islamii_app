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
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppAssets.timeBackground),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo Header
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Image.asset(
                      AppAssets.logo,
                      width: size.width * .45,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),

                // Prayer Times Main Widget
                const PrayerTimesWidget(),

                const SizedBox(height: 24),

                // Azkar Section Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Azkar',
                    style: TextStyle(
                      color: AppColor.gold,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Janna',
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Azkar Cards
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

                const SizedBox(height: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
