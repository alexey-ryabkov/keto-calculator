import 'package:keto_calculator/core/models/nutrition.dart';
import 'package:keto_calculator/core/utils/utils.dart';

(String, String) formatNutrients(Consumable consumable, {num? onWeight}) {
  final Consumable(:proteins, :fats, :carbs, :kcal) = consumable;
  return (
    '🍗 ${formatNumber(proteins)}g • '
        '🥑 ${formatNumber(fats)}g • '
        '🍞 ${formatNumber(carbs)}g',
    '🔥 ${formatNumber(kcal)}'
        'kcal${onWeight != null && onWeight > 0 ? ' '
                  '/ ${formatNumber(onWeight)}g' : ''}',
  );
}
