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
}

class MealNutritrients implements Consumable {
  const MealNutritrients({
    required this.proteins,
    required this.fats,
    required this.carbs,
  });
  factory MealNutritrients.fromConsumable(Consumable consumable) {
    return MealNutritrients(
      proteins: consumable.proteins,
      fats: consumable.fats,
      carbs: consumable.carbs,
    );
  }
  @override
  final double proteins;
  @override
  final double fats;
  @override
  final double carbs;

  static const _proteinKcal = 4;
  static const _fatKcal = 9;
  static const _carbsKcal = 4;

  Map<NutrientType, double> get kcalByNutrients => {
    NutrientType.protein: proteins * _proteinKcal,
    NutrientType.fat: fats * _fatKcal,
    NutrientType.carb: carbs * _carbsKcal,
  };

  double get kcal => kcalByNutrients.values.reduce((a, b) => a + b);
}
