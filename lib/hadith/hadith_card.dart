import 'package:flutter/material.dart';

import '../core/app_assets.dart';
import '../core/app_color.dart';
import '../modules/hadith_model.dart';
import 'hadith_background.dart';

class HadithCard extends StatelessWidget {
  final HadithModel hadithModel;

  const HadithCard({super.key, required this.hadithModel});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity, // ياخد كل المساحة المتاحة من الأب (الكاروسيل)
      decoration: BoxDecoration(
        color: AppColor.gold,
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(
          image: AssetImage(AppAssets.hadithCardBackground),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          const HadithBackground(),

          Padding(
            padding: const EdgeInsets.only(
              top: 40,
              left: 24,
              right: 24,
              bottom: 40,
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Text(
                    hadithModel.hadithTitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      color: AppColor.black,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    hadithModel.hadithContent,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColor.black,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}