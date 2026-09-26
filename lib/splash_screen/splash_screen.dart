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
    await Future.delayed(const Duration(seconds: 3));

    final prefs = await SharedPreferences.getInstance();
    final bool isSeen = prefs.getBool('isSeen') ?? false;

    if (!mounted) return;

    if (isSeen) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => OnboardingScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery
        .of(context)
        .size;

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
            top: size.height * 0.055,
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset(
                AppAssets.mosque,
                width: size.width * 0.69,
                height: size.height * 0.18,
                fit: BoxFit.contain,
              ),
            ),
          ),

          Positioned(
            top: 0,
            left: size.width * 0.74,
            right: 0,
            child: Center(
              child: Image.asset(
                AppAssets.glow,
                width: size.width * 0.18,
                height: size.height * 0.37,
                fit: BoxFit.contain,
              ),
            ),
          ),

          Positioned(
            top: size.height * 0.012,
            left: 0,
            bottom: size.height * 0.21,
            child: Image.asset(
              AppAssets.shape2,
              width: size.width * 0.23,
              fit: BoxFit.contain,
            ),
          ),

          Positioned(
            top: size.height * 0.4,
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset(
                AppAssets.islamiiLogo,
                width: size.width * 0.35,
                fit: BoxFit.cover,
              ),
            ),
          ),

          Positioned(
            bottom: size.height * 0.15,
            left: size.width * 0.79,
            child: Image.asset(
              AppAssets.shape1,
              width: size.width * 0.23,
              fit: BoxFit.contain,
            ),
          ),

          Positioned(
            bottom: size.height * 0.06,
            left: size.width * 0.1,
            right: size.width * 0.1,
            child: Center(
              child: Text(
                "Supervised by Mohamed Monge",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: AppColor.white,
                  fontFamily: "poppins",
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}