import 'package:flutter/cupertino.dart';

import '../core/app_assets.dart';
import '../core/app_color.dart';

class HadithBackground extends StatelessWidget {
  const HadithBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final isLight = AppColor.isLight(context);
    final decorationColor = isLight ? AppColor.white : AppColor.black;

    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset(
                  AppAssets.leftCornerBlack,
                  width: 90,
                  height: 90,
                  color: decorationColor,
                ),
                Image.asset(
                  AppAssets.rightCornerBlack,
                  width: 90,
                  height: 90,
                  color: decorationColor,
                ),
              ],
            ),
          ),
          Image.asset(AppAssets.bottomDecoration, color: decorationColor),
        ],
      ),
    );
  }
}
