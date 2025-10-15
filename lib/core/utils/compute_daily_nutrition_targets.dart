import 'package:keto_calculator/core/models/nutrition.dart';
import 'package:keto_calculator/core/models/profile.dart';

NutritionTarget computeDailyNutritionTargets(Profile profile) {
  final sex = profile.sex;
  final weightKg = profile.weightKg;
  final heightCm = profile.heightCm;
  final lifestyle = profile.lifestyle;
  final dietType = profile.dietType;
  final birthdate = profile.birthdate;

  final now = DateTime.now();
  final age = now.difference(birthdate).inDays ~/ 365;

  double bmr;
  if (sex == Sex.male) {
    bmr = 10 * weightKg + 6.25 * heightCm - 5 * age + 5;
  } else {
    bmr = 10 * weightKg + 6.25 * heightCm - 5 * age - 161;
  }

  final activityFactor = switch (lifestyle) {
    Lifestyle.sedentary => 1.2,
    Lifestyle.lightlyActive => 1.375,
    Lifestyle.active => 1.55,
    Lifestyle.veryActive => 1.725,
  };

  final tdee = (bmr * activityFactor).round();

  double protPct;
  double fatPct;
  double carbPct;

  switch (dietType) {
    case DietType.notKeto:
      protPct = 20.0;
      fatPct = 30.0;
      carbPct = 50.0;
    case DietType.keto:
      protPct = 25.0;
      fatPct = 70.0;
      carbPct = 5.0;
    case DietType.strictKeto:
      protPct = 20.0;
      fatPct = 75.0;
      carbPct = 5.0;
  }

  final sum = protPct + fatPct + carbPct;
  if (sum != 100.0) {
    protPct = protPct / sum * 100;
    fatPct = fatPct / sum * 100;
    carbPct = carbPct / sum * 100;
  }

  return NutritionTarget(
    calories: tdee,
    proteinPercent: protPct,
    fatPercent: fatPct,
    carbPercent: carbPct,
  );
}
