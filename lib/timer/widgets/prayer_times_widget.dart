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
      backgroundColor: AppColor.black,
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
                        color: AppColor.gold,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'إعدادات تنبيهات الأذان',
                      style: TextStyle(
                        color: AppColor.gold,
                        fontFamily: 'Janna',
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 12),

                    SwitchListTile(
                      activeThumbColor: AppColor.gold,
                      title: const Text(
                        'تفعيل تنبيهات الأذان تلقائياً',
                        style: TextStyle(
                          color: AppColor.white,
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
                    const Divider(color: Colors.white24),

                    SwitchListTile(
                      activeThumbColor: AppColor.gold,
                      title: const Text(
                        'أذان صلاة الفجر',
                        style: TextStyle(
                          color: AppColor.white,
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
                      activeThumbColor: AppColor.gold,
                      title: const Text(
                        'أذان صلاة الظهر',
                        style: TextStyle(
                          color: AppColor.white,
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
                      activeThumbColor: AppColor.gold,
                      title: const Text(
                        'أذان صلاة العصر',
                        style: TextStyle(
                          color: AppColor.white,
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
                      activeThumbColor: AppColor.gold,
                      title: const Text(
                        'أذان صلاة المغرب',
                        style: TextStyle(
                          color: AppColor.white,
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
                      activeThumbColor: AppColor.gold,
                      title: const Text(
                        'أذان صلاة العشاء',
                        style: TextStyle(
                          color: AppColor.white,
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
                      label: const Text(
                        'طلب أذونات التنبيهات والأذان',
                        style: TextStyle(
                          color: AppColor.gold,
                          fontFamily: 'Janna',
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColor.gold),
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

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColor.black,
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
                  color: AppColor.gold,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'طريقة الحساب',
                    style: TextStyle(
                      color: AppColor.gold,
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
                    icon: const Icon(
                      Icons.tune,
                      color: AppColor.gold,
                      size: 18,
                    ),
                    label: const Text(
                      'إعدادات الأذان',
                      style: TextStyle(
                        color: AppColor.gold,
                        fontFamily: 'Janna',
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
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
                          color: isSelected ? AppColor.gold : AppColor.white,
                          fontFamily: 'Janna',
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle, color: AppColor.gold)
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
        return 'السبت';
      case 'Sunday':
        return 'الأحد';
      case 'Monday':
        return 'الإثنين';
      case 'Tuesday':
        return 'الثلاثاء';
      case 'Wednesday':
        return 'الأربعاء';
      case 'Thursday':
        return ' ﴾  الخميس  ﴿';
      case 'Friday':
        return 'الجمعة';
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Prominent Location Banner ABOVE Prayer Times Card
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppColor.black.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: _isFallbackLocation
                    ? AppColor.golden.withValues(alpha: 0.5)
                    : AppColor.gold,
                width: 1.2,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _isFallbackLocation
                      ? Icons.location_off_outlined
                      : Icons.my_location_rounded,
                  color: _isFallbackLocation ? AppColor.golden : AppColor.gold,
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
                          color: AppColor.white.withValues(alpha: 0.6),
                          fontSize: 11,
                          fontFamily: 'Janna',
                        ),
                      ),
                      Text(
                        _locationName,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          color: AppColor.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Janna',
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.refresh_rounded,
                    color: AppColor.gold,
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
                  color: AppColor.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Center(
                  child: CircularProgressIndicator(color: AppColor.gold),
                ),
              )
            : _error != null || _model == null
            ? Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColor.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: AppColor.gold,
                      size: 36,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _error ?? 'تعذر تحميل مواقيت الصلاة',
                      style: const TextStyle(
                        color: AppColor.white,
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
                        side: const BorderSide(color: AppColor.gold),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'إعادة المحاولة',
                        style: TextStyle(
                          color: AppColor.gold,
                          fontFamily: 'Janna',
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.asset(AppAssets.group1, fit: BoxFit.cover),
                    ),
                    Positioned.fill(
                      child: Image.asset(AppAssets.group2, fit: BoxFit.cover),
                    ),
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
                              // Gregorian Date
                              Expanded(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    DateFormat(
                                      'dd MMM,\nyyyy',
                                    ).format(_model!.gregorianDate),
                                    style: const TextStyle(
                                      fontSize: 24,
                                      color: AppColor.white,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'alfont',
                                    ),
                                  ),
                                ),
                              ),
                              // Title & Day Name
                              Column(
                                children: [
                                  Text(
                                    _getArabicDayName(_model!.gregorianDate),
                                    style: TextStyle(
                                      fontSize: 45,
                                      color: AppColor.black.withValues(
                                        alpha: 1.8,
                                      ),
                                      fontWeight: FontWeight.w800,
                                      fontFamily: 'alfont',
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 19),
                              // Hijri Date
                              Expanded(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    "${_model!.hijriDay} ${_model!.hijriMonth}\n${_model!.hijriYear} هـ",
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      color: AppColor.white,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'alfont',
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Prayer Cards ListView
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

                          // Footer: Countdown & Sound Control
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppColor.black.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'الصلاة القادمة : ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 25,
                                    color: AppColor.black.withValues(
                                      alpha: 0.9,
                                    ),
                                    fontFamily: 'alfont',
                                  ),
                                ),
                                Text(
                                  _formatDuration(_nextPrayer!.remaining),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: AppColor.black,
                                    fontFamily: 'Janna',
                                  ),
                                ),
                                const SizedBox(width: 18),
                                InkWell(
                                  onTap: _isStartingAudio ? null : _toggleAdhan,
                                  borderRadius: BorderRadius.circular(20),
                                  child: Padding(
                                    padding: const EdgeInsets.all(4),
                                    child: Row(
                                      children: [
                                        Icon(
                                          _isPlaying
                                              ? Icons.volume_up
                                              : Icons.volume_off,
                                          color: AppColor.black,
                                          size: 22,
                                        ),
                                        const SizedBox(width: 15),
                                      ],
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: _showAdhanSettings,
                                  child: Icon(
                                    Icons.notifications_active,
                                    color: AppColor.black,
                                    size: 22,
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

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isActive ? 96 : 82,
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isActive
              ? [AppColor.gold, AppColor.golden]
              : [AppColor.gray, AppColor.black],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isActive
              ? AppColor.white
              : AppColor.gold.withValues(alpha: 0.3),
          width: isActive ? 1.5 : 1.0,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: AppColor.gold.withValues(alpha: 0.4),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ]
            : null,
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
              color: isActive ? AppColor.black : AppColor.white,
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
                color: isActive ? AppColor.black : AppColor.gold,
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
              color: isActive
                  ? AppColor.black.withValues(alpha: 0.8)
                  : AppColor.white.withValues(alpha: 0.7),
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
