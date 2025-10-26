import 'package:keto_calculator/core/models/app_error.dart';
import 'package:keto_calculator/core/models/nutrition.dart';
import 'package:keto_calculator/core/utils/utils.dart';

class ProductOffer {
  ProductOffer({
    required this.name,
    this.photo,
  });

  factory ProductOffer.fromJson(Map<String, dynamic> json) {
    return ProductOffer(
      name: (json['name'] ?? 'Unknown product') as String,
      photo: json['photo'] as String?,
    );
  }

  final String name;
  final String? photo;

  Map<String, dynamic> toJson() => {
    'name': name,
    if (photo != null) 'photo': photo,
  };

  @override
  String toString() => 'ProductOffer(name: $name)';
}

class ProductItem extends ProductOffer {
  ProductItem({
    required super.name,
    required this.id,
    super.photo,
  });
  factory ProductItem.fromJson(Map<String, dynamic> json) {
    return ProductItem(
      name: (json['name'] ?? 'Unknown product') as String,
      photo: json['photo'] as String?,
      id: json['id']?.toString(),
    );
  }

  final String? id;

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    if (id != null) 'id': id,
  };

  @override
  String toString() => 'ProductItem(id: $id, name: $name)';
}

class ProductData extends ProductItem
    with KetoFriendliness
    implements StoredConsumable {
  ProductData({
    required super.name,
    required double kcal,
    required double proteins,
    required double fats,
    required double carbs,
    double weightGrams = defProductWeightGrams,
    super.photo,
    super.id,
  }) : _carbs = carbs,
       _proteins = proteins,
       _fats = fats,
       _kcal = kcal,
       _weightGrams = weightGrams {
    if (weightGrams <= 0) {
      throw const UnexpectedError('weightGrams must be positive number');
    }
  }

  factory ProductData.fromJson(Map<String, dynamic> json) {
    final kcal = toDouble(json['kcal']);
    return ProductData(
      kcal: kcal,
      id: json['id']?.toString(),
      name: (json['name'] as String?) ?? _defName(kcal),
      proteins: toDouble(json['proteins']),
      fats: toDouble(json['fats']),
      carbs: toDouble(json['carbs']),
      weightGrams: toDouble(json['weightGrams']),
      photo: json['photo'] as String?,
    );
  }

  double _kcal;
  double _proteins;
  double _fats;
  double _carbs;
  double _weightGrams;
  static const defProductWeightGrams = 100.00;

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
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'kcal': _kcal,
    'proteins': _proteins,
    'fats': _fats,
    'carbs': _carbs,
    'weightGrams': _weightGrams,
  };

  static String _defName(num kcal) => 'Product with ${kcal}kcal';

  @override
  String toString() =>
      'ProductData(id: $id, name: $name, kcal: $kcal, weight, $weight';
}
