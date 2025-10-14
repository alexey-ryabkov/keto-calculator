import 'package:cloud_firestore/cloud_firestore.dart';

class JournalEntry {
  JournalEntry({
    required this.datetime,
    required this.title,
    required this.kcal,
    required this.protein,
    required this.fat,
    required this.carbs,
    this.weightGrams,
    this.id,
  });

  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    final dt = _parseDateTime(json['datetime']) ?? DateTime.now();
    return JournalEntry(
      id: json['id'] as String?,
      // ??
      // (json['docId'] as String?), // accept doc id under different keys
      datetime: dt,
      title: (json['title'] as String?) ?? '',
      kcal: _toDouble(json['kcal']),
      protein: _toDouble(json['protein']),
      fat: _toDouble(json['fat']),
      carbs: _toDouble(json['carbs']),
      weightGrams: json.containsKey('weightGrams')
          ? _toDouble(json['weightGrams'])
          : null,
    );
  }

  final DateTime datetime;
  final String title;
  final double kcal;
  final double protein;
  final double fat;
  final double carbs;
  final double? weightGrams;
  final String? id;

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
      protein: protein ?? this.protein,
      fat: fat ?? this.fat,
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
      'protein': protein,
      'fat': fat,
      'carbs': carbs,
      if (weightGrams != null) 'weightGrams': weightGrams,
    };
  }

  // TODO below methods to utils?
  static DateTime? _parseDateTime(Object? v) {
    if (v == null) return null;
    if (v is Timestamp) return v.toDate();
    if (v is DateTime) return v;
    if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
    if (v is String) {
      final parsed = DateTime.tryParse(v);
      if (parsed != null) return parsed;
      final maybeInt = int.tryParse(v);
      if (maybeInt != null) {
        return DateTime.fromMillisecondsSinceEpoch(maybeInt);
      }
    }
    return null;
  }

  static double _toDouble(Object? v) {
    if (v == null) return 0.0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) return double.tryParse(v.replaceAll(',', '.')) ?? 0.0;
    return 0.0;
  }

  @override
  String toString() {
    return 'JournalEntry(id:$id, title:$title, datetime:$datetime, kcal:$kcal)';
  }
}
