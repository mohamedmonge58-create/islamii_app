import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:geolocator/geolocator.dart';
import 'package:islamii_app/core/app_assets.dart';
import 'package:islamii_app/core/app_color.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  bool _isLoadingPermission = true;
  String? _errorMessage;

  // Kaaba Coordinates
  static const double kaabaLat = 21.422487;
  static const double kaabaLng = 39.826206;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    setState(() {
      _isLoadingPermission = true;
      _errorMessage = null;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _errorMessage =
              'خدمات الموقع (GPS) غير مفعلة، يرجى تفعيلها لحساب القبلة.';
          _isLoadingPermission = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        setState(() {
          _errorMessage =
              'تم رفض إذن الوصول للموقع. يرجى منحه لحساب اتجاه القبلة بدقة.';
          _isLoadingPermission = false;
        });
        return;
      }

      setState(() {
        _isLoadingPermission = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'حدث خطأ أثناء فحص أذونات الموقع.';
        _isLoadingPermission = false;
      });
    }
  }

  /// Math fallback: Calculate Qibla bearing angle relative to True North for a location
  double calculateQiblaBearing(double lat, double lng) {
    double phiK = kaabaLat * math.pi / 180.0;
    double lambdaK = kaabaLng * math.pi / 180.0;
    double phi = lat * math.pi / 180.0;
    double lambda = lng * math.pi / 180.0;

    double deltaLambda = lambdaK - lambda;

    double y = math.sin(deltaLambda);
    double x =
        math.cos(phi) * math.tan(phiK) - math.sin(phi) * math.cos(deltaLambda);

    double bearing = math.atan2(y, x) * 180.0 / math.pi;
    return (bearing + 360.0) % 360.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.black,
      appBar: AppBar(
        backgroundColor: AppColor.black,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'اتجاه القبلة',
          style: TextStyle(
            color: AppColor.gold,
            fontFamily: 'Janna',
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColor.gold),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage(AppAssets.backgroundNative),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              AppColor.black.withValues(alpha: 0.8),
              BlendMode.darken,
            ),
          ),
        ),
        child: SafeArea(
          child: _isLoadingPermission
              ? const Center(
                  child: CircularProgressIndicator(color: AppColor.gold),
                )
              : _errorMessage != null
              ? _buildErrorWidget()
              : StreamBuilder<QiblahDirection>(
                  stream: FlutterQiblah.qiblahStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: AppColor.gold),
                      );
                    }

                    if (snapshot.hasError || !snapshot.hasData) {
                      return _buildManualFallbackWidget();
                    }

                    final qiblahDirection = snapshot.data!;
                    final direction = qiblahDirection.direction;
                    final qiblah = qiblahDirection.qiblah;
                    final offset = qiblahDirection.offset;

                    // Check if facing Qibla within +/- 3 degrees
                    final isFacingQibla =
                        offset.abs() < 4.0 || (360.0 - offset.abs()) < 4.0;

                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Status Banner
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: isFacingQibla
                                  ? AppColor.gold.withValues(alpha: 0.2)
                                  : AppColor.gray.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isFacingQibla
                                    ? AppColor.gold
                                    : Colors.white24,
                                width: isFacingQibla ? 1.8 : 1.0,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  isFacingQibla
                                      ? Icons.stars_rounded
                                      : Icons.explore_outlined,
                                  color: AppColor.gold,
                                  size: 24,
                                ),
                                const SizedBox(width: 10),
                                Flexible(
                                  child: Text(
                                    isFacingQibla
                                        ? 'أنت الآن باتجاه القبلة الشريفة ✨'
                                        : 'قم بتدوير الهاتف حتى يتطابق المؤشر مع القبلة',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: AppColor.white,
                                      fontFamily: 'Janna',
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 30),

                          // Compass Dial Container
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              // Outer Glow when aligned
                              if (isFacingQibla)
                                Container(
                                  width: 280,
                                  height: 280,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColor.gold.withValues(
                                          alpha: 0.4,
                                        ),
                                        blurRadius: 30,
                                        spreadRadius: 8,
                                      ),
                                    ],
                                  ),
                                ),

                              // Compass Dial Background (Rotates opposite to heading)
                              Transform.rotate(
                                angle: (direction * (math.pi / 180) * -1),
                                child: Container(
                                  width: 270,
                                  height: 270,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColor.black.withValues(
                                      alpha: 0.7,
                                    ),
                                    border: Border.all(
                                      color: isFacingQibla
                                          ? AppColor.gold
                                          : AppColor.golden,
                                      width: 3,
                                    ),
                                  ),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: const [
                                      Positioned(
                                        top: 10,
                                        child: Text(
                                          'N',
                                          style: TextStyle(
                                            color: Colors.redAccent,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 10,
                                        child: Text(
                                          'S',
                                          style: TextStyle(
                                            color: AppColor.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        right: 12,
                                        child: Text(
                                          'E',
                                          style: TextStyle(
                                            color: AppColor.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        left: 12,
                                        child: Text(
                                          'W',
                                          style: TextStyle(
                                            color: AppColor.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // Qibla Pointer Needle (Rotates to Qibla angle)
                              Transform.rotate(
                                angle: (qiblah * (math.pi / 180) * -1),
                                child: Image.asset(
                                  AppAssets.mosque,
                                  width: 130,
                                  height: 130,
                                  fit: BoxFit.contain,
                                ),
                              ),

                              // Center Pin
                              Container(
                                width: 14,
                                height: 14,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColor.gold,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 36),

                          // Angle Information Cards
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildInfoBadge(
                                title: 'زاويــة القبلة',
                                value: '${qiblah.toStringAsFixed(1)}°',
                              ),
                              _buildInfoBadge(
                                title: 'اتجاه الهاتف',
                                value: '${direction.toStringAsFixed(1)}°',
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Calibration Note
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColor.black.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: AppColor.gold.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Row(
                              children: const [
                                Icon(
                                  Icons.info_outline_rounded,
                                  color: AppColor.gold,
                                  size: 20,
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'حرّك الهاتف على شكل رقم 8 لمعايرة البوصلة',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontFamily: 'Janna',
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }

  Widget _buildInfoBadge({required String title, required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppColor.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColor.gold.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontFamily: 'Janna',
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: AppColor.gold,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.location_off_rounded,
              color: AppColor.gold,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'تعذر تحديد الموقع',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColor.white,
                fontFamily: 'Janna',
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _checkPermissions,
              icon: const Icon(Icons.refresh, color: AppColor.black),
              label: const Text(
                'إعادة المحاولة / منح الإذن',
                style: TextStyle(
                  color: AppColor.black,
                  fontFamily: 'Janna',
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.gold,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManualFallbackWidget() {
    final double cairoQiblaBearing = calculateQiblaBearing(30.0444, 31.2357);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.compass_calibration_outlined,
              color: AppColor.gold,
              size: 48,
            ),
            const SizedBox(height: 16),
            const Text(
              'مستشعر البوصلة غير متوفر على هذا الجهاز',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColor.white,
                fontFamily: 'Janna',
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'زاوية اتجاه القبلة المحسوبة لمنطقتك هي: ${cairoQiblaBearing.toStringAsFixed(1)}° من الشمال الجغرافي (الكعبة المشرفة: $kaabaLat° N, $kaabaLng° E)',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white70,
                fontFamily: 'Janna',
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: _checkPermissions,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColor.gold),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'إعادة فحص المستشعرات',
                style: TextStyle(color: AppColor.gold, fontFamily: 'Janna'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
