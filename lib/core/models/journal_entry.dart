import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:keto_calculator/core/models/nutrition.dart';
import 'package:keto_calculator/core/utils/utils.dart';

// TODO get rid of weight field
class JournalEntry extends ConsumableItem {
  JournalEntry({
    required this.datetime,
    required this.title,
    required super.kcal,
    required super.proteins,
    required super.fats,
    required super.carbs,
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
      proteins: toDouble(json['proteins']),
      fats: toDouble(json['fats']),
      carbs: toDouble(json['carbs']),
      weightGrams: json.containsKey('weightGrams')
          ? toDouble(json['weightGrams'])
          : null,
    );
  }

  factory JournalEntry.fromConsumable(
    Consumable consumable, {
    DateTime? datetime,
    String? title,
    double? weightGrams,
  }) {
    datetime ??= DateTime.now();
    title ??= 'Something with ${consumable.kcal}kcal';
    return JournalEntry(
      title: title,
      datetime: datetime,
      proteins: consumable.proteins,
      fats: consumable.fats,
      carbs: consumable.carbs,
      kcal: consumable.kcal,
      weightGrams: weightGrams,
    );
  }

  final DateTime datetime;
  final String title;
  final double? weightGrams;
  final String? id;
  /* @override
  final double kcal;
  @override
  final double proteins;
  @override
  final double fats;
  @override
  final double carbs; */

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
      'proteins': proteins,
      'fats': fats,
      'carbs': carbs,
      if (weightGrams != null) 'weightGrams': weightGrams,
    };
  }

  @override
  String toString() {
    return 'JournalEntry(id:$id, title:$title, datetime:$datetime, kcal:$kcal)';
  }
}
