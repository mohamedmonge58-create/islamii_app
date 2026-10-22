import 'dart:convert';

import 'package:http/http.dart' as http;

import '../modules/prayer_times_model.dart';

class PrayerTimesService {
  /// Fetches prayer times using latitude and longitude coordinates and calculation method.
  Future<PrayerTimesModel> getTimingsByCoordinates({
    required double latitude,
    required double longitude,
    int method = 5,
    DateTime? date,
  }) async {
    final targetDate = date ?? DateTime.now();
    final dateStr =
        '${targetDate.day.toString().padLeft(2, '0')}-${targetDate.month.toString().padLeft(2, '0')}-${targetDate.year}';

    final url = Uri.parse(
      'https://api.aladhan.com/v1/timings/$dateStr?latitude=$latitude&longitude=$longitude&method=$method',
    );

    final response = await http.get(url).timeout(const Duration(seconds: 8));

    if (response.statusCode != 200) {
      throw Exception('Failed to load prayer times (${response.statusCode})');
    }

    final data = json.decode(response.body);
    return PrayerTimesModel.fromJson(data, targetDate);
  }

  /// Fetches prayer times by city and country name.
  Future<PrayerTimesModel> getTimingsByCity({
    required String city,
    required String country,
    int method = 5,
    DateTime? date,
  }) async {
    final targetDate = date ?? DateTime.now();
    final dateStr =
        '${targetDate.day.toString().padLeft(2, '0')}-${targetDate.month.toString().padLeft(2, '0')}-${targetDate.year}';

    final url = Uri.parse(
      'https://api.aladhan.com/v1/timingsByCity/$dateStr?city=$city&country=$country&method=$method',
    );

    final response = await http.get(url).timeout(const Duration(seconds: 8));

    if (response.statusCode != 200) {
      throw Exception('Failed to load prayer times (${response.statusCode})');
    }

    final data = json.decode(response.body);
    return PrayerTimesModel.fromJson(data, targetDate);
  }
}
