import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:islamii_app/core/app_assets.dart';
import 'package:islamii_app/core/app_color.dart';
import 'package:islamii_app/hadith/hadith_screen.dart';
import 'package:islamii_app/quran//quran_screen.dart';
import 'package:islamii_app/radio/radio_screen.dart';
import 'package:islamii_app/sebha/sebha_screen.dart';

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

  final List<Widget> _pages = [
    QuranScreen(),
    HadithScreen(),
    SebhaScreen(),
    RadioScreen(),

    Center(child: Text("Time Screen", style: TextStyle(color: Colors.white, fontSize: 20))),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,


      body: _pages[_selectedIndex],
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

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  List<NavItem> get _items => [
    NavItem(iconPath: AppAssets.quranIcon, title: "Quran"),
    NavItem(iconPath: AppAssets.booksIcon, title: "Hadith"),
    NavItem(iconPath: AppAssets.sebhaIcon, title: "Sebha"),
    NavItem(iconPath: AppAssets.radioIcon, title: "Radio"),
    NavItem(iconPath: AppAssets.timerIcon, title: "Time"),
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      color: AppColor.gold,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_items.length, (index) {
          bool isSelected = selectedIndex == index;

          return GestureDetector(
            onTap: () => onTap(index),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration:  Duration(milliseconds: 200),
                  padding:  EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColor.gray : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: SvgPicture.asset(
                    _items[index].iconPath,
                    width: size.width * .06,
                    height: size.height * .03,
                    colorFilter: ColorFilter.mode(
                      isSelected ? AppColor.white : AppColor.black,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                 SizedBox(height: 2),
                if (isSelected)
                  Text(
                    _items[index].title,
                    style:  TextStyle(
                      color: AppColor.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                else
                   SizedBox(height: 14),
              ],
            ),
          );
        }),
      ),
    );
  }
}