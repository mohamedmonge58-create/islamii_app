import 'package:flutter/material.dart';
import 'package:islamii_app/core/app_color.dart';

class AzkarCard extends StatelessWidget {
  final String title;
  final String imagePath;
  final VoidCallback? onTap;

  const AzkarCard({
    super.key,
    required this.title,
    required this.imagePath,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 259,
        width: 185,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColor.gold, width: 1.5),
          color: Colors.black,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Image.asset(imagePath, fit: BoxFit.contain),
              ),
            ),
            Expanded(
              flex: 1,
              child: Center(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    fontFamily: 'Janna',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
