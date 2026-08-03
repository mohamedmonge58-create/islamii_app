import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:islamii_app/core/app_assets.dart';
import 'package:islamii_app/core/app_color.dart';

class HadithScreen extends StatelessWidget {
  const HadithScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(AppAssets.hadithBackground),
          fit: BoxFit.fill,
        ),
      ),

      child: Column(
        children: [
          Image.asset(
            AppAssets.logo,
            width: size.width * .6,
            height: size.height * .3,
          ),

          Container(
            decoration: BoxDecoration(
              color: AppColor.gold,
              borderRadius: BorderRadius.circular(20),
            ),
            width: 310,
            height: 510,

            child: PageView(
              scrollDirection: Axis.horizontal,
              children: [
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,

                        children: [
                          Image.asset(
                            AppAssets.leftCornerBlack,
                            width: 80,
                            height: 90,
                          ),

                          Text(
                            "الحديث الاول",
                            style: TextStyle(
                              fontSize: 24,
                              color: AppColor.black,
                              fontWeight: FontWeight.w700,
                            ),
                          ),

                          Image.asset(
                            AppAssets.rightCornerBlack,
                            width: 80,
                            height: 90,
                          ),
                        ],
                      ),
                    ),
                    Stack(
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: Text("الحديث الشريف "),
                        ),
                        Image.asset(
                          AppAssets.hadithCardBackground,
                          width: 310,
                          height: 300,
                        ),
                      ],
                    ),
                    Spacer(),

                    Align(
                      alignment: Alignment.center,
                      child: Image.asset(AppAssets.mosqueBlack),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
