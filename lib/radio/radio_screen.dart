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

    return Container(
      width: double.infinity,
      height: double.infinity,

      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(AppAssets.radioBackground),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            AppColor.black.withOpacity(0.7),
            BlendMode.darken,
          ),
        ),
      ),

      child: Column(
        children: [
          SizedBox(height: 20),
          Image.asset(AppAssets.logo, width: size.width * .7),
          Expanded(
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  Container(
                    height: 46,
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: AppColor.gray,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TabBar(
                      labelStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Janna',
                      ),
                      dividerColor: Colors.transparent,
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicator: BoxDecoration(
                        color: AppColor.gold,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      labelColor: AppColor.black,
                      unselectedLabelColor: AppColor.white,

                      tabs: [
                        Tab(text: "Radio"),
                        Tab(text: "Reciters"),
                      ],
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        SingleChildScrollView(child: RadioDetails()),
                        SingleChildScrollView(child: RecitersDetails()),
                      ],
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
