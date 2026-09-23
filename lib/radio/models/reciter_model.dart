// lib/models/reciter_model.dart
import 'moshaf_model.dart';

class ReciterModel {
  final int id;
  final String name;
  final String letter;
  final List<MoshafModel> moshaf;

  ReciterModel({
    required this.id,
    required this.name,
    required this.letter,
    required this.moshaf,
  });

  factory ReciterModel.fromJson(Map<String, dynamic> json) {
    return ReciterModel(
      id: json['id'],
      name: json['name'] ?? '',
      letter: json['letter'] ?? '',
      moshaf: (json['moshaf'] as List<dynamic>? ?? [])
          .map((e) => MoshafModel.fromJson(e))
          .toList(),
    );
  }

  MoshafModel? get defaultMoshaf {
    if (moshaf.isEmpty) return null;
    return moshaf.firstWhere(
      (m) => m.moshafType == 11,
      orElse: () => moshaf.first,
    );
  }
}
