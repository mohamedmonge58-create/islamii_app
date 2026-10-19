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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 220,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColor.gold, width: 1.5),
          color: AppColor.black.withValues(alpha: 0.6),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Image.asset(imagePath, fit: BoxFit.contain),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              color: AppColor.gold.withValues(alpha: 0.15),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColor.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
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
