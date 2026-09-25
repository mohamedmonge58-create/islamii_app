// lib/services/prayer_times_service.dart
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../modules/prayer_times_model.dart';

class PrayerTimesService {
  Future<PrayerTimesModel> getTimingsByCity({
    required String city,
    required String country,
    DateTime? date,
  }) async {
    final targetDate = date ?? DateTime.now();
    final dateStr =
        '${targetDate.day.toString().padLeft(2, '0')}-${targetDate.month.toString().padLeft(2, '0')}-${targetDate.year}';

    final url = Uri.parse(
      'https://api.aladhan.com/v1/timingsByCity/$dateStr?city=$city&country=$country',
    );

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to load prayer times (${response.statusCode})');
    }

    final data = json.decode(response.body);
    return PrayerTimesModel.fromJson(data, targetDate);
  }
}
