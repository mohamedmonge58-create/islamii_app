// lib/core/notched_top_clipper.dart
import 'package:flutter/material.dart';

class NotchedTopClipper extends CustomClipper<Path> {
  final double cornerRadius;
  final double tabWidthFraction; // نسبة عرض "التلة" فوق من عرض الكارت كله
  final double tabHeight; // ارتفاع التلة فوق الحد العلوي للكارت
  final double curveWidth; // عرض الانحناء الجانبي (الكتف) بين التلة والجسم

  NotchedTopClipper({
    this.cornerRadius = 28,
    this.tabWidthFraction = 0.52,
    this.tabHeight = 36,
    this.curveWidth = 40,
  });

  @override
  Path getClip(Size size) {
    final path = Path();
    final w = size.width;
    final h = size.height;

    final tabWidth = w * tabWidthFraction;
    final tabLeft = (w - tabWidth) / 2;
    final tabRight = tabLeft + tabWidth;

    // نبدأ من أعلى شمال الجسم الرئيسي (تحت التلة)
    path.moveTo(0, tabHeight + cornerRadius);

    // الزاوية الشمال العليا (دائرية) للجسم الرئيسي
    path.quadraticBezierTo(0, tabHeight, cornerRadius, tabHeight);

    // خط أفقي لحد بداية الكتف الشمال بتاع التلة
    path.lineTo(tabLeft - curveWidth, tabHeight);

    // الكتف الشمال: من مستوى الجسم لأعلى لمستوى التلة
    path.quadraticBezierTo(
      tabLeft,
      tabHeight,
      tabLeft,
      tabHeight - (tabHeight * 0.4),
    );
    path.quadraticBezierTo(tabLeft, 0, tabLeft + cornerRadius * 0.6, 0);

    // أعلى التلة (خط مستقيم فوق)
    path.lineTo(tabRight - cornerRadius * 0.6, 0);

    // الكتف اليمين: نزول من أعلى التلة لمستوى الجسم
    path.quadraticBezierTo(
      tabRight,
      0,
      tabRight,
      tabHeight - (tabHeight * 0.4),
    );
    path.quadraticBezierTo(
      tabRight,
      tabHeight,
      tabRight + curveWidth,
      tabHeight,
    );

    // خط أفقي لحد الزاوية اليمين العليا للجسم
    path.lineTo(w - cornerRadius, tabHeight);

    // الزاوية اليمين العليا (دائرية)
    path.quadraticBezierTo(w, tabHeight, w, tabHeight + cornerRadius);

    // النزول على الحافة اليمين للجسم
    path.lineTo(w, h - cornerRadius);

    // الزاوية اليمين السفلية
    path.quadraticBezierTo(w, h, w - cornerRadius, h);

    // الحافة السفلية
    path.lineTo(cornerRadius, h);

    // الزاوية الشمال السفلية
    path.quadraticBezierTo(0, h, 0, h - cornerRadius);

    // الرجوع لنقطة البداية
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
