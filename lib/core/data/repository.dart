abstract interface class SingleItemSource {
  Future<Map<String, dynamic>?> get();
  Future<void> set(
    Map<String, dynamic> data, {
    bool merge = false,
  });
  Future<void> delete();
  Future<bool> isExists();
}

class PaginatedItems {
  PaginatedItems(this._items, {String? lastItemId}) : _lastItemId = lastItemId;
  final List<Map<String, dynamic>> _items;
  final String? _lastItemId;

  List<Map<String, dynamic>> get items => _items;
  String? get lastItemId => _lastItemId;
}

abstract interface class MultiItemsSource {
  Future<List<Map<String, dynamic>>> getAll();
  Future<PaginatedItems> getList({
    int size,
    String? afterId,
    List<SourceItemsFilter>? filters,
    List<SourceItemsOrder>? orderBy,
    // bool includeId = true,
  });
  Future<Map<String, dynamic>> addItem(
    Map<String, dynamic> data, {
    String? id,
  });
  Future<Map<String, dynamic>?> getItem(String itemId);
  Future<void> updateItem(String itemId, Map<String, dynamic> data);
  Future<void> deleteItem(String itemId);
  Future<bool> isItemExists(String itemId);
  Future<void> clear();
}

final class SourceItemsFilter {
  SourceItemsFilter(
    this.field, {
    this.isEqualTo,
    this.isNotEqualTo,
    this.isLessThan,
    this.isLessThanOrEqualTo,
    this.isGreaterThan,
    this.isGreaterThanOrEqualTo,
    this.arrayContains,
    this.arrayContainsAny,
    this.whereIn,
    this.whereNotIn,
  });

  final String field;
  final Object? isEqualTo;
  final Object? isNotEqualTo;
  final Object? isLessThan;
  final Object? isLessThanOrEqualTo;
  final Object? isGreaterThan;
  final Object? isGreaterThanOrEqualTo;
  final Object? arrayContains;
  final List<Object?>? arrayContainsAny;
  final List<Object?>? whereIn;
  final List<Object?>? whereNotIn;
}

final class SourceItemsOrder {
  const SourceItemsOrder(this.field, {this.descending = false});
  final String field;
  final bool descending;
}

abstract class DataRepository<T extends DataRepository<T, DF>, DF> {
  DataRepository(this._source);
  // ignore: unused_field only to show contract of the constructor
  late final DF _source;

  static final Map<Type, DataRepository> _instances = {};

  static Future<T> init<T extends DataRepository<T, DF>, DF>(
    T Function(DF source) creator,
    DF source,
  ) async {
    if (_instances[T] == null) {
      _instances[T] = creator(source);
    }
    return _instances[T]! as T;
  }

  static T getInstance<T extends DataRepository<T, DF>, DF>() {
    final instance = _instances[T];
    if (instance == null) {
      throw StateError(
        'Repository of type $T not initialized. Call init() first.',
      );
    }
    return instance as T;
  }
}

abstract class SingleItemRepository<T extends SingleItemRepository<T>>
    extends DataRepository<T, SingleItemSource> {
  SingleItemRepository(super._source);
}

abstract class MultiItemsRepository<T extends MultiItemsRepository<T>>
    extends DataRepository<T, MultiItemsSource> {
  MultiItemsRepository(super._source);
}
