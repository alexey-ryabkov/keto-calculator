import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keto_calculator/core/models/nutrition.dart';
import 'package:keto_calculator/core/widgets/pie_chart_widget.dart';
import 'package:keto_calculator/features/profile/profile.dart';
import 'package:keto_calculator/features/tracking/bloc/journal_bloc.dart';
import 'package:keto_calculator/features/tracking/bloc/journal_state.dart';
import 'package:keto_calculator/features/tracking/models/models.dart';
import 'package:keto_calculator/features/tracking/widgets/macro_row.dart';
import 'package:keto_calculator/features/tracking/widgets/metric_row.dart';

class NutritionAnalytics extends StatelessWidget {
  const NutritionAnalytics({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final NutritionTarget(
      calories: targetCalories,
      proteinPercent: targetProteinPercent,
      fatPercent: targetFatPercent,
      carbPercent: targetCarbsPercent,
    ) = context.select(
      (ProfileBloc profileBloc) => profileBloc.nutritionTarget,
    )!;

    return BlocBuilder<JournalBloc, JournalState>(
      builder: (context, state) {
        final {
          'protein': totalProtein,
          'fat': totalFat,
          'carbs': totalCarbs,
        } = context
            .read<JournalBloc>()
            .totals;

        final totalNutrients = MealNutritrients(
          proteins: totalProtein,
          fats: totalFat,
          carbs: totalCarbs,
        );

        final totalCalories = totalNutrients.kcal;
        final kcalPercentsByNutrients = totalNutrients.kcalByNutrients.map(
          (nutrientName, nutrientKcal) => MapEntry(
            nutrientName,
            totalCalories > 0 ? nutrientKcal / totalCalories : 0.0,
          ),
        );
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                SizedBox(
                  width: 140,
                  height: 140,
                  child: PieChartWidget(
                    data: {
                      'Proteins':
                          kcalPercentsByNutrients[NutrientType.protein] ?? 0,
                      'Fats': kcalPercentsByNutrients[NutrientType.fat] ?? 0,
                      'Carbs': kcalPercentsByNutrients[NutrientType.carb] ?? 0,
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MetricRow(
                        label: 'Calories',
                        value: totalCalories.round().toString(),
                        status: _statusForKcal(targetCalories, totalCalories),
                      ),
                      const SizedBox(height: 6),
                      MacroRow(
                        label: 'Proteins',
                        grams: totalProtein,
                        percentOfMacros:
                            kcalPercentsByNutrients[NutrientType.protein] ?? 0,
                        targetPercent: targetProteinPercent,
                      ),
                      MacroRow(
                        label: 'Fats',
                        grams: totalFat,
                        percentOfMacros:
                            kcalPercentsByNutrients[NutrientType.fat] ?? 0,
                        targetPercent: targetFatPercent,
                      ),
                      MacroRow(
                        label: 'Carbs',
                        grams: totalCarbs,
                        percentOfMacros:
                            kcalPercentsByNutrients[NutrientType.carb] ?? 0,
                        targetPercent: targetCarbsPercent,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  StatusLevel _statusForKcal(int calories, double kcal) {
    final normalKcal = calories;
    // TODO percentage and deps from diet type
    if (kcal < normalKcal - 200) return StatusLevel.under;
    if (kcal > normalKcal + 200) return StatusLevel.over;
    return StatusLevel.ok;
  }
}
