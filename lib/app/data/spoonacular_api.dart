import 'dart:async';

import 'package:keto_calculator/core/data/api.dart';
import 'package:keto_calculator/core/models/app_error.dart';
import 'package:keto_calculator/core/models/product.dart';

const String _baseUrl = 'https://api.spoonacular.com';
const String _productsSearchPath = '/food/ingredients/search';
const String _productDataPath = '/food/ingredients/{id}/information';
const String _searchAllPath = '/food/search';

class SpoonacularApi extends HttpApi implements ProductApi {
  SpoonacularApi(this._apiKey, [HttpApiConfig? config])
    : super(_baseUrl, config);

  final String _apiKey;

  @override
  Uri buildUri(String path, Map<String, String?> params) {
    params['apiKey'] = _apiKey;
    return super.buildUri(path, params);
  }

  @override
  Future<List<ProductOffer>> getProductOffers(String query) async {
    final uri = super.buildUri(_searchAllPath, {
      'query': query,
      'number': '10',
    });
    final jsonBody = await get(uri) as Map<String, dynamic>?;

    final foods =
        jsonBody?['searchResults'] as List<dynamic>? ??
        jsonBody?['results'] as List<dynamic>? ??
        [];
    return foods.map((f) {
      final m = f as Map<String, dynamic>;
      final name = m['name'] as String? ?? m['title'] as String? ?? '';
      final image = m['image'] as String?;
      return ProductOffer(name: name, image: image);
    }).toList();
  }

  @override
  Future<List<ProductItem>> getProductList(String query) async {
    final uri = buildUri(_productsSearchPath, {
      'query': query,
      'number': '20',
    });
    final jsonBody = await get(uri) as Map<String, dynamic>?;

    final results = (jsonBody?['results'] as List<dynamic>?) ?? [];
    return results
        .map((e) => ProductItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<ProductData> getProductData(int id) async {
    final path = _productDataPath.replaceFirst(
      '{id}',
      id.toString(),
    );
    final uri = buildUri(path, {'amount': '100'});
    final jsonBody = await get(uri) as Map<String, dynamic>?;
    if (jsonBody == null) throw ParsingError('Empty body for product $id');
    return ProductData.fromJson(jsonBody);
  }
}
