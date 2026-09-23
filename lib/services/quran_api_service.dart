// lib/services/quran_api_service.dart
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../radio/models/radio_model.dart';
import '../radio/models/reciter_model.dart';

class QuranApiService {
  static const String _recitersUrl =
      'https://www.mp3quran.net/api/v3/reciters?language=ar';
  static const String _radiosUrl =
      'https://www.mp3quran.net/api/v3/radios?language=ar';

  Future<List<ReciterModel>> getReciters() async {
    final response = await http.get(Uri.parse(_recitersUrl));

    if (response.statusCode != 200) {
      throw Exception('Failed to load reciters (${response.statusCode})');
    }

    final data = json.decode(utf8.decode(response.bodyBytes));
    final List<dynamic> list = data['reciters'] ?? [];
    return list.map((e) => ReciterModel.fromJson(e)).toList();
  }

  Future<List<RadioModel>> getRadios() async {
    final response = await http.get(Uri.parse(_radiosUrl));

    if (response.statusCode != 200) {
      throw Exception('Failed to load radios (${response.statusCode})');
    }

    final data = json.decode(utf8.decode(response.bodyBytes));
    final List<dynamic> list = data['radios'] ?? [];
    return list.map((e) => RadioModel.fromJson(e)).toList();
  }
}
