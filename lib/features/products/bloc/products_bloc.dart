import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:keto_calculator/core/models/product.dart';
import 'package:keto_calculator/features/products/bloc/products_state.dart';
import 'package:keto_calculator/features/products/data/products_repository.dart';

class ProductsBloc extends Cubit<ProductsState> {
  ProductsBloc() : super(ProductsState.initial());

  Future<void> init() => loadProducts();

  // TODO paging
  Future<void> loadProducts() async {
    emit(state.copyWith(status: ProductsStatus.loading));
    try {
      final items = await ProductsRepository.instance.getList();
      if (items.isEmpty) {
        emit(state.copyWith(items: [], status: ProductsStatus.empty));
      } else {
        emit(state.copyWith(items: items, status: ProductsStatus.ready));
      }
    } catch (e) {
      debugPrint('ProductsBloc.loadProducts error: $e');
      emit(state.copyWith(status: ProductsStatus.error, error: e.toString()));
    }
  }

  Future<void> saveProduct(ProductData product) async {
    emit(state.copyWith(status: ProductsStatus.saving));
    try {
      await ProductsRepository.instance.save(product);
      await loadProducts();
    } catch (e) {
      emit(state.copyWith(status: ProductsStatus.error, error: e.toString()));
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      await ProductsRepository.instance.delete(id);
      await loadProducts();
    } catch (e) {
      emit(state.copyWith(status: ProductsStatus.error, error: e.toString()));
    }
  }
}
