import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends ValueNotifier<ThemeMode> {
  static final ThemeController instance = ThemeController._internal();

  factory ThemeController() => instance;

  ThemeController._internal() : super(ThemeMode.dark) {
    loadTheme();
  }

  static const String _prefKey = 'theme_mode_key';

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefKey);
    if (saved == 'light') {
      value = ThemeMode.light;
    } else if (saved == 'dark') {
      value = ThemeMode.dark;
    } else if (saved == 'system') {
      value = ThemeMode.system;
    }
  }

  Future<void> toggleTheme() async {
    if (value == ThemeMode.light) {
      await setThemeMode(ThemeMode.dark);
    } else {
      await setThemeMode(ThemeMode.light);
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    value = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, mode.name);
  }

  bool isLight(BuildContext context) {
    if (value == ThemeMode.light) return true;
    if (value == ThemeMode.dark) return false;
    return MediaQuery.of(context).platformBrightness == Brightness.light;
  }
}
