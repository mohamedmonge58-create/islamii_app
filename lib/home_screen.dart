import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:islamii_app/core/app_assets.dart';
import 'package:islamii_app/core/app_color.dart';
import 'package:islamii_app/core/theme_controller.dart';
import 'package:islamii_app/hadith/hadith_screen.dart';
import 'package:islamii_app/quran/quran_screen.dart';
import 'package:islamii_app/radio/radio_screen.dart';
import 'package:islamii_app/timer/time_screen.dart';

class NavItem {
  final String iconPath;
  final String title;

  NavItem({required this.iconPath, required this.title});
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    QuranScreen(),
    HadithScreen(),
    RadioScreen(),
    TimeScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background(context),
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Stack(
          children: [
            IndexedStack(index: _selectedIndex, children: _pages),
            const Positioned(top: 10, left: 16, child: ThemeToggleButton()),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final isLight = AppColor.isLight(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => ThemeController.instance.toggleTheme(),
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isLight
                ? AppColor.lightPrimaryEmerald.withValues(alpha: 0.15)
                : AppColor.gold.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isLight ? AppColor.lightPrimaryEmerald : AppColor.gold,
              width: 1.2,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isLight ? Icons.wb_sunny_rounded : Icons.nightlight_round,
                size: 18,
                color: isLight ? AppColor.lightPrimaryEmerald : AppColor.gold,
              ),
              const SizedBox(width: 6),
              Text(
                isLight ? "نهاري" : "ليلي",
                style: TextStyle(
                  color: isLight ? AppColor.lightPrimaryEmerald : AppColor.gold,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Janna',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  List<NavItem> get _items => [
    NavItem(iconPath: AppAssets.quranIcon, title: "القرآن"),
    NavItem(iconPath: AppAssets.booksIcon, title: "الحديث"),
    NavItem(iconPath: AppAssets.radioIcon, title: "الراديو"),
    NavItem(iconPath: AppAssets.timerIcon, title: "المواقيت"),
  ];

  @override
  Widget build(BuildContext context) {
    final isLight = AppColor.isLight(context);

    return Container(
      decoration: BoxDecoration(
        color: AppColor.navBarBg(context),
        border: Border(
          top: BorderSide(color: AppColor.border(context), width: 1.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isLight ? 0.08 : 0.5),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(_items.length, (index) {
            bool isSelected = selectedIndex == index;

            return InkWell(
              onTap: () => onTap(index),
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColor.navBarSelected(context)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: isSelected
                      ? Border.all(
                          color: isLight
                              ? AppColor.lightPrimaryDark
                              : AppColor.white,
                          width: 1,
                        )
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      _items[index].iconPath,
                      width: 22,
                      height: 22,
                      colorFilter: ColorFilter.mode(
                        isSelected
                            ? AppColor.navBarSelectedText(context)
                            : AppColor.navBarUnselected(context),
                        BlendMode.srcIn,
                      ),
                    ),
                    if (isSelected) ...[
                      const SizedBox(width: 8),
                      Text(
                        _items[index].title,
                        style: TextStyle(
                          color: AppColor.navBarSelectedText(context),
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Janna',
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
