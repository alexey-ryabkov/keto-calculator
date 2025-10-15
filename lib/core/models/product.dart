class ProductOffer {
  ProductOffer({
    required this.name,
    this.image,
  });

  factory ProductOffer.fromJson(Map<String, dynamic> json) {
    return ProductOffer(
      name: (json['name'] ?? '') as String,
      image: (json['image'] as String?)?.isEmpty ?? true
          ? null
          : json['image'] as String?,
    );
  }

  final String name;
  final String? image;

  Map<String, dynamic> toJson() => {'name': name, 'image': image};
}

class ProductItem extends ProductOffer {
  ProductItem({
    required super.name,
    required this.id,
    super.image,
  });
  factory ProductItem.fromJson(Map<String, dynamic> json) {
    return ProductItem(
      name: (json['name'] ?? '') as String,
      image: (json['image'] as String?)?.isEmpty ?? true
          ? null
          : json['image'] as String?,
      id: (json['id'] is int)
          ? json['id'] as int
          : int.parse((json['id'] ?? '0').toString()),
    );
  }

  final int id;

  @override
  Map<String, dynamic> toJson() => {...super.toJson(), 'id': id};
}

class ProductData extends ProductItem {
  ProductData({
    required super.name,
    required this.kcalPer100g,
    required this.protein,
    required this.fat,
    required this.carbs,
    required this.keto,
    super.id = 0,
    super.image,
  });

  factory ProductData.fromJson(Map<String, dynamic> json) {
    double findNutrient(List<dynamic>? nutrients, String key) {
      if (nutrients == null) return 0;
      try {
        final node = nutrients.cast<Map<String, dynamic>?>().firstWhere(
          (n) => (n?['name'] as String?)?.toLowerCase() == key.toLowerCase(),
          orElse: () => null,
        );
        if (node == null) return 0;
        final val = node['amount'];
        if (val is num) return val.toDouble();
        return double.tryParse(val.toString()) ?? 0;
      } catch (_) {
        return 0;
      }
    }

    final nutrition = json['nutrition'] as Map<String, dynamic>?;
    final nutrients = nutrition?['nutrients'] as List<dynamic>?;

    final kcal = findNutrient(nutrients, 'Calories');
    final protein = findNutrient(nutrients, 'Protein');
    final fat = findNutrient(nutrients, 'Fat');
    final carbs = findNutrient(nutrients, 'Carbohydrates');

    return ProductData(
      name: json['name'] as String? ?? '',
      image: json['image'] as String?,
      id: (json['id'] is int)
          ? json['id'] as int
          : int.parse((json['id'] ?? '0').toString()),
      kcalPer100g: kcal,
      protein: protein,
      fat: fat,
      carbs: carbs,
      keto: (json['keto'] as bool?) ?? false,
    );
  }

  final double kcalPer100g;
  final double protein;
  final double fat;
  final double carbs;
  final bool keto;
}
