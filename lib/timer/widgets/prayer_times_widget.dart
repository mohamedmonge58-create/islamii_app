// lib/screens/prayer_times_screen.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:islamii_app/core/app_assets.dart';
import 'package:islamii_app/core/app_color.dart';
import 'package:islamii_app/timer/widgets/prayer_times_helper.dart';

import '../../modules/prayer_times_model.dart';
import '../../services/prayer_times_service.dart';

class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  final _service = PrayerTimesService();
  final _scrollController = ScrollController();

  PrayerTimesModel? _model;
  NextPrayerInfo? _nextPrayer;
  Timer? _timer;
  bool _isMuted = false;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPrayerTimes();
  }

  Future<void> _loadPrayerTimes() async {
    try {
      final model = await _service.getTimingsByCity(
        city: 'cairo',
        country: 'egypt',
      );
      setState(() {
        _model = model;
        _nextPrayer = getNextPrayer(model);
        _isLoading = false;
      });
      _startCountdown();
      _scrollToCurrentPrayer();
    } catch (e) {
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
      setState(() => _nextPrayer = next);

      if (next.remaining.isNegative) {
        _loadPrayerTimes();
      }
    });
  }

  void _scrollToCurrentPrayer() {
    if (_nextPrayer == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final index = _nextPrayer!.index;
      const cardWidth = 110.0;
      final offset = (index * cardWidth) - 150;
      _scrollController.animateTo(
        offset.clamp(0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  String _formatDuration(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null || _model == null) {
      return Center(child: Text(_error ?? 'حدث خطأ'));
    }

    final model = _model!;
    final next = _nextPrayer!;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),

      child: Stack(
        children: [
          Image.asset(AppAssets.group1, fit: BoxFit.fill),
          Positioned.fill(
            child: Image.asset(AppAssets.group2, fit: BoxFit.fill),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        DateFormat('dd MMM,\nyyyy').format(model.gregorianDate),
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        "Pray Time",
                        style: TextStyle(
                          fontSize: 20,
                          color: AppColor.black.withOpacity(0.71),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        DateFormat('EEEE').format(model.gregorianDate),
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black.withOpacity(0.90),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 40),

                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    "${model.hijriDay} ${model.hijriMonth.substring(0, model.hijriMonth.length > 6 ? 6 : model.hijriMonth.length)},\n     ${model.hijriYear}",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 90,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 140,
              child: ListView(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                children: [
                  for (int i = 0; i < model.orderedPrayers.length; i++)
                    _PrayerCard(
                      name: model.orderedPrayers[i].key,
                      time: model.orderedPrayers[i].value,
                      isActive: i == next.index,
                    ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 20, // المسافة من تحت الكارت كله
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Next Pray -',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: AppColor.black.withOpacity(0.75),
                    ),
                  ),
                  Text(
                    " ${_formatDuration(next.remaining)}",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: AppColor.black,
                    ),
                  ),

                  SizedBox(width: 30),
                  GestureDetector(
                    onTap: () => setState(() => _isMuted = !_isMuted),
                    child: Icon(
                      _isMuted ? Icons.volume_off : Icons.volume_up,
                      color: AppColor.black,
                      size: 25,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
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

  @override
  Widget build(BuildContext context) {
    final period = DateFormat('a').format(time);
    final timeStr = DateFormat('hh:mm').format(time);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: isActive ? 128 : 106,
      width: isActive ? 104 : 86,
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topLeft,
          colors: [AppColor.golden, AppColor.black],
        ),

        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            name,
            style: TextStyle(
              color: Colors.white,
              fontSize: isActive ? 16 : 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            timeStr,
            style: TextStyle(
              color: Colors.white,
              fontSize: isActive ? 32 : 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            period,
            style: TextStyle(
              color: Colors.white,
              fontSize: isActive ? 16 : 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
