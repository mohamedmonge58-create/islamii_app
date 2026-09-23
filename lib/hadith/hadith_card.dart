import 'package:flutter/cupertino.dart';

import '../core/app_assets.dart';
import '../core/app_color.dart';
import '../modules/hadith_model.dart';
import 'hadith_background.dart';

class HadithCard extends StatelessWidget {
  final HadithModel hadithModel;

  const HadithCard({super.key, required this.hadithModel});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SafeArea(
      child: Container(
        width: double.infinity,
        height: size.height * .62,
        decoration: BoxDecoration(
          color: AppColor.gold,
          borderRadius: BorderRadius.circular(20),
          image: DecorationImage(
            image: AssetImage(AppAssets.hadithCardBackground),
          ),
        ),

        child: Stack(
          children: [
            HadithBackground(),

            Padding(
              padding: const EdgeInsets.only(
                top: 40,
                left: 24,
                right: 24,
                bottom: 40,
              ),
              child: SingleChildScrollView(
                child: Column(
                  spacing: 20,
                  children: [
                    Text(
                      hadithModel.hadithTitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        color: AppColor.black,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
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
      ),
    );
  }
}
