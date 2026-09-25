// lib/screens/prayer_times_screen.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:islamii_app/core/app_assets.dart';
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

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // نستنى فريم إضافي كمان لضمان إن الـ ListView خلص build فعليًا
      await Future.delayed(const Duration(milliseconds: 100));

      if (!mounted) return;
      if (!_scrollController.hasClients) return;

      try {
        final index = _nextPrayer!.index;
        const cardWidth = 110.0;
        final offset = (index * cardWidth) - 150;
        final maxScroll = _scrollController.position.maxScrollExtent;

        await _scrollController.animateTo(
          offset.clamp(0, maxScroll),
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      } catch (e) {
        // في حالة نادرة إن الـ controller اتشال بعد الـ check مباشرة
        debugPrint('Scroll skipped: $e');
      }
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
          // الخلفية: صورة group1 بس، مرة واحدة
          Positioned.fill(
            child: Image.asset(AppAssets.group1, fit: BoxFit.fill),
          ),

          // المحتوى فوق الصورة
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 24),

              // الهيدر
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          DateFormat(
                            'dd MMM,\nyyyy',
                          ).format(model.gregorianDate),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          const Text(
                            'Pray Time',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            DateFormat('EEEE').format(model.gregorianDate),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Text(
                          model.hijriDate,
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // شريط الصلوات
              SizedBox(
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

              // الفوتر
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 22),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Next Pray - ${_formatDuration(next.remaining)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () => setState(() => _isMuted = !_isMuted),
                      child: Icon(
                        _isMuted ? Icons.volume_off : Icons.volume_up,
                        color: Colors.black87,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
      width: isActive ? 100 : 85,
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isActive
              ? [const Color(0xFF3D3226), const Color(0xFF1A1510)]
              : [const Color(0xFF5A4A35), const Color(0xFF352A1E)],
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
              fontSize: isActive ? 14 : 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            timeStr,
            style: TextStyle(
              color: Colors.white,
              fontSize: isActive ? 24 : 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            period,
            style: TextStyle(
              color: Colors.white70,
              fontSize: isActive ? 13 : 11,
            ),
          ),
        ],
      ),
    );
  }
}
