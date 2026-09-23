import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:islamii_app/core/app_assets.dart';
import 'package:islamii_app/core/app_color.dart';
import 'package:islamii_app/core/recent_sura_cash.dart';
import 'package:islamii_app/modules/recently_item.dart';
import 'package:islamii_app/modules/sura_model.dart';
import 'package:islamii_app/quran/quran_view.dart';

class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key,});

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> {
  final List<SuraModel> suraList = SuraModel.suraList;

  @override
  void initState() {
    super.initState();
    _loadRecentSuras();
  }

  Future<void> _loadRecentSuras() async {
    final recentList = await RecentSuraCash.getRecentSuras();
    setState(() {
      _recentDataList = recentList.map((id) {
        return SuraModel.suraList.firstWhere(
              (sura) => sura.id == id,
        );
      }).toList();
    });
  }

  void _onSearchChanged(String value) {
    final query = value.trim();
    setState(() {
      if (query.isEmpty) {
        _filteredList = suraList;
      } else {
        _filteredList = suraList.where((sura) {
          return (sura.englishName.toLowerCase().contains(
              query.toLowerCase()) ||

              sura.arabicName.contains(query.toLowerCase()));
        }).toList();
      }
    });
  }

  List<SuraModel> _filteredList = SuraModel.suraList;
  List<SuraModel> _recentDataList = [];
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(AppAssets.backgroundNative),
          fit: BoxFit.cover,
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.asset(
                AppAssets.logo,
                height: 120,
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextFormField(
                cursorColor: AppColor.gold,
                onChanged: _onSearchChanged,
                style: TextStyle(color: AppColor.white),
                decoration: InputDecoration(
                  hintText: "Surah Name",
                  hintStyle: TextStyle(color: AppColor.white),

                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(12),

                    child: SvgPicture.asset(
                      AppAssets.quranSvgIcon,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColor.gold),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColor.gold),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            if (_recentDataList.isNotEmpty)

              SizedBox(height: 20),
            if (_recentDataList.isNotEmpty)

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "Most Recently",
                  style: TextStyle(
                    color: AppColor.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            if (_recentDataList.isNotEmpty)


              SizedBox(height: 10),

            if (_recentDataList.isNotEmpty)

              SizedBox(
                height: 150,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _recentDataList.length,
                  separatorBuilder: (context, index) =>
                      SizedBox(width: 10),

                  itemBuilder: (context, index) {
                    return RecentlyItem(
                      suraModel: _recentDataList[index],
                    );
                  },
                ),
              ),

            SizedBox(height: 20),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Surahs List",
                style: TextStyle(
                  color: AppColor.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            SizedBox(height: 10),

            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 20),
                itemCount: _filteredList.length,
                separatorBuilder: (context, index) =>
                    Divider(
                      color: AppColor.white,
                      thickness: .5,
                      indent: 30,
                      endIndent: 30,
                    ),
                itemBuilder: (context, index) {
                  final sura = _filteredList[index];

                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,

                    onTap: () async {
                      await RecentSuraCash.addsura(sura.id);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              QuranView(
                                sura: sura,
                              ),
                        ),
                      );

                      _loadRecentSuras();
                    },
                    child: Row(
                      children: [
                        SizedBox(
                          width: 50,
                          height: 50,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Image.asset(AppAssets.surNumberIcon),
                              Text(
                                "${sura.id}",
                                style: TextStyle(
                                  color: AppColor.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(width: 16),

                        Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              sura.englishName,
                              style: TextStyle(
                                color: AppColor.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              sura.versesCount,
                              style: TextStyle(
                                color: AppColor.white,
                              ),
                            ),
                          ],
                        ),

                        Spacer(),

                        Text(
                          sura.arabicName,
                          style: TextStyle(
                            color: AppColor.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}