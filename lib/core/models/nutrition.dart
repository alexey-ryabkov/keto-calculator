class NutritionTarget {
  const NutritionTarget({
    required this.calories,
    required this.proteinPercent,
    required this.fatPercent,
    required this.carbPercent,
  });
  final int calories;
  final double proteinPercent;
  final double fatPercent;
  final double carbPercent;
}

enum NutrientType { protein, fat, carb }

abstract interface class Consumable {
  double get proteins;
  double get fats;
  double get carbs;
  double get kcal;
}

class ConsumableItem implements Consumable {
  ConsumableItem({
    required this.proteins,
    required this.fats,
    required this.carbs,
    double? kcal,
  }) : _kcal = kcal;

  double? _kcal;
  @override
  double proteins;
  @override
  double fats;
  @override
  double carbs;

  static const _proteinKcal = 4;
  static const _fatKcal = 9;
  static const _carbsKcal = 4;

  Map<NutrientType, double> get kcalByNutrients => {
    NutrientType.protein: proteins * _proteinKcal,
    NutrientType.fat: fats * _fatKcal,
    NutrientType.carb: carbs * _carbsKcal,
  };

  @override
  double get kcal => _kcal ?? kcalByNutrients.values.reduce((a, b) => a + b);
  set kcal(double value) => _kcal = kcal;
}
