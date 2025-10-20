import 'package:keto_calculator/core/models/product.dart';
import 'package:meta/meta.dart';

enum ProductsStatus { initial, loading, ready, empty, saving, error }

@immutable
class ProductsState {
  const ProductsState({
    required this.items,
    required this.status,
    this.error,
  });

  factory ProductsState.initial() =>
      const ProductsState(items: [], status: ProductsStatus.initial);

  final List<ProductData> items;
  final ProductsStatus status;
  final String? error;

  ProductsState copyWith({
    List<ProductData>? items,
    ProductsStatus? status,
    String? error,
  }) {
    return ProductsState(
      items: items ?? this.items,
      status: status ?? this.status,
      error: error ?? this.error,
    );
  }

  bool get isEmpty => items.isEmpty;
  int get count => items.length;

  @override
  String toString() => 'ProductsState(status=$status, count=${items.length})';
}
