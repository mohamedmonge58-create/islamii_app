import 'package:flutter/material.dart';
import 'package:islamii_app/core/app_color.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/azkar_model.dart';

class AzkarScreen extends StatefulWidget {
  final String title;
  final List<AzkarModel> azkarList;

  const AzkarScreen({super.key, required this.title, required this.azkarList});

  @override
  State<AzkarScreen> createState() => _AzkarScreenState();
}

class _AzkarScreenState extends State<AzkarScreen> {
  late List<int> _remainingCounts;
  bool _isLoaded = false;

  String get _progressKey => 'azkar_progress_${widget.title}';

  String get _dateKey => 'azkar_date_${widget.title}';

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  String _todayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month}-${now.day}';
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final savedDate = prefs.getString(_dateKey);
    final today = _todayString();

    if (!mounted) return;

    if (savedDate != today) {
      setState(() {
        _remainingCounts = widget.azkarList.map((a) => a.repeatCount).toList();
        _isLoaded = true;
      });
      await prefs.setString(_dateKey, today);
      await _saveProgress();
      return;
    }

    final saved = prefs.getStringList(_progressKey);
    setState(() {
      if (saved != null && saved.length == widget.azkarList.length) {
        _remainingCounts = saved.map((e) => int.parse(e)).toList();
      } else {
        _remainingCounts = widget.azkarList.map((a) => a.repeatCount).toList();
      }
      _isLoaded = true;
    });
  }

  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _progressKey,
      _remainingCounts.map((e) => e.toString()).toList(),
    );
    await prefs.setString(_dateKey, _todayString());
  }

  void _decrementCount(int index) {
    if (_remainingCounts[index] <= 0) return;
    setState(() {
      _remainingCounts[index]--;
    });
    _saveProgress();
  }

  void _resetAll() {
    setState(() {
      _remainingCounts = widget.azkarList.map((a) => a.repeatCount).toList();
    });
    _saveProgress();
  }

  @override
  Widget build(BuildContext context) {
    final isLight = AppColor.isLight(context);
    final accentColor = AppColor.primary(context);

    if (!_isLoaded) {
      return Scaffold(
        backgroundColor: AppColor.background(context),
        body: Center(child: CircularProgressIndicator(color: accentColor)),
      );
    }

    final total = widget.azkarList.length;
    final completed = _remainingCounts.where((c) => c == 0).length;

    return Scaffold(
      backgroundColor: AppColor.background(context),
      appBar: AppBar(
        backgroundColor: AppColor.background(context),
        elevation: 0,
        centerTitle: true,
        title: Text(
          widget.title,
          style: TextStyle(
            color: accentColor,
            fontFamily: 'Janna',
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        iconTheme: IconThemeData(color: accentColor),
        actions: [
          IconButton(
            onPressed: _resetAll,
            icon: Icon(Icons.refresh, color: accentColor),
            tooltip: 'إعادة تعيين',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: total == 0 ? 0 : completed / total,
                    backgroundColor: isLight
                        ? AppColor.lightBordersDividers
                        : Colors.white12,
                    color: accentColor,
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "$completed من $total ذكر",
                  style: TextStyle(
                    color: AppColor.secondaryText(context),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: widget.azkarList.length,
              itemBuilder: (context, index) {
                final azkar = widget.azkarList[index];
                final remaining = _remainingCounts[index];
                final isDone = remaining == 0;

                final cardBg = isLight
                    ? (isDone
                          ? AppColor.lightPrimaryEmerald.withValues(alpha: 0.1)
                          : AppColor.lightCardBg)
                    : (isDone
                          ? AppColor.gold.withValues(alpha: 0.15)
                          : Colors.white.withValues(alpha: 0.05));

                final cardBorder = isLight
                    ? AppColor.lightPrimaryEmerald
                    : AppColor.gold;

                final textColor = isLight
                    ? (isDone
                          ? AppColor.lightSecondaryText
                          : AppColor.lightPrimaryText)
                    : (isDone
                          ? AppColor.white.withValues(alpha: 0.5)
                          : AppColor.white);

                final circleBg = isDone ? Colors.transparent : accentColor;
                final circleText = isDone
                    ? accentColor
                    : (isLight ? AppColor.white : AppColor.black);

                return GestureDetector(
                  onTap: () => _decrementCount(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isDone
                            ? cardBorder.withValues(alpha: 0.4)
                            : cardBorder,
                        width: 1.2,
                      ),
                      boxShadow: isLight && !isDone
                          ? [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          azkar.text,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 19,
                            fontFamily: 'Janna',
                            fontWeight: FontWeight.w600,
                            height: 1.6,
                          ),
                        ),
                        if (azkar.note != null) ...[
                          const SizedBox(height: 10),
                          Text(
                            azkar.note!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: accentColor.withValues(alpha: 0.85),
                              fontSize: 13,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isDone
                                  ? Icons.check_circle
                                  : Icons.radio_button_unchecked,
                              color: isDone
                                  ? accentColor
                                  : accentColor.withValues(alpha: 0.6),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 46,
                              height: 46,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: circleBg,
                                shape: BoxShape.circle,
                                border: isDone
                                    ? Border.all(
                                        color: accentColor.withValues(
                                          alpha: 0.4,
                                        ),
                                      )
                                    : null,
                              ),
                              child: Text(
                                "$remaining",
                                style: TextStyle(
                                  color: circleText,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
