import 'dart:async';

import 'package:flutter/material.dart';
import 'package:islamii_app/home_screen.dart';
import 'package:islamii_app/splash_screen/onboarding_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/app_assets.dart';
import '../core/app_color.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    // 1. وقت الانتظار للسبلاش سكرين (مثلاً 2 ثانية)
    await Future.delayed(const Duration(seconds: 3));

    // 2. فحص ذاكرة الهاتف
    final prefs = await SharedPreferences.getInstance();
    final bool isSeen = prefs.getBool('isSeen') ?? false;

    if (!mounted) return;

    // 3. التوجيه بناءً على الحالة
    if (isSeen) {
      // لو فتح التطبيق قبل كده -> يدخل على HomeScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } else {
      // لو أول مرة يفتحه -> يدخل على OnboardingScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => OnboardingScreen()),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              AppAssets.background,
              fit: BoxFit.cover,
            ),
          ),

          Positioned(
            top: 45,
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset(
                AppAssets.mosque,
                width: 270,
                height: 150,
              ),
            ),
          ),

          Positioned(
            top: 0,
            left: 290,
            right: 0,
            child: Center(
              child: Image.asset(
                AppAssets.glow,
                width: 70,
                height: 300,
              ),
            ),
          ),

          Positioned(
            top: 10,
            left: 0,
            bottom: 170,

            child: Image.asset(
              AppAssets.shape2,
              width: 90,
            ),
          ),
          Positioned(
              top:200,
              left: 120,
              bottom: 120,
              right: 120,

              child: Image.asset(
            AppAssets.islamiiLogo,
            width: 80,

          )),
          Positioned(
            bottom: 120,
            left: 310,
            child: Center(
              child: Image.asset(
                AppAssets.shape1,
                width: 90,
              ),
              
            ),
            
          ),
          Positioned(
            top: 700,
            bottom: 0,
            left: 50,
            right: 50,child:
            Center(child: Text("Supervised by Mohamed Monge" , style: TextStyle(fontSize: 16 , fontWeight: FontWeight(400) , color: AppColor.white , fontFamily: "poppins"))
            ,)



          )],
      ),
    );
  }
}
