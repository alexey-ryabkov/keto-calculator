import 'package:keto_calculator/core/models/product.dart';

class Meal {
  Meal({required this.product, required this.weightGrams});
  final ProductData product;
  final double weightGrams;
}
