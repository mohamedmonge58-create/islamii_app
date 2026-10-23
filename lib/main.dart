import 'package:flutter/material.dart';
import 'package:islamii_app/core/app_color.dart';
import 'package:islamii_app/core/recent_sura_cash.dart';
import 'package:islamii_app/core/theme_controller.dart';
import 'package:islamii_app/splash_screen/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await RecentSuraCash.checkFirstLaunch();
  await ThemeController.instance.loadTheme();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.instance,
      builder: (context, themeMode, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          themeMode: themeMode,
          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: AppColor.lightBackgroundWarmIvory,
            colorScheme: const ColorScheme.light(
              primary: AppColor.lightPrimaryEmerald,
              secondary: AppColor.lightGoldAccent,
              surface: AppColor.lightCardBg,
              onSurface: AppColor.lightPrimaryText,
              error: AppColor.lightError,
            ),
            fontFamily: 'Janna',
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: AppColor.black,
            colorScheme: const ColorScheme.dark(
              primary: AppColor.gold,
              secondary: AppColor.golden,
              surface: AppColor.black,
              onSurface: AppColor.white,
            ),
            fontFamily: 'Janna',
          ),
          home: const SplashScreen(),
        );
      },
    );
  }
}
