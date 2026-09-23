import 'package:shared_preferences/shared_preferences.dart';

abstract class RecentSuraCash {
  static const String firstLaunchKey = "first_launch";
  static const String recentSuraKey = 'recent';
  static const int _maxRecentSuras = 5;

  static Future<void> addsura(int suraNumBer) async {
    final prefs = await SharedPreferences.getInstance();
    final recent = prefs.getStringList('recent') ?? <String>[];

    recent.remove(suraNumBer.toString());
    recent.insert(0, suraNumBer.toString());
    final trimmedRecent = recent.take(_maxRecentSuras).toList();
    await prefs.setStringList('recent', trimmedRecent);
  }

  static Future<List<int>> getRecentSuras() async {
    final prefs = await SharedPreferences.getInstance();
    final recent = prefs.getStringList('recent') ?? <String>[];
    return recent.map((e) => int.parse(e)).toList();
  }

  static Future<void> checkFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();

    final isFirst = prefs.getBool(firstLaunchKey) ?? true;

    if (isFirst) {
      await prefs.remove(recentSuraKey);
      await prefs.setBool(firstLaunchKey, false);
    }
  }
}
