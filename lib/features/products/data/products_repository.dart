import 'package:keto_calculator/core/data/repository.dart';
import 'package:keto_calculator/core/models/product.dart';

class ProductsRepository extends MultiItemsRepository<ProductsRepository> {
  ProductsRepository._(super.source) : _source = source;
  final MultiItemsSource _source;
  // static const _itemsOrder = [
  //   SourceItemsOrder('consumedCnt', descending: true),
  //   SourceItemsOrder('creadted', descending: true),
  // ];

  static Future<ProductsRepository> init(MultiItemsSource source) =>
      DataRepository.init<ProductsRepository, MultiItemsSource>(
        ProductsRepository._,
        source,
      );

  static ProductsRepository get instance =>
      DataRepository.getInstance<ProductsRepository, MultiItemsSource>();

  // TODO paging
  Future<List<ProductData>> getList({int size = 0, String? afterId}) async {
    final list = await _source.getList();
    return list.items.map(ProductData.fromJson).toList();
  }

  Future<void> save(ProductData product) async {
    await _source.addItem(product.toJson());
  }

  Future<void> delete(String id) => _source.deleteItem(id);
}
