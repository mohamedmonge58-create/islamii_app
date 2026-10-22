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
          color: AppColor.gold,
          borderRadius: BorderRadius.circular(20),
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
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    suraModel.arabicName,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    suraModel.versesCount,
                    style: const TextStyle(
                      color: Colors.black,
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
