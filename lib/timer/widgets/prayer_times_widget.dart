import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:islamii_app/core/app_assets.dart';
import 'package:islamii_app/core/app_color.dart';
import 'package:islamii_app/services/adhan_scheduler_service.dart';
import 'package:islamii_app/timer/widgets/prayer_times_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../modules/prayer_times_model.dart';
import '../../services/prayer_times_service.dart';

class PrayerTimesWidget extends StatefulWidget {
  const PrayerTimesWidget({super.key});

  @override
  State<PrayerTimesWidget> createState() => _PrayerTimesWidgetState();
}

class _PrayerTimesWidgetState extends State<PrayerTimesWidget>
    with WidgetsBindingObserver {
  final AudioPlayer _adhanPlayer = AudioPlayer();
  final _service = PrayerTimesService();
  final _adhanScheduler = AdhanSchedulerService();
  final _scrollController = ScrollController();

  PrayerTimesModel? _model;
  NextPrayerInfo? _nextPrayer;
  Timer? _timer;
  bool _isPlaying = false;
  bool _isStartingAudio = false;
  bool _isLoading = true;
  String? _error;
  int _selectedMethod = 5;
  String _locationName = 'القاهرة، مصر (افتراضي)';
  bool _isFallbackLocation = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _adhanPlayer.onPlayerComplete.listen((_) {
      if (!mounted) return;
      setState(() {
        _isPlaying = false;
        _isStartingAudio = false;
      });
    });

    _adhanScheduler.initialize();
    _loadPrayerTimes();
  }

  String _translateToArabic(String input) {
    if (input.isEmpty) return input;

    const Map<String, String> translations = {
      'Egypt': 'مصر',
      'Cairo': 'القاهرة',
      'Giza': 'الجيزة',
      'Alexandria': 'الإسكندرية',
      'Tanta': 'طنطا',
      'Gharbia': 'الغربية',
      'Gharbeya': 'الغربية',
      'Dakahlia': 'الدقهلية',
      'Mansoura': 'المنصورة',
      'Sharqia': 'الشرقية',
      'Zagazig': 'الزقازيق',
      'Monufia': 'المنوفية',
      'Shebin El Kom': 'شبين الكوم',
      'Qalyubia': 'القليوبية',
      'Banha': 'بنها',
      'Beheira': 'البحيرة',
      'Damanhour': 'دمنهور',
      'Ismailia': 'الإسماعيلية',
      'Suez': 'السويس',
      'Port Said': 'بورسعيد',
      'Faiyum': 'الفيوم',
      'Beni Suef': 'بني سويف',
      'Minya': 'المنيا',
      'Asyut': 'أسيوط',
      'Sohag': 'سوهاج',
      'Qena': 'قنا',
      'Luxor': 'الأقصر',
      'Aswan': 'أسوان',
      'Red Sea': 'البحر الأحمر',
      'Hurghada': 'الغردقة',
      'South Sinai': 'جنوب سيناء',
      'Sharm El-Sheikh': 'شرم الشيخ',
      'Matrouh': 'مطروح',
      'Saudi Arabia': 'السعودية',
      'Makkah': 'مكة المكرمة',
      'Mecca': 'مكة المكرمة',
      'Madinah': 'المدينة المنورة',
      'Medina': 'المدينة المنورة',
      'Riyadh': 'الرياض',
      'Jeddah': 'جدة',
      'United Arab Emirates': 'الإمارات العربية المتحدة',
      'Dubai': 'دبي',
      'Abu Dhabi': 'أبو ظبي',
      'Kuwait': 'الكويت',
      'Qatar': 'قطر',
      'Doha': 'الدوحة',
      'Bahrain': 'البحرين',
      'Manama': 'المنامة',
      'Oman': 'عُمان',
      'Muscat': 'مسقط',
      'Jordan': 'الأردن',
      'Amman': 'عَمّان',
      'Palestine': 'فلسطين',
      'Jerusalem': 'القدس',
      'Lebanon': 'لبنان',
      'Beirut': 'بيروت',
      'Syria': 'سوريا',
      'Damascus': 'دمشق',
      'Iraq': 'العراق',
      'Baghdad': 'بغداد',
      'Morocco': 'المغرب',
      'Rabat': 'الرباط',
      'Casablanca': 'الدار البيضاء',
      'Algeria': 'الجزائر',
      'Tunisia': 'تونس',
      'Libya': 'ليبيا',
      'Tripoli': 'طرابلس',
      'Sudan': 'السودان',
      'Khartoum': 'الخرطوم',
      'United States': 'الولايات المتحدة',
      'United Kingdom': 'المملكة المتحدة',
      'Canada': 'كندا',
      'Germany': 'ألمانيا',
      'France': 'فرنسا',
      'Turkey': 'تركيا',
      'Istanbul': 'إسطنبول',
    };

    if (translations.containsKey(input)) {
      return translations[input]!;
    }

    for (final entry in translations.entries) {
      if (entry.key.toLowerCase() == input.toLowerCase()) {
        return entry.value;
      }
    }

    return input;
  }

  Future<String> _reverseGeocode(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        lat,
        lng,
      ).timeout(const Duration(seconds: 5));

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;

        final rawArea =
            [
                  place.subLocality,
                  place.locality,
                  place.subAdministrativeArea,
                  place.administrativeArea,
                ]
                .whereType<String>()
                .map((e) => e.trim())
                .firstWhere((e) => e.isNotEmpty, orElse: () => '');

        final rawCountry = place.country?.trim() ?? '';

        final area = _translateToArabic(rawArea);
        final country = _translateToArabic(rawCountry);

        if (area.isNotEmpty && country.isNotEmpty) {
          return '$area، $country';
        }

        if (area.isNotEmpty) return area;
        if (country.isNotEmpty) return country;
      }
    } catch (e) {
      debugPrint('Reverse geocoding error: $e');
    }

    return 'القاهرة، مصر (افتراضي)';
  }

  Future<void> _loadPrayerTimes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final method = prefs.getInt('calculation_method') ?? 5;

      double? lat;
      double? lng;
      String locationName = 'القاهرة، مصر (افتراضي)';
      bool isFallback = true;

      try {
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (serviceEnabled) {
          LocationPermission permission = await Geolocator.checkPermission();
          if (permission == LocationPermission.denied) {
            permission = await Geolocator.requestPermission();
          }
          if (permission == LocationPermission.whileInUse ||
              permission == LocationPermission.always) {
            final position = await Geolocator.getCurrentPosition(
              locationSettings: const LocationSettings(
                accuracy: LocationAccuracy.low,
                timeLimit: Duration(seconds: 4),
              ),
            );
            lat = position.latitude;
            lng = position.longitude;
            isFallback = false;
            locationName = await _reverseGeocode(lat, lng);
          }
        }
      } catch (_) {
        // Fallback to Cairo
      }

      PrayerTimesModel model;
      if (lat != null && lng != null) {
        model = await _service.getTimingsByCoordinates(
          latitude: lat,
          longitude: lng,
          method: method,
        );
      } else {
        model = await _service.getTimingsByCity(
          city: 'cairo',
          country: 'egypt',
          method: method,
        );
      }

      if (!mounted) return;
      setState(() {
        _model = model;
        _nextPrayer = getNextPrayer(model);
        _selectedMethod = method;
        _locationName = locationName;
        _isFallbackLocation = isFallback;
        _isLoading = false;
        _error = null;
      });

      _startCountdown();
      _scrollToCurrentPrayer();

      // Schedule background system notifications for future prayer times
      _adhanScheduler.schedulePrayerTimes(model.orderedPrayers);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'تعذر تحميل مواقيت الصلاة';
        _isLoading = false;
      });
    }
  }

  void _startCountdown() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_model == null) return;
      final next = getNextPrayer(_model!);
      if (!mounted) return;
      setState(() => _nextPrayer = next);

      if (next.remaining.isNegative) {
        _loadPrayerTimes();
      }
    });
  }

  void _scrollToCurrentPrayer() {
    if (_nextPrayer == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      final index = _nextPrayer!.index;
      const cardWidth = 92.0;
      final offset = (index * cardWidth) - 100;
      _scrollController.animateTo(
        offset.clamp(0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  Future<void> _toggleAdhan() async {
    if (_isStartingAudio) return;

    if (_adhanScheduler.isPlayingAdhan || _isPlaying) {
      await _stopAdhan();
      return;
    }

    setState(() {
      _isStartingAudio = true;
    });

    try {
      await _adhanScheduler.playFullAdhan();

      if (!mounted) {
        await _adhanScheduler.stopFullAdhan();
        return;
      }

      setState(() {
        _isPlaying = true;
        _isStartingAudio = false;
      });
    } catch (e, stackTrace) {
      debugPrint('Adhan playback error: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      setState(() {
        _isPlaying = false;
        _isStartingAudio = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تعذر تشغيل الأذان')));
    }
  }

  Future<void> _stopAdhan() async {
    try {
      await _adhanScheduler.stopFullAdhan();
      await _adhanPlayer.stop();
    } catch (_) {
      // Ignore error
    }

    if (!mounted) return;

    setState(() {
      _isPlaying = false;
      _isStartingAudio = false;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _stopAdhan();
    }
  }

  void _showAdhanSettings() async {
    final isLight = AppColor.isLight(context);
    final accentColor = AppColor.primary(context);
    final primaryTextColor = AppColor.primaryText(context);

    final prefs = await SharedPreferences.getInstance();
    bool adhanEnabled = prefs.getBool('adhan_enabled') ?? true;
    bool adhanFajr = prefs.getBool('adhan_fajr') ?? true;
    bool adhanDhuhr = prefs.getBool('adhan_dhuhr') ?? true;
    bool adhanAsr = prefs.getBool('adhan_asr') ?? true;
    bool adhanMaghrib = prefs.getBool('adhan_maghrib') ?? true;
    bool adhanIsha = prefs.getBool('adhan_isha') ?? true;

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: isLight ? AppColor.lightCardBg : AppColor.black,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: accentColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'إعدادات تنبيهات الأذان',
                      style: TextStyle(
                        color: accentColor,
                        fontFamily: 'Janna',
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 12),

                    SwitchListTile(
                      activeThumbColor: accentColor,
                      title: Text(
                        'تفعيل تنبيهات الأذان تلقائياً',
                        style: TextStyle(
                          color: primaryTextColor,
                          fontFamily: 'Janna',
                        ),
                      ),
                      value: adhanEnabled,
                      onChanged: (val) async {
                        setModalState(() => adhanEnabled = val);
                        await prefs.setBool('adhan_enabled', val);
                        if (_model != null) {
                          _adhanScheduler.schedulePrayerTimes(
                            _model!.orderedPrayers,
                          );
                        }
                      },
                    ),
                    Divider(color: AppColor.border(context)),

                    SwitchListTile(
                      activeThumbColor: accentColor,
                      title: Text(
                        'أذان صلاة الفجر',
                        style: TextStyle(
                          color: primaryTextColor,
                          fontFamily: 'Janna',
                        ),
                      ),
                      value: adhanFajr,
                      onChanged: !adhanEnabled
                          ? null
                          : (val) async {
                              setModalState(() => adhanFajr = val);
                              await prefs.setBool('adhan_fajr', val);
                              if (_model != null) {
                                _adhanScheduler.schedulePrayerTimes(
                                  _model!.orderedPrayers,
                                );
                              }
                            },
                    ),

                    SwitchListTile(
                      activeThumbColor: accentColor,
                      title: Text(
                        'أذان صلاة الظهر',
                        style: TextStyle(
                          color: primaryTextColor,
                          fontFamily: 'Janna',
                        ),
                      ),
                      value: adhanDhuhr,
                      onChanged: !adhanEnabled
                          ? null
                          : (val) async {
                              setModalState(() => adhanDhuhr = val);
                              await prefs.setBool('adhan_dhuhr', val);
                              if (_model != null) {
                                _adhanScheduler.schedulePrayerTimes(
                                  _model!.orderedPrayers,
                                );
                              }
                            },
                    ),

                    SwitchListTile(
                      activeThumbColor: accentColor,
                      title: Text(
                        'أذان صلاة العصر',
                        style: TextStyle(
                          color: primaryTextColor,
                          fontFamily: 'Janna',
                        ),
                      ),
                      value: adhanAsr,
                      onChanged: !adhanEnabled
                          ? null
                          : (val) async {
                              setModalState(() => adhanAsr = val);
                              await prefs.setBool('adhan_asr', val);
                              if (_model != null) {
                                _adhanScheduler.schedulePrayerTimes(
                                  _model!.orderedPrayers,
                                );
                              }
                            },
                    ),

                    SwitchListTile(
                      activeThumbColor: accentColor,
                      title: Text(
                        'أذان صلاة المغرب',
                        style: TextStyle(
                          color: primaryTextColor,
                          fontFamily: 'Janna',
                        ),
                      ),
                      value: adhanMaghrib,
                      onChanged: !adhanEnabled
                          ? null
                          : (val) async {
                              setModalState(() => adhanMaghrib = val);
                              await prefs.setBool('adhan_maghrib', val);
                              if (_model != null) {
                                _adhanScheduler.schedulePrayerTimes(
                                  _model!.orderedPrayers,
                                );
                              }
                            },
                    ),

                    SwitchListTile(
                      activeThumbColor: accentColor,
                      title: Text(
                        'أذان صلاة العشاء',
                        style: TextStyle(
                          color: primaryTextColor,
                          fontFamily: 'Janna',
                        ),
                      ),
                      value: adhanIsha,
                      onChanged: !adhanEnabled
                          ? null
                          : (val) async {
                              setModalState(() => adhanIsha = val);
                              await prefs.setBool('adhan_isha', val);
                              if (_model != null) {
                                _adhanScheduler.schedulePrayerTimes(
                                  _model!.orderedPrayers,
                                );
                              }
                            },
                    ),

                    Divider(color: AppColor.border(context)),

                    ListTile(
                      title: Text(
                        'طريقة حساب مواقيت الصلاة',
                        style: TextStyle(
                          color: primaryTextColor,
                          fontFamily: 'Janna',
                        ),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: accentColor,
                        size: 16,
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        _showMethodSelector();
                      },
                    ),

                    const SizedBox(height: 12),

                    OutlinedButton.icon(
                      onPressed: () async {
                        await _adhanScheduler.requestPermissions();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('تم طلب أذونات التنبيهات والأذان'),
                            ),
                          );
                        }
                      },
                      label: Text(
                        'طلب أذونات التنبيهات والأذان',
                        style: TextStyle(
                          color: accentColor,
                          fontFamily: 'Janna',
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: accentColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showMethodSelector() {
    final methods = {
      5: 'الهيئة المصرية العامة للمساحة',
      4: 'جامعة أم القرى (مكة المكرمة)',
      3: 'رابطة العالم الإسلامي',
      2: 'الجمعية الإسلامية لشمال أمريكا (ISNA)',
      1: 'جامعة العلوم الإسلامية بكراتشي',
      8: 'منطقة الخليج العربي',
    };

    final isLight = AppColor.isLight(context);
    final accentColor = AppColor.primary(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: isLight ? AppColor.lightCardBg : AppColor.black,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'طريقة الحساب',
                    style: TextStyle(
                      color: accentColor,
                      fontFamily: 'Janna',
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _showAdhanSettings();
                    },
                    icon: Icon(Icons.tune, color: accentColor, size: 18),
                    label: Text(
                      'إعدادات الأذان',
                      style: TextStyle(color: accentColor, fontFamily: 'Janna'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: methods.entries.map((entry) {
                    final isSelected = entry.key == _selectedMethod;
                    return ListTile(
                      onTap: () async {
                        Navigator.pop(context);
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setInt('calculation_method', entry.key);
                        setState(() {
                          _isLoading = true;
                        });
                        _loadPrayerTimes();
                      },
                      title: Text(
                        entry.value,
                        style: TextStyle(
                          color: isSelected
                              ? accentColor
                              : AppColor.primaryText(context),
                          fontFamily: 'Janna',
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      trailing: isSelected
                          ? Icon(Icons.check_circle, color: accentColor)
                          : null,
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDuration(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  String _getArabicDayName(DateTime date) {
    final englishDay = DateFormat('EEEE').format(date);
    switch (englishDay) {
      case 'Saturday':
        return '﴾  السبت  ﴿';
      case 'Sunday':
        return '﴾  الأحد  ﴿';
      case 'Monday':
        return '﴾  الأثنين  ﴿';
      case 'Tuesday':
        return '﴾  الثلاثاء  ﴿';
      case 'Wednesday':
        return '﴾  الأربعاء  ﴿';
      case 'Thursday':
        return ' ﴾  الخميس  ﴿';
      case 'Friday':
        return '﴾  الجمعة  ﴿';
      default:
        return englishDay;
    }
  }

  String _getArabicPrayerName(String key) {
    switch (key) {
      case 'Fajr':
        return 'الفجر';
      case 'Sunrise':
        return 'الشروق';
      case 'Dhuhr':
        return 'الظهر';
      case 'Asr':
        return 'العصر';
      case 'Maghrib':
        return 'المغرب';
      case 'Isha':
        return 'العشاء';
      default:
        return key;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _scrollController.dispose();
    _adhanPlayer.stop();
    _adhanPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLight = AppColor.isLight(context);
    final accentColor = AppColor.primary(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Prominent Location Banner ABOVE Prayer Times Card
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isLight
                  ? AppColor.lightCardBg
                  : AppColor.black.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: _isFallbackLocation
                    ? (isLight
                          ? AppColor.lightSecondaryText
                          : AppColor.golden.withValues(alpha: 0.5))
                    : accentColor,
                width: 1.2,
              ),
              boxShadow: isLight
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  _isFallbackLocation
                      ? Icons.location_off_outlined
                      : Icons.my_location_rounded,
                  color: _isFallbackLocation
                      ? (isLight
                            ? AppColor.lightSecondaryText
                            : AppColor.golden)
                      : accentColor,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'الموقع الحالي لمواقيت الصلاة',
                        style: TextStyle(
                          color: AppColor.secondaryText(context),
                          fontSize: 11,
                          fontFamily: 'Janna',
                        ),
                      ),
                      Text(
                        _locationName,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: AppColor.primaryText(context),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Janna',
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.refresh_rounded,
                    color: accentColor,
                    size: 22,
                  ),
                  onPressed: () {
                    setState(() {
                      _isLoading = true;
                    });
                    _loadPrayerTimes();
                  },
                  tooltip: 'تحديث الموقع والمواقيت',
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 6),

        // Main Prayer Times Card Container
        _isLoading
            ? Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                height: 220,
                decoration: BoxDecoration(
                  color: isLight
                      ? AppColor.lightPrimaryLight
                      : AppColor.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(24),
                  border: isLight
                      ? Border.all(
                          color: AppColor.lightPrimaryEmerald.withValues(
                            alpha: 0.25,
                          ),
                        )
                      : null,
                ),
                child: Center(
                  child: CircularProgressIndicator(
                    color: isLight
                        ? AppColor.lightPrimaryEmerald
                        : AppColor.gold,
                  ),
                ),
              )
            : _error != null || _model == null
            ? Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isLight
                      ? AppColor.lightCardBg
                      : AppColor.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(24),
                  border: isLight
                      ? Border.all(
                          color: AppColor.lightPrimaryEmerald.withValues(
                            alpha: 0.25,
                          ),
                        )
                      : null,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: isLight
                          ? AppColor.lightPrimaryEmerald
                          : AppColor.gold,
                      size: 36,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _error ?? 'تعذر تحميل مواقيت الصلاة',
                      style: TextStyle(
                        color: isLight
                            ? AppColor.lightPrimaryDark
                            : AppColor.white,
                        fontFamily: 'Janna',
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _isLoading = true;
                          _error = null;
                        });
                        _loadPrayerTimes();
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: isLight
                            ? AppColor.lightPrimaryEmerald
                            : AppColor.gold,
                        side: BorderSide(
                          color: isLight
                              ? AppColor.lightPrimaryEmerald
                              : AppColor.gold,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'إعادة المحاولة',
                        style: TextStyle(fontFamily: 'Janna'),
                      ),
                    ),
                  ],
                ),
              )
            : Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  // اللون الجديد للكارد الكبير في Light Mode
                  gradient: isLight
                      ? const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFFF0F8F3),
                            Color(0xFFE0F0E7),
                            Color(0xFFD2E8DC),
                          ],
                          stops: [0.0, 0.55, 1.0],
                        )
                      : null,
                  color: isLight ? null : AppColor.black,
                  borderRadius: BorderRadius.circular(24),
                  border: isLight
                      ? Border.all(
                          color: AppColor.lightPrimaryEmerald.withValues(
                            alpha: 0.3,
                          ),
                          width: 1.2,
                        )
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: isLight ? 0.08 : 0.3,
                      ),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: [
                    // صور الخلفية تظهر في Dark Mode فقط
                    if (!isLight) ...[
                      Positioned.fill(
                        child: Image.asset(AppAssets.group1, fit: BoxFit.cover),
                      ),
                      Positioned.fill(
                        child: Image.asset(AppAssets.group2, fit: BoxFit.cover),
                      ),
                    ],

                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 14,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    DateFormat(
                                      'dd MMM,\nyyyy',
                                    ).format(_model!.gregorianDate),
                                    style: TextStyle(
                                      fontSize: 24,
                                      color: isLight
                                          ? AppColor.lightPrimaryDark
                                          : AppColor.white,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'alfont',
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Column(
                                children: [
                                  Text(
                                    _getArabicDayName(_model!.gregorianDate),
                                    style: TextStyle(
                                      fontSize: 45,
                                      color: isLight
                                          ? AppColor.lightPrimaryEmerald
                                          : AppColor.black,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'alfont',
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 19),
                              Expanded(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    '${_model!.hijriDay} '
                                    '${_model!.hijriMonth}\n'
                                    '${_model!.hijriYear} هـ',
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: isLight
                                          ? AppColor.lightPrimaryDark
                                          : AppColor.white,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'alfont',
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          SizedBox(
                            height: 135,
                            child: ListView.builder(
                              controller: _scrollController,
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              itemCount: _model!.orderedPrayers.length,
                              itemBuilder: (context, index) {
                                final prayer = _model!.orderedPrayers[index];

                                return _PrayerCard(
                                  name: _getArabicPrayerName(prayer.key),
                                  time: prayer.value,
                                  isActive: index == _nextPrayer!.index,
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 16),

                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isLight
                                  ? AppColor.lightPrimaryEmerald.withValues(
                                      alpha: 0.10,
                                    )
                                  : AppColor.black.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(16),
                              border: isLight
                                  ? Border.all(
                                      color: AppColor.lightPrimaryEmerald
                                          .withValues(alpha: 0.22),
                                    )
                                  : null,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Flexible(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      'الصلاة القادمة : ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 22,
                                        color: isLight
                                            ? AppColor.lightPrimaryEmerald
                                            : AppColor.black,
                                        fontFamily: 'alfont',
                                      ),
                                    ),
                                  ),
                                ),
                                Text(
                                  _formatDuration(_nextPrayer!.remaining),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: isLight
                                        ? AppColor.lightPrimaryDark
                                        : AppColor.black,
                                    fontFamily: 'Janna',
                                  ),
                                ),
                                const SizedBox(width: 12),
                                InkWell(
                                  onTap: _isStartingAudio ? null : _toggleAdhan,
                                  borderRadius: BorderRadius.circular(20),
                                  child: Padding(
                                    padding: const EdgeInsets.all(4),
                                    child: Icon(
                                      _isPlaying
                                          ? Icons.volume_up
                                          : Icons.volume_off,
                                      color: isLight
                                          ? AppColor.lightPrimaryEmerald
                                          : AppColor.black,
                                      size: 22,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                InkWell(
                                  onTap: _showAdhanSettings,
                                  borderRadius: BorderRadius.circular(20),
                                  child: Padding(
                                    padding: const EdgeInsets.all(4),
                                    child: Icon(
                                      Icons.notifications_active,
                                      color: isLight
                                          ? AppColor.lightPrimaryEmerald
                                          : AppColor.black,
                                      size: 22,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ],
    );
  }
}

class _PrayerCard extends StatelessWidget {
  final String name;
  final DateTime time;
  final bool isActive;

  const _PrayerCard({
    required this.name,
    required this.time,
    required this.isActive,
  });

  String _getArabicPeriod(String period) {
    final upper = period.toUpperCase();
    if (upper == 'AM' || upper == 'ص') return 'ص';
    if (upper == 'PM' || upper == 'م') return 'م';
    return period;
  }

  @override
  Widget build(BuildContext context) {
    final period = _getArabicPeriod(DateFormat('a').format(time));
    final timeStr = DateFormat('hh:mm').format(time);
    final isLight = AppColor.isLight(context);

    final activeGradient = isLight
        ? [AppColor.lightPrimaryEmerald, AppColor.lightPrimaryDark]
        : [AppColor.gold, AppColor.golden];

    final inactiveGradient = isLight
        ? [AppColor.lightCardBg, AppColor.lightPrimaryLight]
        : [AppColor.gray, AppColor.black];

    final activeNameColor = isLight ? AppColor.lightGoldAccent : AppColor.black;
    final activeTimeColor = isLight ? AppColor.white : AppColor.black;
    final activePeriodColor = isLight
        ? AppColor.white.withValues(alpha: 0.9)
        : AppColor.black.withValues(alpha: 0.8);

    final inactiveNameColor = isLight
        ? AppColor.lightPrimaryDark
        : AppColor.white;
    final inactiveTimeColor = isLight
        ? AppColor.lightPrimaryEmerald
        : AppColor.gold;
    final inactivePeriodColor = isLight
        ? AppColor.lightSecondaryText
        : AppColor.white.withValues(alpha: 0.7);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isActive ? 96 : 82,
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isActive ? activeGradient : inactiveGradient,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isActive
              ? (isLight ? AppColor.lightGoldAccent : AppColor.white)
              : (isLight
                    ? AppColor.lightPrimaryEmerald.withValues(alpha: 0.25)
                    : AppColor.gold.withValues(alpha: 0.3)),
          width: isActive ? 1.8 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isActive
                ? (isLight ? AppColor.lightPrimaryEmerald : AppColor.gold)
                      .withValues(alpha: 0.45)
                : (isLight
                      ? Colors.black.withValues(alpha: 0.05)
                      : Colors.transparent),
            blurRadius: isActive ? 12 : 6,
            spreadRadius: isActive ? 1 : 0,
            offset: isActive ? const Offset(0, 3) : const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: isActive ? activeNameColor : inactiveNameColor,
              fontSize: isActive ? 30 : 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'alfont',
            ),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              timeStr,
              style: TextStyle(
                color: isActive ? activeTimeColor : inactiveTimeColor,
                fontSize: isActive ? 22 : 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Janna',
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            period,
            style: TextStyle(
              color: isActive ? activePeriodColor : inactivePeriodColor,
              fontSize: isActive ? 12 : 11,
              fontWeight: FontWeight.w600,
              fontFamily: 'Janna',
            ),
          ),
        ],
      ),
    );
  }
}
