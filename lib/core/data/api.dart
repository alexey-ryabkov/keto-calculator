import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart';
import 'package:keto_calculator/core/models/app_error.dart';
import 'package:keto_calculator/core/models/product.dart';

base class HttpApiConfig {
  HttpApiConfig({this.timeout = 10_000});
  int timeout; // milliseconds
}

abstract class HttpApi {
  HttpApi(this._baseUrl, [HttpApiConfig? config, Client? httpClient])
    : _config = config ?? HttpApiConfig(),
      _client = httpClient ?? Client();
  final String _baseUrl;
  final HttpApiConfig _config;
  final Client _client;

  String get baseUrl => _baseUrl;
  HttpApiConfig get config => _config;

  Uri buildUri(String path, Map<String, String?> params) => Uri.parse(
    baseUrl + path,
  ).replace(queryParameters: params..removeWhere((_, v) => v == null));

  Future<T> get<T extends Object>(Uri uri) async {
    try {
      final timeout = Duration(milliseconds: config.timeout);
      final response = await _client.get(uri).timeout(timeout);

      // TODO need exhaustivness
      final code = response.statusCode;
      if (code >= 200 && code < 300) {
        try {
          return json.decode(response.body) as T;
        } catch (e) {
          throw ParsingError('Invalid JSON: $e');
        }
      } else if (code >= 400 && code < 500) {
        throw ApiError(code, '');
      } else if (code >= 500) {
        throw ServerApiError(code, '');
      }
      throw const UnexpectedError('Unknown server response');
    } on TimeoutException catch (e) {
      throw NetworkError('Request timeout: ${e.message}');
    } on ClientException catch (e) {
      throw NetworkError('Network error: ${e.message}');
    } catch (e) {
      throw UnexpectedError(e.toString());
    }
  }

  Future<void> dispose() async {
    _client.close();
  }
}

abstract interface class ProductApi {
  Future<List<ProductOffer>> getProductOffers(String query);
  Future<List<ProductItem>> getProductList(String query);
  Future<ProductData> getProductData(int id);
}
