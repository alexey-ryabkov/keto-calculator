import 'package:keto_calculator/core/models/product.dart';

class Meal {
  final Product product;
  final double weightGrams; // for simple percentage & display
  Meal({required this.product, required this.weightGrams});
}
