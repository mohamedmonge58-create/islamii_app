import 'package:flutter_test/flutter_test.dart';
import 'package:islamii_app/main.dart';
import 'package:islamii_app/modules/prayer_times_model.dart';
import 'package:islamii_app/timer/widgets/prayer_times_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Prayer Times & Scheduling Logic Tests', () {
    test('getNextPrayer selects the next upcoming prayer correctly', () {
      final now = DateTime.now();
      final model = PrayerTimesModel(
        fajr: now.subtract(const Duration(hours: 5)),
        sunrise: now.subtract(const Duration(hours: 4)),
        dhuhr: now.subtract(const Duration(hours: 2)),
        asr: now.add(const Duration(hours: 1)),
        maghrib: now.add(const Duration(hours: 4)),
        isha: now.add(const Duration(hours: 6)),
        gregorianDate: now,
        hijriDay: '15',
        hijriMonth: 'رمضان',
        hijriYear: '1447',
        hijriDate: '15 رمضان 1447',
      );

      final next = getNextPrayer(model);

      expect(next.name, equals('Asr'));
      expect(next.index, equals(3)); // Fajr(0), Sunrise(1), Dhuhr(2), Asr(3)
      expect(next.remaining.isNegative, isFalse);
    });

    test(
      'getNextPrayer wraps to tomorrow Fajr when all prayers today passed',
      () {
        final now = DateTime.now();
        final model = PrayerTimesModel(
          fajr: now.subtract(const Duration(hours: 10)),
          sunrise: now.subtract(const Duration(hours: 9)),
          dhuhr: now.subtract(const Duration(hours: 7)),
          asr: now.subtract(const Duration(hours: 4)),
          maghrib: now.subtract(const Duration(hours: 2)),
          isha: now.subtract(const Duration(hours: 1)),
          gregorianDate: now,
          hijriDay: '15',
          hijriMonth: 'رمضان',
          hijriYear: '1447',
          hijriDate: '15 رمضان 1447',
        );

        final next = getNextPrayer(model);

        expect(next.name, equals('Fajr'));
        expect(next.index, equals(0));
        expect(next.remaining.isNegative, isFalse);
      },
    );

    test('SharedPreferences persistence for Adhan settings', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await prefs.setBool('adhan_enabled', true);
      await prefs.setInt('calculation_method', 5);
      await prefs.setBool('adhan_fajr', false);

      expect(prefs.getBool('adhan_enabled'), isTrue);
      expect(prefs.getInt('calculation_method'), equals(5));
      expect(prefs.getBool('adhan_fajr'), isFalse);
      expect(prefs.getBool('adhan_dhuhr') ?? true, isTrue);
    });
  });

  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle(const Duration(seconds: 4));
    expect(find.byType(MyApp), findsOneWidget);
  });
}
