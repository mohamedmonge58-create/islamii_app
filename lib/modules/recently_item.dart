import 'package:flutter/material.dart';
import 'package:islamii_app/modules/sura_model.dart';

import '../core/app_assets.dart';
import '../core/app_color.dart';
import '../core/recent_sura_cash.dart';
import '../quran/quran_view.dart';

class RecentlyItem extends StatelessWidget {
  final SuraModel suraModel;

  const RecentlyItem({super.key, required this.suraModel});

  @override
  Widget build(BuildContext context) {
    final isLight = AppColor.isLight(context);
    final cardColor = isLight ? AppColor.lightPrimaryEmerald : AppColor.gold;
    final textColor = isLight ? AppColor.white : Colors.black;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        await RecentSuraCash.addsura(suraModel.id);
        if (!context.mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => QuranView(sura: suraModel)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: isLight
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColor.lightPrimaryEmerald,
                    AppColor.lightPrimaryDark,
                  ],
                )
              : null,
          color: isLight ? null : cardColor,
          borderRadius: BorderRadius.circular(20),
          border: isLight
              ? Border.all(
                  color: AppColor.lightGoldAccent.withValues(alpha: 0.4),
                  width: 1.2,
                )
              : null,
          boxShadow: isLight
              ? [
                  BoxShadow(
                    color: AppColor.lightPrimaryEmerald.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(17.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    suraModel.englishName,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    suraModel.arabicName,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    suraModel.versesCount,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 130,
              height: 130,
              child: Image.asset(AppAssets.moshafSvgIcon, fit: BoxFit.cover),
            ),
          ],
        ),
      ),
    );
  }
}
