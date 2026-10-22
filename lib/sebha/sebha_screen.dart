import 'package:flutter/material.dart';
import 'package:islamii_app/core/app_assets.dart';
import 'package:islamii_app/core/app_color.dart';
import 'package:islamii_app/modules/sebha_model.dart';

class SebhaScreen extends StatefulWidget {
  const SebhaScreen({super.key});

  @override
  State<SebhaScreen> createState() => _SebhaScreenState();
}

class _SebhaScreenState extends State<SebhaScreen> {
  final List<SebhaModel> sebhaList = SebhaModel.sebhaList;
  int counter = 0;
  int currentIndex = 0;

  void onTasbeeh() {
    setState(() {
      counter++;

      if (counter == 33) {
        counter = 0;

        if (currentIndex < sebhaList.length - 1) {
          currentIndex++;
        } else {
          currentIndex = 0;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppAssets.sebhaBackground),
            fit: BoxFit.cover,
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final height = constraints.maxHeight;

            return Column(
              children: [
                SizedBox(height: height * 0.025),

                Image.asset(AppAssets.logo, width: width * 0.7),

                SizedBox(height: height * 0.015),

                Text(
                  'سَبِّحِ اسْمَ رَبِّكَ الأعلى',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: width * 0.075,
                    color: AppColor.white,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Janna',
                  ),
                ),

                SizedBox(height: height * 0.015),

                Expanded(
                  child: GestureDetector(
                    onTap: onTasbeeh,
                    child: LayoutBuilder(
                      builder: (context, area) {
                        final sebhaWidth = area.maxWidth;
                        final sebhaHeight = area.maxHeight;

                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            Positioned(
                              top: 0,
                              child: Image.asset(
                                AppAssets.partSebha,
                                width: sebhaWidth * 0.25,
                                height: sebhaHeight * 0.20,
                                fit: BoxFit.contain,
                              ),
                            ),

                            Positioned.fill(
                              child: Align(
                                alignment: Alignment.center,
                                child: Image.asset(
                                  AppAssets.sebhaBody,
                                  width: sebhaWidth * 0.9,
                                  height: sebhaHeight * 0.88,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),

                            Align(
                              alignment: const Alignment(0, 0.05),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: width * 0.12,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        sebhaList[currentIndex].arabicName,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: AppColor.white,
                                          fontSize: width * 0.075,
                                          fontFamily: 'Janna',
                                        ),
                                      ),
                                    ),

                                    SizedBox(height: height * 0.015),

                                    Text(
                                      '$counter',
                                      style: TextStyle(
                                        color: AppColor.white,
                                        fontSize: width * 0.075,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
