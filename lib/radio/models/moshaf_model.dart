// lib/models/moshaf_model.dart
class MoshafModel {
  final int id;
  final String name;
  final int rewayaId;
  final String server;
  final int surahTotal;
  final int moshafType;
  final String surahList;

  MoshafModel({
    required this.id,
    required this.name,
    required this.rewayaId,
    required this.server,
    required this.surahTotal,
    required this.moshafType,
    required this.surahList,
  });

  factory MoshafModel.fromJson(Map<String, dynamic> json) {
    return MoshafModel(
      id: json['id'],
      name: json['name'] ?? '',
      rewayaId: json['rewaya_id'] ?? 0,
      server: json['server'] ?? '',
      surahTotal: json['surah_total'] ?? 0,
      moshafType: json['moshaf_type'] ?? 0,
      surahList: json['surah_list'] ?? '',
    );
  }

  /// Builds the mp3 url for a given surah number (1-114)
  String surahUrl(int surahNumber) {
    final padded = surahNumber.toString().padLeft(3, '0');
    return '$server$padded.mp3';
  }
}
