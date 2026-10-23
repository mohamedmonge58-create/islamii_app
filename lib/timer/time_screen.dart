import 'package:flutter/material.dart';
import 'package:islamii_app/core/app_assets.dart';
import 'package:islamii_app/core/app_color.dart';
import 'package:islamii_app/qibla/qibla_screen.dart';
import 'package:islamii_app/timer/widgets/azkar_card.dart';
import 'package:islamii_app/timer/widgets/prayer_times_widget.dart';

import '../azkar/azkar_screen.dart';
import '../azkar/modules/azkar_data.dart';

class TimeScreen extends StatelessWidget {
  const TimeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLight = AppColor.isLight(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: AppColor.background(context),
          image: DecorationImage(
            image: const AssetImage(AppAssets.timeBackground),
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
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo Header
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Image.asset(
                      AppAssets.logo,
                      width: size.width * .45,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),

                // Prayer Times Main Widget
                const PrayerTimesWidget(),

                const SizedBox(height: 20),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'الأذكار والدعاء',
                    style: TextStyle(
                      color: AppColor.primaryText(context),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Janna',
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Azkar Grid (4 Categories)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 0.85,
                    children: [
                      // 1. أذكار الصباح
                      AzkarCard(
                        title: 'أذكار الصباح',
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

                      // 2. أذكار المساء
                      AzkarCard(
                        title: 'أذكار المساء',
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

                      // 3. أذكار بعد الصلاة المفروضة
                      AzkarCard(
                        title: 'أذكار بعد الصلاة ',
                        imagePath: AppAssets.afterPrayer,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AzkarScreen(
                                title: "أذكار بعد الصلاة ",
                                azkarList: AzkarData.afterPrayerAzkar,
                              ),
                            ),
                          );
                        },
                      ),

                      // 4. الأدعية والأذكار اليومية
                      AzkarCard(
                        title: 'الأدعية والأذكار اليومية',
                        imagePath: AppAssets.dailyDua,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AzkarScreen(
                                title: "الأدعية والأذكار اليومية",
                                azkarList: AzkarData.dailyDuaAzkar,
                              ),
                            ),
                          );
                        },
                      ),
                      AzkarCard(
                        title: 'اتجاه القبلة',
                        imagePath: AppAssets.qbla,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const QiblaScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
