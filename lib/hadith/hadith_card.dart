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
    final isLight = AppColor.isLight(context);
    final cardBgColor = isLight ? AppColor.lightPrimaryEmerald : AppColor.gold;
    final textColor = isLight ? AppColor.white : AppColor.black;

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(
          image: const AssetImage(AppAssets.hadithCardBackground),
          fit: BoxFit.cover,
          colorFilter: isLight
              ? ColorFilter.mode(
                  AppColor.lightPrimaryDark.withValues(alpha: 0.15),
                  BlendMode.srcATop,
                )
              : null,
        ),
        boxShadow: isLight
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
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
                      color: textColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    hadithModel.hadithContent,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: textColor,
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
