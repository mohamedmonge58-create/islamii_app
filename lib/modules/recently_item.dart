import 'package:flutter/material.dart';
import 'package:islamii_app/modules/sura_model.dart';

import '../core/app_assets.dart';
import '../core/app_color.dart';

class RecentlyItem extends StatelessWidget {
  final SuraModel suraModel;

  const RecentlyItem({super.key, required this.suraModel});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.gold,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.all(17.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  suraModel.englishName,
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                    fontSize: 24,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  suraModel.arabicName,
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                    fontSize: 24,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  suraModel.versesCount,
                  style: TextStyle(
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
    );
  }
}
