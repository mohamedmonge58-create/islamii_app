import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:islamii_app/core/audio_player_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class AdhanSchedulerService {
  static final AdhanSchedulerService _instance =
      AdhanSchedulerService._internal();
  factory AdhanSchedulerService() => _instance;
  AdhanSchedulerService._internal();

  static const MethodChannel _nativeChannel = MethodChannel(
    'com.example.islamii_app/adhan',
  );

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final AudioPlayer _adhanPlayer = AudioPlayer();

  bool _isInitialized = false;
  bool _isPlayingAdhan = false;

  static const String channelId = 'adhan_channel_id';
  static const String channelName = 'مواقيت الصلاة والأذان';
  static const String channelDescription =
      'تنبيهات وأذان مواقيت الصلاة المفروضة';

  static const int playingNotificationId = 999;

  static const Map<String, Map<String, dynamic>> _prayerMap = {
    'Fajr': {'id': 101, 'name': 'الفجر'},
    'Dhuhr': {'id': 102, 'name': 'الظهر'},
    'Asr': {'id': 103, 'name': 'العصر'},
    'Maghrib': {'id': 104, 'name': 'المغرب'},
    'Isha': {'id': 105, 'name': 'العشاء'},
  };

  bool get isPlayingAdhan => _isPlayingAdhan;

  /// Initializes timezone data, notification plugin, and player listeners
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      tz.initializeTimeZones();

      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );
      const initSettings = InitializationSettings(android: androidSettings);

      await _notificationsPlugin.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: _onNotificationResponse,
      );

      const androidChannel = AndroidNotificationChannel(
        channelId,
        channelName,
        description: channelDescription,
        importance: Importance.max,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('a4ab138564ce'),
      );

      final androidPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      if (androidPlugin != null) {
        await androidPlugin.createNotificationChannel(androidChannel);
      }

      _adhanPlayer.onPlayerComplete.listen((_) {
        _isPlayingAdhan = false;
        _notificationsPlugin.cancel(id: playingNotificationId);
      });

      _isInitialized = true;
    } catch (e) {
      debugPrint('AdhanSchedulerService initialize error: $e');
    }
  }

  /// Handles notification taps and action buttons
  Future<void> _onNotificationResponse(NotificationResponse response) async {
    if (response.actionId == 'stop_adhan') {
      await stopFullAdhan();
    } else {
      await playFullAdhan();
    }
  }

  /// Plays the full-length Adhan audio track from beginning to end
  Future<void> playFullAdhan() async {
    try {
      await AudioPlayerManager.instance.stop();
      await _adhanPlayer.stop();

      await _adhanPlayer.play(AssetSource('audio/a4ab138564ce.mp3'));
      _isPlayingAdhan = true;

      await _notificationsPlugin.show(
        id: playingNotificationId,
        title: 'يتم الآن تشغيل الأذان كاملاً',
        body: 'اضغط لإيقاف الصوت في أي وقت',
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            channelId,
            channelName,
            channelDescription: channelDescription,
            importance: Importance.high,
            priority: Priority.high,
            ongoing: true,
            autoCancel: false,
            actions: [
              AndroidNotificationAction(
                'stop_adhan',
                'إيقاف الأذان',
                showsUserInterface: true,
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      debugPrint('AdhanSchedulerService playFullAdhan error: $e');
      _isPlayingAdhan = false;
    }
  }

  /// Stops full-length Adhan playback
  Future<void> stopFullAdhan() async {
    try {
      await _adhanPlayer.stop();
      _isPlayingAdhan = false;
      await _notificationsPlugin.cancel(id: playingNotificationId);
      try {
        await _nativeChannel.invokeMethod('stopNativeAdhan');
      } catch (_) {}
    } catch (e) {
      debugPrint('AdhanSchedulerService stopFullAdhan error: $e');
    }
  }

  /// Requests Android 13+ POST_NOTIFICATIONS and Exact Alarm permissions
  Future<bool> requestPermissions() async {
    try {
      final androidPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      if (androidPlugin != null) {
        final granted = await androidPlugin.requestNotificationsPermission();
        await androidPlugin.requestExactAlarmsPermission();
        return granted ?? false;
      }
    } catch (e) {
      debugPrint('AdhanSchedulerService requestPermissions error: $e');
    }
    return false;
  }

  /// Schedules future prayer notifications according to user preferences and location
  Future<void> schedulePrayerTimes(
    List<MapEntry<String, DateTime>> prayers,
  ) async {
    await initialize();

    final prefs = await SharedPreferences.getInstance();
    final bool adhanEnabled = prefs.getBool('adhan_enabled') ?? true;

    if (!adhanEnabled) {
      await cancelAll();
      return;
    }

    final now = DateTime.now();
    final List<Map<String, dynamic>> nativePrayers = [];

    for (final prayer in prayers) {
      final key = prayer.key;
      final time = prayer.value;

      if (!_prayerMap.containsKey(key)) continue;

      final info = _prayerMap[key]!;
      final int id = info['id'] as int;
      final String arabicName = info['name'] as String;

      final bool isPrayerEnabled =
          prefs.getBool('adhan_${key.toLowerCase()}') ?? true;

      // Rejection of past times or disabled prayers
      if (!isPrayerEnabled || !time.isAfter(now)) {
        await _notificationsPlugin.cancel(id: id);
        continue;
      }

      nativePrayers.add({
        'key': key,
        'name': arabicName,
        'id': id,
        'timeMillis': time.millisecondsSinceEpoch,
      });

      try {
        final scheduledDate = tz.TZDateTime.from(time, tz.local);

        await _notificationsPlugin.zonedSchedule(
          id: id,
          title: 'حان الآن موعد صلاة $arabicName',
          body: 'حي على الصلاة .. حي على الفلاح (اضغط لتشغيل الأذان كاملاً)',
          scheduledDate: scheduledDate,
          payload: 'play_adhan',
          notificationDetails: NotificationDetails(
            android: AndroidNotificationDetails(
              channelId,
              channelName,
              channelDescription: channelDescription,
              importance: Importance.max,
              priority: Priority.high,
              sound: const RawResourceAndroidNotificationSound('a4ab138564ce'),
              playSound: true,
              styleInformation: BigTextStyleInformation(
                'حان الآن موعد أذان صلاة $arabicName حسب توقيت مدينتك. اضغط لتشغيل الأذان كاملاً.',
              ),
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        );
      } catch (e) {
        debugPrint('Error scheduling $arabicName ($time): $e');
      }
    }

    // Schedule native Android exact alarms and foreground service trigger
    try {
      await _nativeChannel.invokeMethod('scheduleNativeAdhan', {
        'prayers': nativePrayers,
      });
    } catch (e) {
      debugPrint('Native Adhan scheduling channel error: $e');
    }
  }

  /// Schedules a test Adhan N seconds ahead for verification
  Future<void> scheduleTestAdhan({int delaySeconds = 10}) async {
    try {
      await _nativeChannel.invokeMethod('scheduleTestAdhan', {
        'delaySeconds': delaySeconds,
      });
    } catch (e) {
      debugPrint('scheduleTestAdhan error: $e');
    }
  }

  /// Cancels all scheduled prayer notifications
  Future<void> cancelAll() async {
    try {
      await _notificationsPlugin.cancelAll();
      await stopFullAdhan();
      try {
        await _nativeChannel.invokeMethod('cancelAllNativeAdhan');
      } catch (_) {}
    } catch (e) {
      debugPrint('AdhanSchedulerService cancelAll error: $e');
    }
  }
}
