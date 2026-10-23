// lib/widgets/surah_picker_sheet.dart
import 'package:flutter/material.dart';
import 'package:islamii_app/core/app_color.dart';

import '../modules/sura_model.dart';
import '../radio/models/moshaf_model.dart';

/// يعرض Bottom Sheet فيه كل السور المتاحة عند القارئ ده.
/// يرجّع الـ SuraModel اللي اختاره المستخدم، أو null لو قفل من غير اختيار.
Future<SuraModel?> showSurahPicker({
  required BuildContext context,
  required String reciterName,
  required MoshafModel moshaf,
}) {
  final isLight = AppColor.isLight(context);
  final accentColor = AppColor.primary(context);
  final primaryTextColor = AppColor.primaryText(context);
  final secondaryTextColor = AppColor.secondaryText(context);

  final availableIds = moshaf.surahList
      .split(',')
      .where((e) => e.trim().isNotEmpty)
      .map((e) => int.parse(e.trim()))
      .toSet();

  final availableSuras = SuraModel.suraList
      .where((s) => availableIds.contains(s.id))
      .toList();

  return showModalBottomSheet<SuraModel>(
    context: context,
    backgroundColor: isLight ? AppColor.lightCardBg : AppColor.black,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                reciterName,
                style: TextStyle(
                  color: accentColor,
                  fontFamily: 'Janna',
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'اختر السورة',
                style: TextStyle(color: secondaryTextColor, fontSize: 13),
              ),
              Divider(color: AppColor.border(context), height: 20),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: availableSuras.length,
                  itemBuilder: (context, index) {
                    final sura = availableSuras[index];
                    return ListTile(
                      onTap: () => Navigator.pop(context, sura),
                      leading: CircleAvatar(
                        backgroundColor: accentColor,
                        radius: 18,
                        child: Text(
                          '${sura.id}',
                          style: TextStyle(
                            color: isLight ? AppColor.white : AppColor.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      title: Text(
                        'سورة ${sura.arabicName}',
                        style: TextStyle(
                          color: primaryTextColor,
                          fontFamily: 'Janna',
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(
                        sura.versesCount,
                        style: TextStyle(color: secondaryTextColor),
                      ),
                      trailing: Icon(Icons.play_arrow, color: accentColor),
                    );
                  },
                ),
              ),
            ],
          );
        },
      );
    },
  );
}
