import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:keto_calculator/core/models/nutrition.dart';
import 'package:keto_calculator/core/utils/utils.dart';

class JournalEntry implements Consumable {
  JournalEntry({
    required this.datetime,
    required this.title,
    required this.kcal,
    required this.proteins,
    required this.fats,
    required this.carbs,
    this.weightGrams,
    this.id,
  });

  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    final dt = parseDateTime(json['datetime']) ?? DateTime.now();
    return JournalEntry(
      id: json['id'] as String?,
      datetime: dt,
      title: (json['title'] as String?) ?? '',
      kcal: toDouble(json['kcal']),
      proteins: toDouble(json['protein']),
      fats: toDouble(json['fat']),
      carbs: toDouble(json['carbs']),
      weightGrams: json.containsKey('weightGrams')
          ? toDouble(json['weightGrams'])
          : null,
    );
  }

  final DateTime datetime;
  final String title;
  final double kcal;
  final double? weightGrams;
  final String? id;
  @override
  final double proteins;
  @override
  final double fats;
  @override
  final double carbs;

  JournalEntry copyWith({
    String? id,
    DateTime? datetime,
    String? title,
    double? kcal,
    double? protein,
    double? fat,
    double? carbs,
    double? weightGrams,
  }) {
    return JournalEntry(
      id: id ?? this.id,
      datetime: datetime ?? this.datetime,
      title: title ?? this.title,
      kcal: kcal ?? this.kcal,
      proteins: protein ?? proteins,
      fats: fat ?? fats,
      carbs: carbs ?? this.carbs,
      weightGrams: weightGrams ?? this.weightGrams,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'datetime': Timestamp.fromDate(datetime),
      'title': title,
      'kcal': kcal,
      'protein': proteins,
      'fat': fats,
      'carbs': carbs,
      if (weightGrams != null) 'weightGrams': weightGrams,
    };
  }

  @override
  String toString() {
    return 'JournalEntry(id:$id, title:$title, datetime:$datetime, kcal:$kcal)';
  }
}
