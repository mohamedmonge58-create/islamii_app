import 'package:flutter/material.dart';

abstract class AppColor {
  // Dark Mode Palette (Original)
  static const Color black = Color(0xFF202020);
  static const Color white = Color(0xFFFFFFFF);
  static const Color gold = Color(0xFFE2BE7F);
  static const Color gray = Color(0xFF51473E);
  static const Color golden = Color(0xFFB19768);

  // Light Mode Palette
  static const Color lightPrimaryEmerald = Color(0xFF087F5B);
  static const Color lightPrimaryDark = Color(0xFF066747);
  static const Color lightPrimaryLight = Color(0xFFE8F3ED);
  static const Color lightBackgroundWarmIvory = Color(0xFFF8F7F2);
  static const Color lightCardBg = Color(0xFFFFFFFF);
  static const Color lightGoldAccent = Color(0xFFD4A84F);
  static const Color lightPrimaryText = Color(0xFF26352F);
  static const Color lightSecondaryText = Color(0xFF68756E);
  static const Color lightBordersDividers = Color(0xFFE4E8E2);
  static const Color lightError = Color(0xFFB42318);

  static bool isLight(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light;
  }

  // Theme-aware Dynamic Color Getters
  static Color primary(BuildContext context) =>
      isLight(context) ? lightPrimaryEmerald : gold;

  static Color primaryDark(BuildContext context) =>
      isLight(context) ? lightPrimaryDark : black;

  static Color primaryLight(BuildContext context) =>
      isLight(context) ? lightPrimaryLight : gray;

  static Color background(BuildContext context) =>
      isLight(context) ? lightBackgroundWarmIvory : black;

  static Color cardBackground(BuildContext context) =>
      isLight(context) ? lightCardBg : gold;

  static Color cardContentText(BuildContext context) =>
      isLight(context) ? lightPrimaryText : black;

  static Color primaryText(BuildContext context) =>
      isLight(context) ? lightPrimaryText : white;

  static Color secondaryText(BuildContext context) =>
      isLight(context) ? lightSecondaryText : white.withValues(alpha: 0.7);

  static Color border(BuildContext context) =>
      isLight(context) ? lightBordersDividers : gold.withValues(alpha: 0.3);

  static Color goldAccent(BuildContext context) =>
      isLight(context) ? lightGoldAccent : gold;

  static Color cardButtonColor(BuildContext context) =>
      isLight(context) ? lightPrimaryEmerald : black;

  static Color cardButtonIconColor(BuildContext context) =>
      isLight(context) ? white : black;

  static Color navBarBg(BuildContext context) =>
      isLight(context) ? lightCardBg : black;

  static Color navBarSelected(BuildContext context) =>
      isLight(context) ? lightPrimaryEmerald : gold;

  static Color navBarSelectedText(BuildContext context) =>
      isLight(context) ? white : black;

  static Color navBarUnselected(BuildContext context) =>
      isLight(context) ? lightSecondaryText : white.withValues(alpha: 0.7);

  static Color searchBarFill(BuildContext context) =>
      isLight(context) ? lightCardBg : black.withValues(alpha: 0.55);

  static Color searchBarBorder(BuildContext context) =>
      isLight(context) ? lightPrimaryEmerald : gold;

  static Color searchBarText(BuildContext context) =>
      isLight(context) ? lightPrimaryText : white;
}
