// lib/models/prayer_times_model.dart
class PrayerTimesModel {
  final DateTime fajr;
  final DateTime sunrise;
  final DateTime dhuhr;
  final DateTime asr;
  final DateTime maghrib;
  final DateTime isha;
  final String hijriDate; // e.g. "09 Muharram 1446"
  final String hijriDay;
  final String hijriMonth;
  final String hijriYear;
  final DateTime gregorianDate;

  PrayerTimesModel({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.hijriDay,
    required this.hijriMonth,
    required this.hijriYear,
    required this.hijriDate,
    required this.gregorianDate,
  });

  factory PrayerTimesModel.fromJson(
    Map<String, dynamic> json,
    DateTime forDate,
  ) {
    final timings = json['data']['timings'];
    final hijri = json['data']['date']['hijri'];
    final gregorian = json['data']['date']['gregorian'];

    DateTime parseTime(String raw) {
      // raw comes as "04:38 (EET)" or "04:38" -> we only need HH:mm
      final cleaned = raw.split(' ').first;
      final parts = cleaned.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      return DateTime(forDate.year, forDate.month, forDate.day, hour, minute);
    }

    return PrayerTimesModel(
      fajr: parseTime(timings['Fajr']),
      sunrise: parseTime(timings['Sunrise']),
      dhuhr: parseTime(timings['Dhuhr']),
      asr: parseTime(timings['Asr']),
      maghrib: parseTime(timings['Maghrib']),
      isha: parseTime(timings['Isha']),
      hijriDay: hijri['day'],
      hijriMonth: hijri['month']['en'],
      // e.g. "Muharram"
      hijriYear: hijri['year'],
      hijriDate: '${hijri['day']} ${hijri['month']['en']}, ${hijri['year']}',
      gregorianDate: forDate,
    );
  }

  /// كل الصلوات مرتبة، بالاسم والوقت
  List<MapEntry<String, DateTime>> get orderedPrayers => [
    MapEntry('Fajr', fajr),
    MapEntry('Sunrise', sunrise),
    MapEntry('Dhuhr', dhuhr),
    MapEntry('Asr', asr),
    MapEntry('Maghrib', maghrib),
    MapEntry('Isha', isha),
  ];
}
