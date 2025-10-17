import 'package:keto_calculator/core/data/repository.dart';
import 'package:keto_calculator/core/models/meal.dart';

class MenuRepository extends MultiItemsRepository<MenuRepository> {
  MenuRepository._(super.source) : _source = source;
  final MultiItemsSource _source;
  static const _itemsOrder = [
    SourceItemsOrder('consumedCnt', descending: true),
    SourceItemsOrder('creadted', descending: true),
  ];

  static Future<MenuRepository> init(MultiItemsSource source) =>
      DataRepository.init<MenuRepository, MultiItemsSource>(
        MenuRepository._,
        source,
      );

  static MenuRepository get instance =>
      DataRepository.getInstance<MenuRepository, MultiItemsSource>();

  Future<List<Meal>> getList({int size = 0, String? afterId}) async {
    final list = await _source.getList(
      // size: size,
      // afterId: afterId,
      // orderBy: _itemsOrder,
    );
    return list.items.map(Meal.fromJson).toList();
  }

  Future<void> add(Meal meal) async {
    await _source.addItem(meal.toJson());
  }

  Future<void> consume(Meal meal) async {
    var Meal(:id, consumedCnt: cnt) = meal;
    if (id == null) return;
    cnt ??= 0;
    await _source.updateItem(id, {'consumedCnt': cnt + 1});
  }

  Future<void> delete(String id) => _source.deleteItem(id);
}
