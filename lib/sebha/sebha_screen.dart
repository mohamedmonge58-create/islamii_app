import 'package:flutter/cupertino.dart';
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
    final size = MediaQuery.of(context).size;
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(image: AssetImage(AppAssets.sebhaBackground,),
            fit: BoxFit.cover,

          ),
        ),
        child: Column(


          children: [
            SizedBox(height: 20,),

            Image.asset(
              AppAssets.logo,
              width: size.width * .7,
            ),
            Align(
              alignment: Alignment.center,
              child: Text(
                "سَبِّحِ اسْمَ رَبِّكَ الأعلى",
                style: TextStyle(
                  fontSize: 36,
                  color: AppColor.white,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Janna',
                ),
              ),
            ),
            SizedBox(height: 15),
            GestureDetector(
              onTap: onTasbeeh,
              child: SizedBox(
                width: size.width,
                height: size.height * .5,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      top: 0,
                      bottom: 335,
                      child: Image.asset(
                        AppAssets.partSebha,
                        width: size.width * .25,
                        height: size.width * .25,
                        fit: BoxFit.contain,
                      ),
                    ),
                    Positioned(
                      top: 70,
                      child: Image.asset(
                        AppAssets.sebhaBody,
                        width: size.width * .9,
                        height: size.height * .4,
                        fit: BoxFit.contain,
                      ),
                    ),

                    Positioned(
                      top: size.height * .22,
                      child: Column(
                        children: [
                          Text(
                            sebhaList[currentIndex].arabicName,

                            style: TextStyle(
                              color: AppColor.white,
                              fontSize: 36,
                              fontFamily: 'Janna',
                            ),
                          ),
                          SizedBox(height: 15),
                          Text(
                            "$counter",
                            style: TextStyle(
                                color: AppColor.white, fontSize: 36),
                          ),
                        ],
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
