import 'package:flutter/material.dart';
import 'package:islamii_app/core/app_color.dart';
import 'package:islamii_app/home_screen.dart';
import 'package:islamii_app/splash_screen/onboarding_1.dart';
import 'package:islamii_app/splash_screen/onboarding_2.dart';
import 'package:islamii_app/splash_screen/onboarding_3.dart';
import 'package:islamii_app/splash_screen/onboarding_4.dart';
import 'package:islamii_app/splash_screen/onboarding_5.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<Widget> _onboardingPages = const [
    Onboarding1(),
    Onboarding2(),
    Onboarding3(),
    Onboarding4(),
    Onboarding5(),
  ];

  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isSeen', true);

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen()),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColor.black,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _onboardingPages.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return _onboardingPages[index];
                  },
                ),
              ),

              Container(
                height: size.height * 0.1,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (_currentIndex > 0)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: () {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: Text(
                            "Back",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppColor.gold,
                            ),
                          ),
                        ),
                      ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_onboardingPages.length, (index) {
                        bool isActive = index == _currentIndex;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          height: 8,
                          width: isActive ? 24 : 8,
                          decoration: BoxDecoration(
                            color: isActive ? AppColor.gold : AppColor.gray,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        );
                      }),
                    ),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          if (_currentIndex < _onboardingPages.length - 1) {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          } else {
                            _finishOnboarding();
                          }
                        },
                        child: Text(
                          _currentIndex == _onboardingPages.length - 1
                              ? "Finish"
                              : "Next",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColor.gold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}