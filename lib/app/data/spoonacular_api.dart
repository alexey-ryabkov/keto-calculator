import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:keto_calculator/core/data/api.dart';
import 'package:keto_calculator/core/models/app_error.dart';
import 'package:keto_calculator/core/models/product.dart';
import 'package:keto_calculator/core/utils/utils.dart';

const _baseUrl = 'https://api.spoonacular.com';
const _productAutocompletePath = '/food/ingredients/autocomplete';
const _productsSearchPath = '/food/ingredients/search';
const _productDataPath = '/food/ingredients/{id}/information';
const _imagesUrl =
    'https://img.spoonacular.com/ingredients_{size}x{size}/{name}';
const _apiKeyVarName = 'SPOONACULAR_KEY';
const _defSorting = {
  // TODO more relevant?
  'sort': 'calories',
  'sortDirection': 'asc',
};

class SpoonacularApi extends HttpApi implements ProductApi {
  SpoonacularApi._(
    this._apiKey, [
    HttpApiConfig? config,
    bool _muteOnError = true,
  ]) : muteOnError = _muteOnError,
       _productAmount = ProductData.defProductWeightGrams.toInt(),
       super(_baseUrl, config);

  static SpoonacularApi? _instance;
  final String _apiKey;
  final int _productAmount;
  bool muteOnError;

  static Future<SpoonacularApi> init([HttpApiConfig? config]) async {
    if (_instance == null) {
      await dotenv.load();
      final key = dotenv.env[_apiKeyVarName];
      if (key == null) throw Exception('$_apiKeyVarName missing');
      _instance = SpoonacularApi._(key, config);
    }
    return _instance!;
  }

  static SpoonacularApi get instance {
    if (_instance == null) {
      throw StateError(
        'Spoonacular API not initialized. Call init() first.',
      );
    }
    return _instance!;
  }

  @override
  Uri buildUri(String path, [Map<String, String?>? params]) {
    final queryParams = params ?? <String, String?>{};
    queryParams['apiKey'] = _apiKey;
    return super.buildUri(path, queryParams);
  }

  @override
  Future<List<ProductOffer>> getProductOffers(
    String query, {
    int count = 20,
  }) async {
    final uri = buildUri(_productAutocompletePath, {
      'query': query,
      'number': count.toString(),
      'metaInformation': 'false',
    });
    return await _runInErrorBoundry(() async {
          final results = await get<List<dynamic>>(
            uri,
          );
          return List<Map<String, dynamic>>.from(
            results,
          ).map(ProductOffer.fromJson).toList();
        }) ??
        [];
  }

  // TODO paging
  @override
  Future<List<ProductItem>> getProductList(
    String query, {
    int count = 20,
  }) async {
    final uri = buildUri(_productsSearchPath, {
      'query': query,
      'number': count.toString(),
      'metaInformation': 'false',
      ..._defSorting,
    });
    return await _runInErrorBoundry(() async {
          final {'results': List<dynamic> results} =
              await get<Map<String, dynamic>>(uri);
          return List<Map<String, dynamic>>.from(
            results,
          ).map(ProductItem.fromJson).toList();
        }) ??
        [];
  }

  @override
  Future<ProductData?> getProductData(String id) async {
    final path = _productDataPath.replaceFirst(
      '{id}',
      id,
    );
    final productAmount = _productAmount.toString();
    final uri = buildUri(path, {'amount': productAmount, 'unit': 'grams'});
    return _runInErrorBoundry(() async {
      final result = await get<Map<String, dynamic>>(uri);
      final name = result['name'] as String?;
      result['name'] = name?.capitalize();
      final photo = result['image'] as String?;
      result['photo'] = photo != null ? _getImageUrl(photo) : null;
      result['weightGrams'] = productAmount;
      _extractNutritions(result);
      return ProductData.fromJson(result);
    });
  }

  // @override
  String? _getImageUrl(
    String imgName, [
    // ProductImageSize? size = ProductImageSize.small,
    SpoonacularApiImgSize size = SpoonacularApiImgSize.small,
  ]) => imgName.isNotEmpty
      ? _imagesUrl
            .replaceAll(
              '{size}',
              // '${SpoonacularApiImgSize.fromProductImageSize(size!).px}',
              '${size.px}',
            )
            .replaceAll('{name}', imgName)
      : null;

  void _extractNutritions(Map<String, dynamic> result) {
    final nutrition = result['nutrition'] as Map<String, dynamic>?;
    final nutrients = nutrition?['nutrients'] as List<dynamic>?;

    double? find(String name) {
      final match = nutrients?.cast<Map<String, dynamic>>().firstWhere(
        (n) => n['name'] == name,
        orElse: () => <String, dynamic>{},
      );
      return match?['amount'] is num
          ? (match!['amount'] as num).toDouble()
          : null;
    }

    result.addAll({
      'proteins': find('Protein') ?? 0.0,
      'fats': find('Fat') ?? 0.0,
      'carbs': find('Carbohydrates') ?? 0.0,
      'kcal': find('Calories') ?? 0.0,
    });
  }

  Future<T?> _runInErrorBoundry<T>(Future<T> Function() request) async {
    try {
      return await request();
    } catch (e) {
      final hasApiError = e is ApiError;
      final error = hasApiError ? SpoonacularApiError.fromApiError(e) : e;
      if (muteOnError) {
        debugPrint(error.toString());
        return null;
      } else {
        if (hasApiError) {
          throw error as SpoonacularApiError;
        } else {
          rethrow;
        }
      }
    }
  }
}

enum SpoonacularApiImgSize {
  small(100),
  medium(250),
  large(500);

  const SpoonacularApiImgSize(this.px);
  final int px;

  // static SpoonacularApiImgSize fromProductImageSize(ProductImageSize size) =>
  //     SpoonacularApiImgSize.values.byName(size.name);
}

class SpoonacularApiError extends ApiError {
  const SpoonacularApiError(super.statusCode, super.message, [this.status]);
  factory SpoonacularApiError.fromJson(Map<String, dynamic> json) {
    return SpoonacularApiError(
      json['code'] as int? ?? 0,
      json['message'] as String? ?? ' Unexpected Spoonacular API error',
      json['status'] as String?,
    );
  }
  factory SpoonacularApiError.fromApiError(ApiError error) =>
      error.original != null
      ? SpoonacularApiError.fromJson(error.original as Map<String, dynamic>)
      : SpoonacularApiError(error.statusCode, error.message);
  final String? status;

  @override
  String toString() =>
      'SpoonacularApiError(code: $statusCode, message: $message, '
      'status: $status)';
}
