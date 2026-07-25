import 'package:flutter/material.dart';
import 'package:islamii_app/core/app_assets.dart';
import 'package:islamii_app/core/app_color.dart';

class Onboarding3 extends StatelessWidget {
  const Onboarding3({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColor.black,
      body:  Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: size.height * 0.02 ,),
            Image.asset(AppAssets.logo , width: size.width * 0.8,
              height: size.height * 0.2,),

            Image.asset(AppAssets.moshaf ,width: size.width *.9, height: size.height *.5,),
            SizedBox(height: size.height * 0.02 ,),

            Text("Reading the Quran " , style: TextStyle(fontSize: 20 , fontWeight: FontWeight(500) , color: AppColor.gold ,),),
            SizedBox(height: size.height * 0.02 ,),

            Text(" Read, and your Lord is the Most \nGenerous  " , textAlign: TextAlign.center , style: TextStyle(fontSize: 20 , fontWeight: FontWeight(500) , color: AppColor.gold ,),),

          ],
        ),
      ),


    );
  }
}
