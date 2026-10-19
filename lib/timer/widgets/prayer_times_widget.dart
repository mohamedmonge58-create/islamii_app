import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:islamii_app/core/app_assets.dart';
import 'package:islamii_app/core/app_color.dart';
import 'package:islamii_app/timer/widgets/prayer_times_helper.dart';

import '../../modules/prayer_times_model.dart';
import '../../services/prayer_times_service.dart';

class PrayerTimesWidget extends StatefulWidget {
  const PrayerTimesWidget({super.key});

  @override
  State<PrayerTimesWidget> createState() => _PrayerTimesWidgetState();
}

class _PrayerTimesWidgetState extends State<PrayerTimesWidget> {
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
      if (!mounted) return;
      setState(() {
        _model = model;
        _nextPrayer = getNextPrayer(model);
        _isLoading = false;
        _error = null;
      });
      _startCountdown();
      _scrollToCurrentPrayer();
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

  String _formatDuration(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
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
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        height: 220,
        decoration: BoxDecoration(
          color: AppColor.black.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(24),
          // border: Border.all(color: AppColor.gold.withValues(alpha: 0.3)),
        ),
        // child: const Center(
        //   child: CircularProgressIndicator(color: AppColor.gold),
        // ),
      );
    }

    if (_error != null || _model == null) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColor.black.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(24),
          // border: Border.all(color: AppColor.gold.withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // const Icon(Icons.error_outline, color: AppColor.gold, size: 36),
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
                // side: const BorderSide(color: AppColor.gold),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'إعادة المحاولة',
                style: TextStyle(color: AppColor.gold, fontFamily: 'Janna'),
              ),
            ),
          ],
        ),
      );
    }

    final model = _model!;
    final next = _nextPrayer!;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        // border: Border.all(color: AppColor.gold, width: 1.2),
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
            padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header Row: Dates and Title
                Row(
                  children: [
                    // Gregorian Date
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          DateFormat(
                            'dd MMM,\n yyyy',
                          ).format(model.gregorianDate),
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColor.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Title
                    Column(
                      children: [
                        Text(
                          "Pray Time",
                          style: TextStyle(
                            fontSize: 18,
                            color: AppColor.black.withValues(alpha: 0.8),
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Janna',
                          ),
                        ),
                        Text(
                          DateFormat('EEEE').format(model.gregorianDate),
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColor.black.withValues(alpha: 0.95),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                    // Hijri Date
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Text(
                          "${model.hijriDay} ${model.hijriMonth}\n${model.hijriYear}",
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColor.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Prayer Cards ListView / Carousel
                SizedBox(
                  height: 135,
                  child: ListView.builder(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    itemCount: model.orderedPrayers.length,
                    itemBuilder: (context, index) {
                      final prayer = model.orderedPrayers[index];
                      return _PrayerCard(
                        name: prayer.key,
                        time: prayer.value,
                        isActive: index == next.index,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Footer: Countdown & Sound
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
                        'Next Pray - ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: AppColor.black.withValues(alpha: 0.8),
                          fontFamily: 'Janna',
                        ),
                      ),
                      Text(
                        _formatDuration(next.remaining),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColor.black,
                        ),
                      ),
                      const SizedBox(width: 24),
                      InkWell(
                        onTap: () => setState(() => _isMuted = !_isMuted),
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Icon(
                            _isMuted ? Icons.volume_off : Icons.volume_up,
                            color: AppColor.black,
                            size: 24,
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
              fontSize: isActive ? 15 : 13,
              fontWeight: FontWeight.bold,
              fontFamily: 'Janna',
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
            ),
          ),
        ],
      ),
    );
  }
}
