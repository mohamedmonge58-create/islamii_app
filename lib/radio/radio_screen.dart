import 'package:flutter/material.dart';
import 'package:islamii_app/core/app_assets.dart';
import 'package:islamii_app/core/app_color.dart';
import 'package:islamii_app/radio/radio_details.dart';
import 'package:islamii_app/radio/reciters_details.dart';

class RadioScreen extends StatelessWidget {
  const RadioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLight = AppColor.isLight(context);

    final tabBg = isLight ? AppColor.lightPrimaryLight : AppColor.gray;
    final tabIndicator = isLight ? AppColor.lightPrimaryEmerald : AppColor.gold;
    final selectedText = isLight ? AppColor.white : AppColor.black;
    final unselectedText = isLight ? AppColor.lightPrimaryText : AppColor.white;

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: AppColor.background(context),
        image: DecorationImage(
          image: const AssetImage(AppAssets.radioBackground),
          fit: BoxFit.cover,
          colorFilter: isLight
              ? ColorFilter.mode(
                  AppColor.lightBackgroundWarmIvory.withValues(alpha: 0.88),
                  BlendMode.screen,
                )
              : ColorFilter.mode(
                  AppColor.black.withValues(alpha: 0.7),
                  BlendMode.darken,
                ),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Image.asset(AppAssets.logo, width: size.width * .7),
          const SizedBox(height: 10),
          Expanded(
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  Container(
                    height: 46,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: tabBg,
                      borderRadius: BorderRadius.circular(12),
                      border: isLight
                          ? Border.all(color: AppColor.lightBordersDividers)
                          : null,
                    ),
                    child: TabBar(
                      labelStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Janna',
                      ),
                      dividerColor: Colors.transparent,
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicator: BoxDecoration(
                        color: tabIndicator,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      labelColor: selectedText,
                      unselectedLabelColor: unselectedText,
                      tabs: const [
                        Tab(text: "الإذاعة"),
                        Tab(text: "القراء"),
                      ],
                    ),
                  ),
                  const Expanded(
                    child: TabBarView(
                      children: [RadioDetails(), RecitersDetails()],
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
