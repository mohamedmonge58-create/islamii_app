import '../../modules/prayer_times_model.dart';

class NextPrayerInfo {
  final String name;
  final DateTime time;
  final Duration remaining;
  final int index; // index في orderedPrayers

  NextPrayerInfo({
    required this.name,
    required this.time,
    required this.remaining,
    required this.index,
  });
}

/// بيرجع الصلاة "الجاية" (اللي لسه ما جاش وقتها)، ومعاها المدة المتبقية.
/// لو كل صلوات النهارده خلصت، بيرجع فجر بكرة (المدة بتحسب عادي كفرق زمن).
NextPrayerInfo getNextPrayer(PrayerTimesModel model) {
  final now = DateTime.now();
  final prayers = model.orderedPrayers;

  for (int i = 0; i < prayers.length; i++) {
    if (prayers[i].value.isAfter(now)) {
      return NextPrayerInfo(
        name: prayers[i].key,
        time: prayers[i].value,
        remaining: prayers[i].value.difference(now),
        index: i,
      );
    }
  }

  // كل الصلوات فاتت -> الجاية هي فجر بكرة
  final tomorrowFajr = prayers.first.value.add(const Duration(days: 1));
  return NextPrayerInfo(
    name: prayers.first.key,
    time: tomorrowFajr,
    remaining: tomorrowFajr.difference(now),
    index: 0,
  );
}
