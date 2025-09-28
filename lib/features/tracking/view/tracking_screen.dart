import 'package:flutter/material.dart';
import 'package:keto_calculator/core/models/meal.dart';
import 'package:keto_calculator/core/widgets/pie_chart_widget.dart';
import 'package:keto_calculator/features/tracking/models/models.dart';
import 'package:keto_calculator/features/tracking/widgets/macro_row_widget.dart';
import 'package:keto_calculator/features/tracking/widgets/metric_row_widget.dart';

class TrackingScreen extends StatelessWidget {
  final DateTime selectedDate;
  final List<Meal> meals;
  final VoidCallback onPrevDay;
  final VoidCallback onNextDay;
  final void Function(int index) onRemoveMeal;

  const TrackingScreen({
    super.key,
    required this.selectedDate,
    required this.meals,
    required this.onPrevDay,
    required this.onNextDay,
    required this.onRemoveMeal,
  });

  // target macros for demo
  Map<String, double> get _targetPercents => {
    'protein': 0.30,
    'fat': 0.45,
    'carbs': 0.25,
  };

  // compute totals based on meals
  Map<String, double> _computeTotals() {
    double kcal = 0, protein = 0, fat = 0, carbs = 0;
    for (final m in meals) {
      final factor = m.weightGrams / 100.0;
      kcal += m.product.kcalPer100g * factor;
      protein += m.product.protein * factor;
      fat += m.product.fat * factor;
      carbs += m.product.carbs * factor;
    }
    return {
      'kcal': kcal,
      'protein': protein,
      'fat': fat,
      'carbs': carbs,
    };
  }

  @override
  Widget build(BuildContext context) {
    final totals = _computeTotals();
    final totalCalories = totals['kcal']!;
    // For pie chart we convert grams->calories roughly: protein 4 kcal/g, carbs 4, fat 9
    final protCal = totals['protein']! * 4;
    final fatCal = totals['fat']! * 9;
    final carbCal = totals['carbs']! * 4;
    final macroCalories = {
      'protein': protCal,
      'fat': fatCal,
      'carbs': carbCal,
    };
    final macroSum = macroCalories.values.fold(0.0, (a, b) => a + b);
    final percents = macroCalories.map(
      (k, v) => MapEntry(k, macroSum > 0 ? v / macroSum : 0.0),
    );

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: onPrevDay,
                  icon: const Icon(Icons.arrow_back),
                ),
                Expanded(
                  child: Text(
                    '${selectedDate.day.toString().padLeft(2, '0')}.${selectedDate.month.toString().padLeft(2, '0')}.${selectedDate.year}',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  onPressed: onNextDay,
                  icon: const Icon(Icons.arrow_forward),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    SizedBox(
                      width: 140,
                      height: 140,
                      child: PieChartWidget(
                        data: {
                          'Protein': percents['protein'] ?? 0,
                          'Fat': percents['fat'] ?? 0,
                          'Carbs': percents['carbs'] ?? 0,
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MetricRowWidget(
                            label: 'Калории',
                            value: totalCalories.round().toString(),
                            status: _statusForKcal(totalCalories),
                          ),
                          const SizedBox(height: 6),
                          MacroRowWidget(
                            label: 'Белки',
                            grams: totals['protein']!,
                            percentOfMacros: percents['protein'] ?? 0,
                            targetPercent: _targetPercents['protein']!,
                          ),
                          MacroRowWidget(
                            label: 'Жиры',
                            grams: totals['fat']!,
                            percentOfMacros: percents['fat'] ?? 0,
                            targetPercent: _targetPercents['fat']!,
                          ),
                          MacroRowWidget(
                            label: 'Углеводы',
                            grams: totals['carbs']!,
                            percentOfMacros: percents['carbs'] ?? 0,
                            targetPercent: _targetPercents['carbs']!,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Съеденное',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: meals.isEmpty
                  ? Center(child: Text('Нет записей за этот день'))
                  : ListView.builder(
                      itemCount: meals.length,
                      itemBuilder: (context, idx) {
                        final m = meals[idx];
                        return Dismissible(
                          key: ValueKey('${m.product.name}-$idx'),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            color: Colors.red,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: const Icon(
                              Icons.delete_forever,
                              color: Colors.white,
                            ),
                          ),
                          onDismissed: (_) => onRemoveMeal(idx),
                          child: ListTile(
                            leading: CircleAvatar(
                              child: Text(m.product.name[0]),
                            ),
                            title: Text(m.product.name),
                            subtitle: Text(
                              '${m.weightGrams.round()} г — ${m.product.kcalPer100g} kcal /100g',
                            ),
                            trailing: ElevatedButton(
                              onPressed: () {},
                              child: const Text('View'),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // simple demo status for kcal
  StatusLevel _statusForKcal(double kcal) {
    // hardcoded demo norm
    const norm = 2000;
    if (kcal < norm - 200) return StatusLevel.under;
    if (kcal > norm + 200) return StatusLevel.over;
    return StatusLevel.ok;
  }
}
