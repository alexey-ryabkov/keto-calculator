import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:keto_calculator/core/models/app_error.dart';
import 'package:keto_calculator/core/models/nutrition.dart';
import 'package:keto_calculator/core/utils/utils.dart';

class Meal with KetoFriendliness implements StoredConsumable {
  Meal({
    required this.created,
    required this.name,
    required double kcal,
    required double proteins,
    required double fats,
    required double carbs,
    required double weightGrams,
    this.consumedCnt = 0,
    bool? isKetoFriendly,
    this.photo,
    this.id,
  }) : _carbs = carbs,
       _proteins = proteins,
       _fats = fats,
       _kcal = kcal,
       _weightGrams = weightGrams,
       _isKetoFriendly = isKetoFriendly {
    if (weightGrams <= 0) {
      throw const UnexpectedError('weightGrams must be positive number');
    }
  }

  factory Meal.fromJson(Map<String, dynamic> json) {
    final kcal = toDouble(json['kcal']);
    return Meal(
      id: json['id'] as String?,
      created: parseDateTime(json['created']) ?? DateTime.now(),
      name: (json['name'] as String?) ?? _defName(kcal),
      kcal: kcal,
      proteins: toDouble(json['proteins']),
      fats: toDouble(json['fats']),
      carbs: toDouble(json['carbs']),
      weightGrams: toDouble(json['weightGrams']),
      consumedCnt: toInt(json['consumedCnt']),
      photo: json['photo'] as String?,
      isKetoFriendly: parseBool(json['isKetoFriendly']),
    );
  }

  factory Meal.fromConsumable(
    Consumable consumable, {
    required double weightGrams,
    bool? isKetoFriendly,
    DateTime? created,
    String? photo,
    String? name,
  }) {
    name ??= _defName(consumable.kcal);
    return Meal(
      created: created ?? DateTime.now(),
      name: name,
      proteins: consumable.proteins,
      fats: consumable.fats,
      carbs: consumable.carbs,
      kcal: consumable.kcal,
      weightGrams: weightGrams,
      photo: photo,
      isKetoFriendly: isKetoFriendly,
    );
  }

  final DateTime created;
  final int? consumedCnt;
  @override
  final String name;
  @override
  final String? photo;
  @override
  final String? id;
  double _kcal;
  double _proteins;
  double _fats;
  double _carbs;
  double _weightGrams;

  final bool? _isKetoFriendly;

  @override
  double get kcal => _kcal;
  @override
  double get proteins => _proteins;
  @override
  double get fats => _fats;
  @override
  double get carbs => _carbs;
  @override
  double get weight => _weightGrams;
  set weight(double value) {
    if (value <= 0) return;
    _kcal = (_kcal / _weightGrams) * value;
    _proteins = (_proteins / _weightGrams) * value;
    _fats = (_fats / _weightGrams) * value;
    _carbs = (_carbs / _weightGrams) * value;
    _weightGrams = value;
  }

  @override
  bool isKetoFriendly({bool isStrict = false, bool considerWeight = false}) {
    return _isKetoFriendly ??
        super.isKetoFriendly(
          isStrict: isStrict,
          considerWeight: considerWeight,
        );
  }

  Meal copyWith({
    String? id,
    DateTime? created,
    String? name,
    double? kcal,
    double? proteins,
    double? fats,
    double? carbs,
    double? weightGrams,
    bool? isKetoFriendly,
    int? consumedCnt,
    String? photo,
  }) {
    return Meal(
      id: id ?? this.id,
      created: created ?? this.created,
      name: name ?? this.name,
      kcal: kcal ?? _kcal,
      proteins: proteins ?? _proteins,
      fats: fats ?? _fats,
      carbs: carbs ?? _carbs,
      weightGrams: weightGrams ?? _weightGrams,
      consumedCnt: consumedCnt ?? this.consumedCnt,
      isKetoFriendly: isKetoFriendly ?? _isKetoFriendly,
      photo: photo ?? this.photo,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'datetime': Timestamp.fromDate(created),
      'name': name,
      'kcal': _kcal,
      'proteins': _proteins,
      'fats': _fats,
      'carbs': _carbs,
      'weightGrams': _weightGrams,
      if (consumedCnt != null) 'consumedCnt': consumedCnt,
      if (_isKetoFriendly != null) 'isKetoFriendly': _isKetoFriendly,
      if (photo != null) 'photo': photo,
    };
  }

  static String _defName(num kcal) => 'Meal with ${kcal}kcal';

  @override
  String toString() =>
      'Meal(id:$id, name:$name, kcal:$_kcal, weight, $weight, '
      'created:$created)';
}
